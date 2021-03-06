import ComposableArchitecture
import SwiftUI
import WaniKani
import WaniKaniComposableClient
import WaniKaniHelpers

public struct ProfileState: Equatable {
    public var alert: AlertState<ProfileAction>?

    public var username: String
    public var userLevel: Int
    public var userOnVacation: Bool
    public var userSubscriptionType: User.Subscription.Kind
    public var userStarted: Date
    public var voiceActors: [VoiceActor] = []
    public var updateRequestInFlight: Bool = false

    @BindableState public var defaultVoiceActorID: Int
    @BindableState public var lessonsAutoplayAudio: Bool
    @BindableState public var lessonsBatchSize: Int
    @BindableState public var lessonsPresentationOrder: User.Preferences.PresentationOrder
    @BindableState public var reviewsAutoplayAudio: Bool
    @BindableState public var reviewsDisplaySRSIndicator: Bool

    public init(
        user: User
    ) {
        username = user.username
        userLevel = user.level
        userOnVacation = user.currentVacationStarted != nil
        userSubscriptionType = user.subscription.type
        userStarted = user.started

        defaultVoiceActorID = user.preferences.defaultVoiceActorID
        lessonsAutoplayAudio = user.preferences.autoplayLessonsAudio
        lessonsBatchSize = user.preferences.lessonsBatchSize
        lessonsPresentationOrder = user.preferences.lessonsPresentationOrder
        reviewsAutoplayAudio = user.preferences.autoplayReviewsAudio
        reviewsDisplaySRSIndicator = user.preferences.displayReviewsSRSIndicator
    }
}

public enum ProfileAction: BindableAction, Equatable {
    case onAppear
    case binding(BindingAction<ProfileState>)
    case getVoiceActorsResponse(Result<Response<VoiceActors.List>.Content, Error>)
    case updateUserResponse(Result<Response<Users.Update>.Content, Error>)
    case alertDismissed
    case logoutButtonTapped

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.onAppear, .onAppear),
            (.getVoiceActorsResponse(.success), .getVoiceActorsResponse(.success)),
            (.getVoiceActorsResponse(.failure), .getVoiceActorsResponse(.failure)),
            (.updateUserResponse(.success), .updateUserResponse(.success)),
            (.updateUserResponse(.failure), .updateUserResponse(.failure)),
            (.alertDismissed, .alertDismissed),
            (.logoutButtonTapped, .logoutButtonTapped):
            return true
        case (.binding(let a), .binding(let b)):
            return a == b
        default:
            return false
        }
    }
}

public struct ProfileEnvironment {
    public var wanikaniClient: WaniKaniComposableClient
    public var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        wanikaniClient: WaniKaniComposableClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.wanikaniClient = wanikaniClient
        self.mainQueue = mainQueue
    }
}

public let profileReducer = Reducer<ProfileState, ProfileAction, ProfileEnvironment> { state, action, environment in
    switch action {
    case .onAppear:
        return environment.wanikaniClient
            .listVoiceActors(.voiceActors(), nil)
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileAction.getVoiceActorsResponse)
    case .getVoiceActorsResponse(.success(let response)):
        state.voiceActors = Array(response)
        return .none
    case .getVoiceActorsResponse(.failure(let error)):
        state.alert = AlertState(
            title: TextState("WaniKani error"),
            message: TextState(error.localizedDescription)
        )
        return .none
    case .binding(\.$defaultVoiceActorID):
        state.updateRequestInFlight = true
        return environment.wanikaniClient
            .updateUser(.updateUser(defaultVoiceActorID: state.defaultVoiceActorID))
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileAction.updateUserResponse)
    case .binding(\.$lessonsAutoplayAudio):
        state.updateRequestInFlight = true
        return environment.wanikaniClient
            .updateUser(.updateUser(lessonsAutoplayAudio: state.lessonsAutoplayAudio))
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileAction.updateUserResponse)
    case .binding(\.$lessonsBatchSize):
        state.updateRequestInFlight = true
        return environment.wanikaniClient
            .updateUser(.updateUser(lessonsBatchSize: state.lessonsBatchSize))
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileAction.updateUserResponse)
    case .binding(\.$lessonsPresentationOrder):
        state.updateRequestInFlight = true
        return environment.wanikaniClient
            .updateUser(.updateUser(lessonsPresentationOrder: state.lessonsPresentationOrder))
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileAction.updateUserResponse)
    case .binding(\.$reviewsAutoplayAudio):
        state.updateRequestInFlight = true
        return environment.wanikaniClient
            .updateUser(.updateUser(reviewsAutoplayAudio: state.reviewsAutoplayAudio))
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileAction.updateUserResponse)
    case .binding(\.$reviewsDisplaySRSIndicator):
        state.updateRequestInFlight = true
        return environment.wanikaniClient
            .updateUser(.updateUser(reviewsDisplaySRSIndicator: state.reviewsDisplaySRSIndicator))
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileAction.updateUserResponse)
    case .binding:
        return .none
    case .updateUserResponse(.success(let response)):
        // TODO: green checkmark for updated property
        // TODO: update user used across app
        print("updated user")
        state.updateRequestInFlight = false
        return .none
    case .updateUserResponse(.failure(let error)):
        state.alert = AlertState(
            title: TextState("WaniKani error"),
            message: TextState(error.localizedDescription)
        )
        state.updateRequestInFlight = false
        return .none
    case .alertDismissed:
        state.alert = nil
        return .none
    case .logoutButtonTapped:
        return .none
    }
}
.binding()

public struct ProfileView: View {
    let store: Store<ProfileState, ProfileAction>

    public init(
        store: Store<ProfileState, ProfileAction>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            Form {
                Section {
                    HStack {
                        Text(viewStore.username)
                        Spacer()
                        if viewStore.userOnVacation {
                            Text("????")
                                .font(.body.bold())
                        }
                        Text("Level \(viewStore.userLevel)")
                    }

                    Text(
                        """
                        \(viewStore.userSubscriptionType.rawValue.capitalized) member since \(viewStore.userStarted.formatted(.dateTime.month().year()))
                        """
                    )
                }

                Section {
                    Picker("Default voice actor", selection: viewStore.binding(\.$defaultVoiceActorID)) {
                        ForEach(viewStore.voiceActors) { voiceActor in
                            Text(voiceActor.name)
                                .tag(voiceActor.id)
                        }
                    }
                    .disabled(viewStore.voiceActors.isEmpty)
                }
                Section("Lessons") {
                    Toggle("Autoplay audio", isOn: viewStore.binding(\.$lessonsAutoplayAudio))
                    Picker("Batch size", selection: viewStore.binding(\.$lessonsBatchSize)) {
                        ForEach(3...10, id: \.self) { value in
                            Text("\(value)")
                                .tag(value)
                        }
                    }
                }
                Section("Reviews") {
                    Toggle("Autoplay audio", isOn: viewStore.binding(\.$reviewsAutoplayAudio))
                    Toggle("Display SRS indicator", isOn: viewStore.binding(\.$reviewsDisplaySRSIndicator))
                    Picker("Presentation order", selection: viewStore.binding(\.$lessonsPresentationOrder)) {
                        ForEach(User.Preferences.PresentationOrder.allCases, id: \.self) { order in
                            Text(order.description)
                                .tag(order)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: {
                            viewStore.send(.logoutButtonTapped)
                        },
                        label: {
                            Text("Sign out")
                        }
                    )
                }
            }
            .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

extension User.Preferences.PresentationOrder: CaseIterable {
    public static let allCases: [Self] = [
        .ascendingLevelThenSubject,
        .shuffled,
        .ascendingLevelThenShuffled,
    ]
}

extension User.Preferences.PresentationOrder: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ascendingLevelThenSubject:
            return "Ascending level, then subject"
        case .shuffled:
            return "Shuffled"
        case .ascendingLevelThenShuffled:
            return "Ascending level, then shuffled"
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView(
                store: Store(
                    initialState: .init(user: .testing),
                    reducer: profileReducer,
                    environment: .init(
                        wanikaniClient: .testing,
                        mainQueue: .main
                    )
                )
            )
        }
    }
}
