import ComposableArchitecture
import SwiftUI
import WaniKani
import WaniKaniHelpers

public struct ProfileState: Equatable {
    var username: String
    var userLevel: Int
    var userOnVacation: Bool
    var userSubscriptionType: User.Subscription.Kind
    var userStarted: Date
    var voiceActors: [VoiceActor] = []
    var updateRequestInFlight: Bool = false

    @BindableState var defaultVoiceActorID: Int
    @BindableState var lessonsAutoplayAudio: Bool
    @BindableState var lessonsBatchSize: Int
    @BindableState var lessonsPresentationOrder: User.Preferences.PresentationOrder
    @BindableState var reviewsAutoplayAudio: Bool
    @BindableState var reviewsDisplaySRSIndicator: Bool

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
    case getVoiceActorsResponse(Result<Response<VoiceActors.List>, Error>)
    case updateUserResponse(Result<Response<Users.Update>, Error>)

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.onAppear, .onAppear),
            (.getVoiceActorsResponse(.success), .getVoiceActorsResponse(.success)),
            (.getVoiceActorsResponse(.failure), .getVoiceActorsResponse(.failure)),
            (.updateUserResponse(.success), .updateUserResponse(.success)),
            (.updateUserResponse(.failure), .updateUserResponse(.failure)):
            return true
        case (.binding(let a), .binding(let b)):
            return a == b
        default:
            return false
        }
    }
}

public struct ProfileEnvironment {
    public var wanikaniClient: WaniKani
    public var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        wanikaniClient: WaniKani,
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
            .send(.voiceActors())
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileAction.getVoiceActorsResponse)
    case .getVoiceActorsResponse(.success(let response)):
        state.voiceActors = Array(response.data)
        return .none
    case .getVoiceActorsResponse:
        // TODO: alerting
        return .none
    case .binding(\.$defaultVoiceActorID):
        state.updateRequestInFlight = true
        return environment.wanikaniClient
            .send(.updateUser(defaultVoiceActorID: state.defaultVoiceActorID))
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileAction.updateUserResponse)
    case .binding(\.$lessonsAutoplayAudio):
        state.updateRequestInFlight = true
        return environment.wanikaniClient
            .send(.updateUser(lessonsAutoplayAudio: state.lessonsAutoplayAudio))
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileAction.updateUserResponse)
    case .binding(\.$lessonsBatchSize):
        state.updateRequestInFlight = true
        return environment.wanikaniClient
            .send(.updateUser(lessonsBatchSize: state.lessonsBatchSize))
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileAction.updateUserResponse)
    case .binding(\.$lessonsPresentationOrder):
        state.updateRequestInFlight = true
        return environment.wanikaniClient
            .send(.updateUser(lessonsPresentationOrder: state.lessonsPresentationOrder.rawValue))
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileAction.updateUserResponse)
    case .binding(\.$reviewsAutoplayAudio):
        state.updateRequestInFlight = true
        return environment.wanikaniClient
            .send(.updateUser(reviewsAutoplayAudio: state.reviewsAutoplayAudio))
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileAction.updateUserResponse)
    case .binding(\.$reviewsDisplaySRSIndicator):
        state.updateRequestInFlight = true
        return environment.wanikaniClient
            .send(.updateUser(reviewsDisplaySRSIndicator: state.reviewsDisplaySRSIndicator))
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileAction.updateUserResponse)
    case .binding:
        return .none
    case .updateUserResponse(.success(let response)):
        // TODO: green checkmark for updated property
        // TODO: update user used across app
        state.updateRequestInFlight = false
        return .none
    case .updateUserResponse:
        // TODO: alerting
        state.updateRequestInFlight = false
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
                    Text("\(viewStore.username) – Level \(viewStore.userLevel) \(viewStore.userOnVacation ? "🌴" : "")")
                    Text(
                        "\(viewStore.userSubscriptionType.rawValue.capitalized) member since \(viewStore.userStarted.formatted(.dateTime.month().year()))"
                    )
                }
                Section {
                    Picker("Default voice actor", selection: viewStore.binding(\.$defaultVoiceActorID)) {
                        ForEach(viewStore.voiceActors) { voiceActor in
                            Text("\(voiceActor.name) (\(voiceActor.description))")
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