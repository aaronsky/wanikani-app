import ComposableArchitecture
import Profile
import SubjectClient
import Subjects
import SwiftUI
import WaniKani
import WaniKaniComposableClient

public struct HomeState: Equatable {
    public enum SubjectsPurpose: Hashable {
        case lessons
        case reviews
    }

    public var alert: AlertState<HomeAction>?

    public var user: User
    public var summary: Summary?
    public var assignments: [Assignment] = []
    public var subjectGroups: [SubjectsPurpose: [Subject]] = [:]
    public var profile: ProfileState?
    public var subjects: SubjectsState?

    public init(
        user: User
    ) {
        self.user = user
    }
}

public enum HomeAction: Equatable {
    case onAppear
    case refresh
    case getSummaryResponse(Result<Response<Summaries.Get>.Content, Error>)
    case getAssignmentsResponse(Result<Response<Assignments.List>.Content, Error>)
    case getSubjectResponse(Result<(HomeState.SubjectsPurpose, Subject?), Error>)
    case profileButtonTapped
    case profile(ProfileAction)
    case profileDismissed
    case subjects(SubjectsAction)
    case startReviewsButtonTapped
    case alertDismissed

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.onAppear, .onAppear),
            (.refresh, .refresh),
            (.getSummaryResponse, .getSummaryResponse),
            (.getAssignmentsResponse, .getAssignmentsResponse),
            (.getSubjectResponse, .getSubjectResponse),
            (.profileButtonTapped, .profileButtonTapped),
            (.profile, .profile),
            (.profileDismissed, .profileDismissed),
            (.subjects, .subjects),
            (.startReviewsButtonTapped, .startReviewsButtonTapped),
            (.alertDismissed, .alertDismissed):
            return true
        default:
            return false
        }
    }
}

public struct HomeEnvironment {
    public var wanikaniClient: WaniKaniComposableClient
    public var subjects: SubjectClient
    public var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        wanikaniClient: WaniKaniComposableClient,
        subjects: SubjectClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.wanikaniClient = wanikaniClient
        self.subjects = subjects
        self.mainQueue = mainQueue
    }
}

public let homeReducer = Reducer<HomeState, HomeAction, HomeEnvironment>
    .combine(
        profileReducer
            .optional()
            .pullback(
                state: \.profile,
                action: /HomeAction.profile,
                environment: {
                    ProfileEnvironment(
                        wanikaniClient: $0.wanikaniClient,
                        mainQueue: $0.mainQueue
                    )
                }
            ),
        subjectsReducer
            .optional()
            .pullback(
                state: \.subjects,
                action: /HomeAction.subjects,
                environment: { _ in
                    SubjectsEnvironment()
                }
            ),
        Reducer { state, action, environment in
            switch action {
            case .onAppear, .refresh:
                return
                    Effect.merge(
                        environment.wanikaniClient
                            .summary()
                            .catchToEffect(HomeAction.getSummaryResponse),
                        environment.wanikaniClient
                            .listAssignments(.assignments(levels: [state.user.level]), nil)
                            .catchToEffect(HomeAction.getAssignmentsResponse)
                    )
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
            case .getSummaryResponse(.success(let summary)):
                state.summary = summary
                return Effect.merge(
                    Effect.merge(
                        summary
                            .lessons
                            .flatMap { $0.subjectIDs }
                            .publisher
                            .flatMap {
                                environment.subjects.get($0)
                                    .map { (.lessons, $0) }
                            }
                            .catchToEffect(HomeAction.getSubjectResponse)
                    ),
                    Effect.merge(
                        summary
                            .reviews
                            .filter { $0.available.timeIntervalSinceNow < 0 }
                            .flatMap { $0.subjectIDs }
                            .publisher
                            .flatMap {
                                environment.subjects.get($0)
                                    .map { (.reviews, $0) }
                            }
                            .catchToEffect(HomeAction.getSubjectResponse)
                    )
                )
            case .getSummaryResponse(.failure(let error)):
                state.alert = AlertState(
                    title: TextState("WaniKani error"),
                    message: TextState(error.localizedDescription)
                )
                return .none
            case .getAssignmentsResponse(.success(let response)):
                state.assignments = Array(response)
                return .none
            case .getAssignmentsResponse(.failure(let error)):
                state.alert = AlertState(
                    title: TextState("WaniKani error"),
                    message: TextState(error.localizedDescription)
                )
                return .none
            case .getSubjectResponse(.success((let purpose, .some(let subject)))):
                state.subjectGroups[purpose, default: []].append(subject)
                return .none
            case .getSubjectResponse:
                // no alert necessary here
                return .none
            case .profileButtonTapped:
                state.profile = ProfileState(user: state.user)
                return .none
            case .profile(.logoutButtonTapped):
                state.profile = nil
                return .none
            case .profile:
                return .none
            case .profileDismissed:
                state.profile = nil
                return .none
            case .subjects:
                return .none
            case .startReviewsButtonTapped:
                return .none
            case .alertDismissed:
                state.alert = nil
                return .none
            }
        }
    )

public struct HomeView: View {
    let store: Store<HomeState, HomeAction>

    public init(
        store: Store<HomeState, HomeAction>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Section {
                        Text("Welcome, \(viewStore.user.username)!")
                            .font(.title.bold())
                        if let nextReviews = viewStore.summary?.nextReviews {
                            Text(
                                "Your next review will be in \(nextReviews.formatted(.relative(presentation: .named)))"
                            )
                            .font(.subheadline.bold())
                        }

                        LevelProgressionBar(state: .init(user: viewStore.user, assignments: viewStore.assignments))
                    }
                    Text("Coming Up")
                        .font(.title2.bold())
                    Section(
                        header: Text("Lessons")
                            .font(.title3.bold())
                    ) {
                        LessonsReviewsCard(
                            kind: .lessons,
                            subjects: viewStore.subjectGroups[.lessons, default: []],
                            showUpcoming: true
                        )
                    }
                    Section(
                        header: Text("Reviews")
                            .font(.title3.bold())
                    ) {
                        LessonsReviewsCard(
                            kind: .reviews,
                            subjects: viewStore.subjectGroups[.reviews, default: []],
                            showUpcoming: false
                        )
                    }

                    Section(
                        header: Text("More")
                            .font(.title3.bold())
                    ) {

                        NavigationLink(
                            destination: IfLetStore(
                                store.scope(
                                    state: \.subjects,
                                    action: HomeAction.subjects
                                ),
                                then: SubjectsView.init(store:)
                            )
                        ) {
                            Label("Subjects", systemImage: "gear")
                        }
                        NavigationLink(destination: EmptyView()) {
                            Label("Progress", systemImage: "gear")
                        }
                        NavigationLink(destination: EmptyView()) {
                            Label("Dominic", systemImage: "gear")
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
            .sheet(
                isPresented: viewStore.binding(
                    get: { $0.profile != nil },
                    send: .profileDismissed
                )
            ) {
                IfLetStore(
                    store.scope(state: \.profile, action: HomeAction.profile)
                ) { profileStore in
                    NavigationView {
                        ProfileView(store: profileStore)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            viewStore.send(.profileButtonTapped)
                        },
                        label: {
                            Label("Profile", systemImage: "person.circle")
                        }
                    )
                }

                ToolbarItemGroup(placement: .bottomBar) {
                    Button(
                        action: {
                            viewStore.send(.startReviewsButtonTapped)
                        },
                        label: {
                            Label("Start Review", systemImage: "square.and.pencil")
                                .font(.body)
                                .labelStyle(.titleAndIcon)
                        }
                    )
                    Spacer()
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(
                store: Store(
                    initialState: .init(user: .testing),
                    reducer: homeReducer,
                    environment: .init(
                        wanikaniClient: .testing,
                        subjects: .testing,
                        mainQueue: .main
                    )
                )
            )
        }
    }
}
