import ComposableArchitecture
import SwiftUI
import WaniKani

public struct ProfileState: Equatable {
    var username: String
    var userLevel: Int
    var userOnVacation: Bool
    var userSubscriptionType: User.Subscription.Kind
    var userStarted: Date

    @BindableState var defaultVoiceActorID: Int
    @BindableState var lessonsAutoplayAudio: Bool
    @BindableState var lessonsBatchSize: Int
    @BindableState var lessonsPresentationOrder: User.Preferences.PresentationOrder
    @BindableState var reviewsAutoplayAudio: Bool
    @BindableState var reviewsDisplaySRSIndicator: Bool
    @BindableState var voiceActors: [VoiceActor] = []

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
    case binding(BindingAction<ProfileState>)
    //    case updateUserResponse(Result<User, Error>)
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
    case .binding(\.$defaultVoiceActorID):
        return .none
    case .binding(\.$lessonsAutoplayAudio):
        return .none
    case .binding(\.$lessonsBatchSize):
        return .none
    case .binding(\.$lessonsPresentationOrder):
        return .none
    case .binding(\.$reviewsAutoplayAudio):
        return .none
    case .binding(\.$reviewsDisplaySRSIndicator):
        return .none
    case .binding:
        return .none
    //    case .updateUserResponse(.success(let user)):
    //        return .none
    //    case .updateUserResponse(.failure(let error)):
    //        return .none
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
                //                Section {
                //                    Picker("Default voice actor", section: viewStore.binding(\.defaultVoiceActorID)) {
                //                        ForEach(voiceActors) { voiceActor in
                //                            Text("\(voiceActor.name) (\(voiceActor.description))")
                //                                .tag(voiceActor.id)
                //                        }
                //                    }.disabled(voiceActors.isEmpty)
                //                }
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
        }
    }
}
//            }
//        .onAppear(perform: populateDefaultState)
//        // .handlingErrors(in: viewModel.error, onRequiresLogout: {})
//        .task {
//            await viewModel.fetchVoiceActors()
//        }

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

@MainActor class ProfileViewModel: ObservableObject {
    @Published var error: Error?

    @Published var voiceActors: [VoiceActor] = []

    let client: WaniKani
    @Binding var user: User?

    init(
        client: WaniKani,
        user: Binding<User?>
    ) {
        self.client = client
        self._user = user
    }

    func fetchVoiceActors() async {
        do {
            let response = try await client.send(.voiceActors())
            voiceActors = Array(response.data)
        } catch {
            self.error = error
        }
    }

    func updateUserPreferences(
        defaultVoiceActorID: Int? = nil,
        lessonsAutoplayAudio: Bool? = nil,
        lessonsBatchSize: Int? = nil,
        lessonsPresentationOrder: String? = nil,
        reviewsAutoplayAudio: Bool? = nil,
        reviewsDisplaySRSIndicator: Bool? = nil
    ) async {
        do {
            let response = try await client.send(
                .updateUser(
                    defaultVoiceActorID: defaultVoiceActorID,
                    lessonsAutoplayAudio: lessonsAutoplayAudio,
                    lessonsBatchSize: lessonsBatchSize,
                    lessonsPresentationOrder: lessonsPresentationOrder,
                    reviewsAutoplayAudio: reviewsAutoplayAudio,
                    reviewsDisplaySRSIndicator: reviewsDisplaySRSIndicator
                )
            )
            user = response.data
        } catch {
            self.error = error
        }
    }
}
