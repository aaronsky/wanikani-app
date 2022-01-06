import ComposableArchitecture
import WaniKaniHelpers

extension AuthenticationClient {
    public static let testing = Self(
        login: { _, _ in
            Effect(value: AuthenticationResponse(user: .testing))
        },
        logout: .none
    )
}
