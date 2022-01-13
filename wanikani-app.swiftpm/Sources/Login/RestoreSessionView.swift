import AuthenticationClient
import ComposableArchitecture
import SwiftUI

public struct RestoreSessionState: Equatable {
    public init() {}
}

public enum RestoreSessionAction: Equatable {
    case onAppear
    case response(Result<AuthenticationAction, Error>)

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.onAppear, .onAppear),
            (.response(.success), .response(.success)),
            (.response(.failure), .response(.failure)):
            return true
        default:
            return false
        }
    }
}

public let restoreSessionReducer = Reducer<
    RestoreSessionState,
    RestoreSessionAction,
    LoginEnvironment
> { state, action, environment in
    switch action {
    case .onAppear:
        return environment
            .authenticationClient
            .restoreSession()
            .receive(on: environment.mainQueue)
            .catchToEffect(RestoreSessionAction.response)
    case .response:
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
