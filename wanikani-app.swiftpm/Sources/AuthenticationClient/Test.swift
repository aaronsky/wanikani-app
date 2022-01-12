import ComposableArchitecture

#if DEBUG
extension AuthenticationClient {
    public static let testing = Self(
        login: { _ in .none },
        createAccessToken: { _ in .none },
        restoreSession: { .none },
        logout: { .none }
    )
}
#endif
