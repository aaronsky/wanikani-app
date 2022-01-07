import Authentication
import ComposableArchitecture
import Home
import Login
import Subjects
import SwiftUI
import WaniKani

public enum AppState: Equatable {
    case restoreSession(RestoreSessionState)
    case login(LoginState)
    case home(HomeState)

    public init() {
        self = .restoreSession(.init())
    }
}

public enum AppAction: Equatable {
    case restoreSession(RestoreSessionAction)
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
        restoreSessionReducer
            .pullback(
                state: /AppState.restoreSession,
                action: /AppAction.restoreSession,
                environment: {
                    RestoreSessionEnvironment(
                        wanikaniClient: $0.wanikaniClient,
                        authenticationClient: $0.authenticationClient,
                        mainQueue: $0.mainQueue
                    )
                }
            ),
        loginReducer
            .pullback(
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
        homeReducer
            .pullback(
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
            case .restoreSession(.restoreSession(.success(let response))):
                state = .home(HomeState(user: response.user))
                return environment.subjects
                    .update(environment.wanikaniClient)
                    .receive(on: environment.mainQueue)
                    .fireAndForget()
            case .restoreSession(.restoreSession(.failure(let error))):
                print(error)
                state = .login(.init())
                return .none
            case .restoreSession:
                return .none
            case .login(.loginResponse(.success(let response))):
                state = .home(HomeState(user: response.user))
                return environment.subjects
                    .update(environment.wanikaniClient)
                    .receive(on: environment.mainQueue)
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

public struct AppView: View {
    let store: Store<AppState, AppAction>

    public init(
        store: Store<AppState, AppAction>
    ) {
        self.store = store
    }

    public var body: some View {
        SwitchStore(store) {
            CaseLet(state: /AppState.restoreSession, action: AppAction.restoreSession) { store in
                RestoreSessionView(store: store)
            }
            CaseLet(state: /AppState.login, action: AppAction.login) { store in
                NavigationView {
                    LoginView(store: store)
                }
                .navigationViewStyle(.stack)
            }
            CaseLet(state: /AppState.home, action: AppAction.home) { store in
                NavigationView {
                    HomeView(store: store)
                }
                .navigationViewStyle(.stack)
            }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppView(
                store: Store(
                    initialState: .init(),
                    reducer: appReducer,
                    environment: .init(
                        wanikaniClient: .init(),
                        authenticationClient: .testing,
                        subjects: .testing,
                        mainQueue: .main
                    )
                )
            )
        }
    }
}
