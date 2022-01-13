import AuthenticationClient
import ComposableArchitecture
import SwiftUI
import SwiftUIHelpers

public struct UsernamePasswordState: Equatable {
    enum Field: String, Hashable {
        case username, password
    }

    @BindableState var username = ""
    @BindableState var password = ""
    @BindableState var focusedField: Field? = nil
    @BindableState var showPasswordFieldText = false

    var canLogIn = false
    var isRequestInFlight = false
    var alert: AlertState<UsernamePasswordAction>?

    public init() {}
}

public enum UsernamePasswordAction: BindableAction, Equatable {
    case alertDismissed
    case binding(BindingAction<UsernamePasswordState>)
    case loginButtonTapped
    case response(Result<AuthenticationAction, Error>)

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.alertDismissed, .alertDismissed),
            (.loginButtonTapped, .loginButtonTapped),
            (.response(.success), .response(.success)),
            (.response(.failure), .response(.failure)):
            return true
        case (.binding(let a), .binding(let b)):
            return a == b
        default:
            return false
        }
    }
}

public let usernamePasswordReducer = Reducer<
    UsernamePasswordState,
    UsernamePasswordAction,
    LoginEnvironment
> { state, action, environment in
    switch action {
    case .alertDismissed:
        state.alert = nil
        return .none
    case .binding(\.$username):
        state.canLogIn = !state.username.isEmpty && !state.password.isEmpty
        return .none
    case .binding(\.$password):
        state.canLogIn = !state.username.isEmpty && !state.password.isEmpty
        return .none
    case .binding:
        return .none
    case .loginButtonTapped:
        state.isRequestInFlight = true
        return environment
            .authenticationClient
            .login(LoginRequest(username: state.username, password: state.password))
            .receive(on: environment.mainQueue)
            .catchToEffect(UsernamePasswordAction.response)
    case .response(.success(.noSession)):
        assertionFailure("unexpected error??")
        return .none
    case .response(.failure(let error)):
        state.alert = .init(title: TextState(error.localizedDescription))
        state.isRequestInFlight = false
        return .none
    case .response:
        return .none
    }
}
.binding()

public struct UsernamePasswordView: View {
    @FocusState var focusedField: UsernamePasswordState.Field?

    let store: Store<UsernamePasswordState, UsernamePasswordAction>

    public init(
        store: Store<UsernamePasswordState, UsernamePasswordAction>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 16) {
                Text(
                    """
                    This application, which is unaffiliated with WaniKani, requires access to your WaniKani account.
                    """
                )

                TextField(
                    "Username or email",
                    text: viewStore.binding(\.$username)
                )
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .username)

                HStack {
                    if viewStore.showPasswordFieldText {
                        TextField(
                            "Password",
                            text: viewStore.binding(\.$password)
                        )
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .password)
                    } else {
                        SecureField(
                            "Password",
                            text: viewStore.binding(\.$password)
                        )
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .password)
                    }
                    Toggle(
                        isOn: viewStore.binding(\.$showPasswordFieldText)
                    ) {
                        Label("Show Password", systemImage: "eye")
                            .labelStyle(.iconOnly)
                    }
                    .toggleStyle(.button)
                }

                Button(
                    action: {
                        viewStore.send(.loginButtonTapped)
                    },
                    label: {
                        Text("Log In")

                        if viewStore.isRequestInFlight {
                            ProgressView()
                        }
                    }
                )
                .disabled(!viewStore.canLogIn)
            }
            .padding(.horizontal)
            .disabled(viewStore.isRequestInFlight)
            .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
            .synchronize(
                viewStore.binding(\.$focusedField),
                self.$focusedField
            )
        }
    }
}

struct UsernamePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UsernamePasswordView(
                store: Store(
                    initialState: .init(),
                    reducer: usernamePasswordReducer,
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
