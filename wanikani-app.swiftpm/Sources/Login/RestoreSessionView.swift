import Authentication
import ComposableArchitecture
import Home
import SwiftUI
import WaniKaniHelpers

public struct RestoreSessionState: Equatable {
    public init() {}
}

public enum RestoreSessionAction: Equatable {
    case onAppear
    case restoreSession(Result<AuthenticationResponse, Error>)

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.onAppear, .onAppear),
            (.restoreSession(.success), .restoreSession(.success)),
            (.restoreSession(.failure), .restoreSession(.failure)):
            return true
        default:
            return false
        }
    }
}

public struct RestoreSessionEnvironment {
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

public let restoreSessionReducer = Reducer<RestoreSessionState, RestoreSessionAction, RestoreSessionEnvironment> {
    _,
    action,
    environment in
    switch action {
    case .onAppear:
        return environment.authenticationClient
            .login(
                LoginRequest(token: nil, storeValidTokenInKeychain: false),
                environment.wanikaniClient
            )
            .receive(on: environment.mainQueue)
            .catchToEffect(RestoreSessionAction.restoreSession)
    case .restoreSession:
        return .none
    }
}

public struct RestoreSessionView: View {
    let store: Store<RestoreSessionState, RestoreSessionAction>

    public init(
        store: Store<RestoreSessionState, RestoreSessionAction>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ProgressView()
                .onAppear {
                    viewStore.send(.onAppear)
                }
        }
    }
}

struct RestoreSessionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RestoreSessionView(
                store: Store(
                    initialState: .init(),
                    reducer: restoreSessionReducer,
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
