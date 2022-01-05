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
    case onAppear
    case login(LoginAction)
    case home(HomeAction)
    case scenePhaseChanged(ScenePhase)
    case openURL(URL)
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
            case .onAppear:
                return environment.authenticationClient
                    .login(
                        .init(token: nil, storeValidTokenInKeychain: false),
                        environment.wanikaniClient
                    )
                    .receive(on: environment.mainQueue)
                    .catchToEffect {
                        AppAction.login(.loginResponse($0.mapError { $0 as! AuthenticationError }))
                    }
            case .login(.loginResponse(.success(let response))):
                state = .home(HomeState(user: response.user))
                return environment.subjects
                    .update(environment.wanikaniClient)
                    .fireAndForget()
            case .login:
                return .none
            case .home:
                return .none
            case .scenePhaseChanged(.background):
                return environment.subjects.save.fireAndForget()
            case .scenePhaseChanged:
                return .none
            case .openURL:
                // TODO: routing
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
