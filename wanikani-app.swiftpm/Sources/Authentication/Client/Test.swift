import ComposableArchitecture
import WaniKaniHelpers

#if DEBUG
extension AuthenticationClient {
    public static let testing = Self(
        login: { _, _ in
            Effect(value: AuthenticationResponse(user: .testing))
        },
        logout: .none
    )
}
#endif
