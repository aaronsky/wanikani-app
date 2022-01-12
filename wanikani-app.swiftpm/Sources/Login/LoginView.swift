import AuthenticationClient
import ComposableArchitecture
import SwiftUI
import WaniKani
import WaniKaniComposableClient

public enum LoginState: Equatable {
    case restoreSession(RestoreSessionState)
    case usernamePassword(UsernamePasswordState)
    case createAccessToken(CreateAccessTokenState)
}

public enum LoginAction: Equatable {
    case restoreSession(RestoreSessionAction)
    case usernamePassword(UsernamePasswordAction)
    case createAccessToken(CreateAccessTokenAction)
    case authenticated(Result<User, Error>)

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.restoreSession(let a), .restoreSession(let b)):
            return a == b
        case (.usernamePassword(let a), .usernamePassword(let b)):
            return a == b
        case (.createAccessToken(let a), .createAccessToken(let b)):
            return a == b
        case (.authenticated(.success), .authenticated(.success)),
            (.authenticated(.failure), .authenticated(.failure)):
            return true
        default:
            return false
        }
    }

}

public struct LoginEnvironment {
    public var wanikaniClient: WaniKaniComposableClient
    public var authenticationClient: AuthenticationClient
    public var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        wanikaniClient: WaniKaniComposableClient,
        authenticationClient: AuthenticationClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.wanikaniClient = wanikaniClient
        self.authenticationClient = authenticationClient
        self.mainQueue = mainQueue
    }
}

public let loginReducer = Reducer<LoginState, LoginAction, LoginEnvironment>
    .combine(
        restoreSessionReducer
            .pullback(
                state: /LoginState.restoreSession,
                action: /LoginAction.restoreSession,
                environment: { $0 }
            ),
        usernamePasswordReducer
            .pullback(
                state: /LoginState.usernamePassword,
                action: /LoginAction.usernamePassword,
                environment: { $0 }
            ),
        createAccessTokenReducer
            .pullback(
                state: /LoginState.createAccessToken,
                action: /LoginAction.createAccessToken,
                environment: { $0 }
            ),
        Reducer { state, action, environment in
            switch action {
            case .restoreSession(.response(.success(.authenticated(let response)))),
                 .usernamePassword(.response(.success(.authenticated(let response)))),
                 .createAccessToken(.response(.success(.authenticated(let response)))):
                return environment
                    .wanikaniClient
                    .setToken(response.accessToken)
                    .flatMap {
                        environment.wanikaniClient.me()
                    }
                    .receive(on: environment.mainQueue)
                    .catchToEffect(LoginAction.authenticated)
            case .restoreSession(.response(.success(.needsAccessToken(let request)))),
                .usernamePassword(.response(.success(.needsAccessToken(let request)))):
                state = .createAccessToken(.init(request: request))
                return .none
            case .restoreSession(.response(.success(.noSession))), .restoreSession(.response(.failure)):
                state = .usernamePassword(.init())
                return .none
            case .restoreSession:
                return .none
            case .usernamePassword:
                return .none
            case .createAccessToken:
                return .none
            case .authenticated:
                return .none
            }
        }
    )

public struct LoginView: View {
    let store: Store<LoginState, LoginAction>

    public init(
        store: Store<LoginState, LoginAction>
    ) {
        self.store = store
    }

    public var body: some View {
        SwitchStore(store) {
            CaseLet(state: /LoginState.restoreSession, action: LoginAction.restoreSession) { store in
                RestoreSessionView(store: store)
                    .navigationTitle("")
            }
            CaseLet(state: /LoginState.usernamePassword, action: LoginAction.usernamePassword) { store in
                ScrollView {
                    UsernamePasswordView(store: store)
                        .navigationTitle("Login")
                }
            }
            CaseLet(state: /LoginState.createAccessToken, action: LoginAction.createAccessToken) { store in
                CreateAccessTokenView(store: store)
                    .navigationTitle("Create Access Token")
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView(
                store: Store(
                    initialState: .usernamePassword(.init()),
                    reducer: loginReducer,
                    environment: .init(
                        wanikaniClient: .testing,
                        authenticationClient: .testing,
                        mainQueue: .main
                    )
                )
            )
        }
    }
}
