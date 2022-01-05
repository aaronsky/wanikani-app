import Authentication
import ComposableArchitecture
import Home
import Login
import Subjects
import SwiftUI
import WaniKani

public enum AppState: Equatable {
    case login(LoginState)
    case home(HomeState)

    public init() {
        self = .login(.init())
    }
}

public enum AppAction: Equatable {
    case login(LoginAction)
    case home(HomeAction)
    case scenePhaseChanged(ScenePhase)
}

public struct AppEnvironment {
    public var wanikaniClient: WaniKani
    public var authenticationClient: AuthenticationClient
    public var subjects: SubjectClient
    public var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        wanikaniClient: WaniKani,
        authenticationClient: AuthenticationClient,
        subjects: SubjectClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.wanikaniClient = wanikaniClient
        self.authenticationClient = authenticationClient
        self.subjects = subjects
        self.mainQueue = mainQueue
    }
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>
    .combine(
        loginReducer.pullback(
            state: /AppState.login,
            action: /AppAction.login,
            environment: {
                LoginEnvironment(
                    wanikaniClient: $0.wanikaniClient,
                    authenticationClient: $0.authenticationClient,
                    mainQueue: $0.mainQueue
                )
            }
        ),
        homeReducer.pullback(
            state: /AppState.home,
            action: /AppAction.home,
            environment: {
                HomeEnvironment(
                    wanikaniClient: $0.wanikaniClient,
                    subjects: $0.subjects,
                    mainQueue: $0.mainQueue
                )
            }
        ),
        Reducer { state, action, environment in
            switch action {
            case .login(.loginResponse(.success(let response))):
                state = .home(HomeState(user: response.user))
                //                environment.subjects.load(SubjectsLoadRequest(url: ))
                return .none
            case .login:
                return .none
            case .home:
                return .none
            case .scenePhaseChanged(.background):
                //                environment.subjects.save(SubjectsSaveRequest(subjects: , url: ))
                return .none
            case .scenePhaseChanged:
                return .none
            }
        }
    )
    .debug()

public struct AppView: View {
    let store: Store<AppState, AppAction>

    public init(
        store: Store<AppState, AppAction>
    ) {
        self.store = store
    }

    public var body: some View {
        SwitchStore(store) {
            CaseLet(state: /AppState.login, action: AppAction.login) { store in
                NavigationView {
                    LoginView(store: store)
                }
            }
            CaseLet(state: /AppState.home, action: AppAction.home) { store in
                NavigationView {
                    HomeView(store: store)
                }
            }
        }
    }
}

// public struct AppView: View {
//    @Environment(\.scenePhase) private var scenePhase
//
//    var body: some View {
//        NavigationView {
//            Switch(viewModel.authentication.$state) {
//                CaseLet(/AuthenticationStore.State.unknown) {
//                    ProgressView()
//                }
//                CaseLet(/AuthenticationStore.State.notAuthenticated) {
//                    LoginView(
//                        onLogin: viewModel.login,
//                        onLogout: viewModel.authentication.logout
//                    )
//                }
//                CaseLet(/AuthenticationStore.State.authenticated) { $user in
//                    HomeView(
//                        viewModel: HomeViewModel(
//                            client: viewModel.wanikaniClient,
//                            subjects: viewModel.subjects,
//                            user: $user
//                        )
//                    )
//                        .toolbar(content: toolbar)
//                        .sheet(isPresented: $showProfileScreen) {
//                            ProfileView(
//                                viewModel: ProfileViewModel(
//                                    client: viewModel.wanikaniClient,
//                                    user: $viewModel.user
//                                )
//                            )
//                        }
//                }
//            }
//        }
//        .onOpenURL { url in
//            viewModel.open(url: url)
//        }
//        .task {
//            try! await viewModel.loadSubjectsFromDisk()
//        }
//        .task {
//            try? await viewModel.login()
//        }
//        .onChange(of: scenePhase) { phase in
//            guard phase == .inactive else {
//                return
//            }
//
//            Task {
//                await viewModel.prepareForBackground()
//            }
//        }
//    }
//
//    @ToolbarContentBuilder
//    func toolbar() -> some ToolbarContent {
//        ToolbarItem(placement: .navigationBarLeading) {
//            Button(
//                action: {
//                    showProfileScreen = true
//                },
//                label: {
//                    Label("Profile", systemImage: "gear")
//                }
//            )
//        }
//    }
// }
//
// @MainActor
// class AppViewModel: ObservableObject {
//    @Published var authentication: AuthenticationStore
//    @Published var subjects: SubjectsStore
//    @Published var user: User?
//
//    let wanikaniClient: WaniKani
//    let urlSession: URLSession
//
//    var authCancellables: Set<AnyCancellable> = []
//
//    init(
//        wanikaniClient: WaniKani? = nil,
//        urlSession: URLSession = .init(configuration: .default),
//        authentication: AuthenticationStore = .init(),
//        subjects: SubjectsStore = .init()
//    ) {
//        self.wanikaniClient = wanikaniClient ?? WaniKani(transport: urlSession)
//        self.urlSession = urlSession
//        self.authentication = authentication
//        self.subjects = subjects
//
//        authentication.$state
//            .filter { $0 == .authenticated }
//            .removeDuplicates()
//            .sink { [unowned self] _ in
//                Task.detached(priority: .background) {
//                    try! await self.subjects.reloadIfNeeded(client: self.wanikaniClient)
//                }
//            }
//            .store(in: &authCancellables)
//    }
//
//    func loadSubjectsFromDisk() async throws {
//        try await subjects.loadPersistentStore(session: urlSession)
//    }
//
//    func prepareForBackground() async {
//        try? subjects.save()
//    }
//
//    func login(_ token: String? = nil) async throws {
//        let user = try await authentication.login(token, client: wanikaniClient)
//        self.user = user
//    }
//
//    func open(url: URL) {
//    }
// }
