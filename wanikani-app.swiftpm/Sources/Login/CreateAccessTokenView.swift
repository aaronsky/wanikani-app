import AuthenticationClient
import ComposableArchitecture
import SwiftUI

public struct CreateAccessTokenState: Equatable {
    var request: AccessTokenRequest

    @BindableState var permissionStartAssignments: Bool
    @BindableState var permissionCreateReviews: Bool
    @BindableState var permissionCreateStudyMaterials: Bool
    @BindableState var permissionUpdateStudyMaterials: Bool
    @BindableState var permissionUpdateUser: Bool

    var isRequestInFlight = false
    var alert: AlertState<CreateAccessTokenAction>?

    public init(
        request: AccessTokenRequest
    ) {
        self.request = request
        self.permissionStartAssignments = request.permissionStartAssignments
        self.permissionCreateReviews = request.permissionCreateReviews
        self.permissionCreateStudyMaterials = request.permissionCreateStudyMaterials
        self.permissionUpdateStudyMaterials = request.permissionUpdateStudyMaterials
        self.permissionUpdateUser = request.permissionUpdateUser
    }
}

public enum CreateAccessTokenAction: BindableAction, Equatable {
    case alertDismissed
    case binding(BindingAction<CreateAccessTokenState>)
    case createTokenButtonTapped
    case response(Result<AuthenticationAction, Error>)

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.alertDismissed, .alertDismissed),
            (.createTokenButtonTapped, .createTokenButtonTapped),
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

public let createAccessTokenReducer = Reducer<
    CreateAccessTokenState,
    CreateAccessTokenAction,
    LoginEnvironment
> { state, action, environment in
    switch action {
    case .alertDismissed:
        state.alert = nil
        return .none
    case .binding(\.$permissionStartAssignments):
        state.request.permissionStartAssignments = state.permissionStartAssignments
        return .none
    case .binding(\.$permissionCreateReviews):
        state.request.permissionCreateReviews = state.permissionCreateReviews
        return .none
    case .binding(\.$permissionCreateStudyMaterials):
        state.request.permissionCreateStudyMaterials = state.permissionCreateStudyMaterials
        return .none
    case .binding(\.$permissionUpdateStudyMaterials):
        state.request.permissionUpdateStudyMaterials = state.permissionUpdateStudyMaterials
        return .none
    case .binding(\.$permissionUpdateUser):
        state.request.permissionUpdateUser = state.permissionUpdateUser
        return .none
    case .binding:
        return .none
    case .createTokenButtonTapped:
        state.isRequestInFlight = true
        return environment
            .authenticationClient
            .createAccessToken(state.request)
            .receive(on: environment.mainQueue)
            .catchToEffect(CreateAccessTokenAction.response)
    case .response(.success(.noSession)), .response(.success(.needsAccessToken)):
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

public struct CreateAccessTokenView: View {
    let store: Store<CreateAccessTokenState, CreateAccessTokenAction>

    public init(store: Store<CreateAccessTokenState, CreateAccessTokenAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            Form {
                Text("Start Assignments")
                    .font(.caption)
                Section {
                    Toggle("Start Assignments", isOn: viewStore.binding(\.$permissionStartAssignments))
                }
                Section {
                    Button(
                        action: {
                            viewStore.send(.createTokenButtonTapped)
                        },
                        label: {
                            Text("Create Access Token")
                        }
                    )
                }
            }
            .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
        }
    }
}

struct CreateAccessTokenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateAccessTokenView(
                store: Store(
                    initialState: .init(request: .init(cookie: "", emailAddress: "")),
                    reducer: createAccessTokenReducer,
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
