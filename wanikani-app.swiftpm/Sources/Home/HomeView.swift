import ComposableArchitecture
import Subjects
import SwiftUI
import WaniKani
import WaniKaniHelpers

public struct HomeState: Equatable {
    public var user: User
    public var summary: Summary?
    public var assignments: [Assignment] = []
    public var isLoading: Bool = false

    public init(
        user: User
    ) {
        self.user = user
    }
}

public enum HomeAction: Equatable {
    case onAppear
    case refresh
    case getSummaryResponse(Result<Response<Summaries.Get>, Error>)
    case getAssignmentsResponse(Result<Response<Assignments.List>, Error>)
    case profileButtonTapped
    case startReviewsButtonTapped

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.getSummaryResponse, .getSummaryResponse),
            (.profileButtonTapped, .profileButtonTapped),
            (.startReviewsButtonTapped, .startReviewsButtonTapped):
            return true
        default:
            return false
        }
    }
}

public struct HomeEnvironment {
    public var wanikaniClient: WaniKani
    public var subjects: SubjectClient
    public var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        wanikaniClient: WaniKani,
        subjects: SubjectClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.wanikaniClient = wanikaniClient
        self.subjects = subjects
        self.mainQueue = mainQueue
    }
}

public let homeReducer = Reducer<HomeState, HomeAction, HomeEnvironment> { state, action, environment in
    switch action {
    case .onAppear, .refresh:
        state.isLoading = true
        return
            Effect.merge(
                environment.wanikaniClient.send(.summary)
                    .catchToEffect(HomeAction.getSummaryResponse),
                environment.wanikaniClient.send(.assignments(levels: [state.user.level]))
                    .catchToEffect(HomeAction.getAssignmentsResponse)
            )
            .receive(on: environment.mainQueue)
            .eraseToEffect()
    case .getSummaryResponse(.success(let response)):
        state.summary = response.data
        return .none
    case .getSummaryResponse:
        // TODO: alerting
        return .none
    case .getAssignmentsResponse(.success(let response)):
        state.assignments = Array(response.data)
        return .none
    case .getAssignmentsResponse:
        // TODO: alerting
        return .none
    case .profileButtonTapped:
        return .none
    case .startReviewsButtonTapped:
        return .none
    }
}

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
                        if let nextReviews = viewStore.summary?.nextReviews {
                            Text(
                                "Your next review will be in \(nextReviews.formatted(.relative(presentation: .named)))"
                            )
                            .font(.subheadline.bold())
                        }

                        LevelProgressionBar(store: store)
                    }
                    Text("Coming Up")
                        .font(.title2.bold())
                    Section(
                        header: Text("Lessons")
                            .font(.title3.bold())
                    ) {
                        if let summary = viewStore.summary {
                            LessonsReviewsCard(
                                kind: .lessons,
                                summary: summary,
                                showUpcoming: true
                            )
                        } else if viewStore.isLoading {
                            ProgressView()
                        }
                    }
                    Section(
                        header: Text("Reviews")
                            .font(.title3.bold())
                    ) {
                        if let summary = viewStore.summary {
                            LessonsReviewsCard(
                                kind: .reviews,
                                summary: summary,
                                showUpcoming: false
                            )
                        } else if viewStore.isLoading {
                            ProgressView()
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Welcome, \(viewStore.user.username)!")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            viewStore.send(.profileButtonTapped)
                        },
                        label: {
                            Label("Profile", systemImage: "gear")
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
            .refreshable {
                await viewStore.send(.refresh, while: \.isLoading)
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
                        wanikaniClient: .init(),
                        subjects: .testing,
                        mainQueue: .main
                    )
                )
            )
        }
    }
}
