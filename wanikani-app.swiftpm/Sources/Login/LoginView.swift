import Authentication
import ComposableArchitecture
import Home
import SwiftUI
import WaniKaniHelpers

public struct LoginState: Equatable {
    public var alert: AlertState<LoginAction>?
    public var token = ""
    public var isTokenValid = false
    public var isLoginRequestInFlight = false
    public var home: HomeState?

    public init() {}
}

public enum LoginAction: Equatable {
    case tokenChanged(String)
    case alertDismissed
    case loginButtonTapped
    case loginResponse(Result<AuthenticationResponse, AuthenticationError>)
    case home(HomeAction)
}

public struct LoginEnvironment {
    public var wanikaniClient: WaniKani
    public var authenticationClient: AuthenticationClient
    public var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        wanikaniClient: WaniKani,
        authenticationClient: AuthenticationClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.wanikaniClient = wanikaniClient
        self.authenticationClient = authenticationClient
        self.mainQueue = mainQueue
    }
}

public let loginReducer = Reducer<LoginState, LoginAction, LoginEnvironment> { state, action, environment in
    switch action {
    case .tokenChanged(let token):
        state.token = token
        state.isTokenValid = !state.token.isEmpty
        return .none
    case .alertDismissed:
        state.alert = nil
        return .none
    case .loginButtonTapped:
        state.isLoginRequestInFlight = true
        return environment
            .authenticationClient
            .login(LoginRequest(token: state.token), environment.wanikaniClient)
            .receive(on: environment.mainQueue)
            .catchToEffect {
                LoginAction.loginResponse($0.mapError { $0 as! AuthenticationError })
            }
    case .loginResponse(.success(let response)):
        state.isLoginRequestInFlight = false
        state.home = HomeState(user: response.user)
        return .none
    case .loginResponse(.failure(let error)):
        state.alert = .init(title: TextState(error.localizedDescription))
        state.isLoginRequestInFlight = false
        return .none
    case .home:
        return .none
    }
}

public struct LoginView: View {
    let store: Store<LoginState, LoginAction>

    public init(
        store: Store<LoginState, LoginAction>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(spacing: 16) {
                    Text(
                        """
                        This application requires a WaniKani access token. Please provide one with the appropriate scopes.
                        """
                    )

                    SecureField(
                        "access token",
                        text: viewStore.binding(get: \.token, send: LoginAction.tokenChanged)
                    )
                    .textFieldStyle(.roundedBorder)

                    NavigationLink(
                        destination: IfLetStore(
                            store.scope(state: \.home, action: LoginAction.home),
                            then: HomeView.init(store:)
                        ),
                        isActive: viewStore.binding(
                            get: { $0.home != nil },
                            send: .loginButtonTapped
                        )
                    ) {
                        Text("Log In")

                        if viewStore.isLoginRequestInFlight {
                            ProgressView()
                        }
                    }
                    .disabled(!viewStore.isTokenValid)
                }
                .disabled(viewStore.isLoginRequestInFlight)
                .padding(.horizontal)
            }
            .navigationTitle("Login")
            .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView(
                store: Store(
                    initialState: .init(),
                    reducer: loginReducer,
                    environment: .init(
                        wanikaniClient: .init(),
                        authenticationClient: .testing,
                        mainQueue: .main
                    )
                )
            )
        }
    }
}
