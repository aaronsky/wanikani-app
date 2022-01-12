import AuthenticationClient
import ComposableArchitecture
import Home
import Login
import SubjectClient
import SwiftUI
import WaniKaniComposableClient

public enum AppState: Equatable {
    case login(LoginState)
    case home(HomeState)

    public init() {
        self = .login(.restoreSession(.init()))
    }
}

public enum AppAction: Equatable {
    case login(LoginAction)
    case home(HomeAction)
    case logout
    case scenePhaseChanged(ScenePhase)
    case openURL(URL)
}

public struct AppEnvironment {
    public var wanikaniClient: WaniKaniComposableClient
    public var authenticationClient: AuthenticationClient
    public var subjects: SubjectClient
    public var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        wanikaniClient: WaniKaniComposableClient,
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
            case .login(.authenticated(.success(let user))):
                state = .home(HomeState(user: user))
                return environment.subjects
                    .update(environment.wanikaniClient)
                    .receive(on: environment.mainQueue)
                    .fireAndForget()
            case .login:
                return .none
            case .home(.profile(.logoutButtonTapped)):
                return Effect.merge(
                    environment
                        .authenticationClient
                        .logout()
                        .catchToEffect { _ in () },
                    environment
                        .wanikaniClient
                        .setToken(nil)
                )
                    .receive(on: environment.mainQueue)
                    .map { _ in AppAction.logout }
                    .eraseToEffect()
            case .home:
                return .none
            case .logout:
                state = .login(.usernamePassword(.init()))
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
                        wanikaniClient: .testing,
                        authenticationClient: .testing,
                        subjects: .testing,
                        mainQueue: .main
                    )
                )
            )
        }
    }
}
