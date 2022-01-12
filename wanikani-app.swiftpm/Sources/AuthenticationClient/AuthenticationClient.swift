import Combine
import ComposableArchitecture
import WaniKani

public struct AuthenticationClient {
    public var login: (LoginRequest) -> Effect<AuthenticationAction, Error>
    public var createAccessToken: (AccessTokenRequest) -> Effect<AuthenticationAction, Error>
    public var restoreSession: () -> Effect<AuthenticationAction, Error>
    public var logout: () -> Effect<Void, Error>

    public init(
        login: @escaping (LoginRequest) -> Effect<AuthenticationAction, Error>,
        createAccessToken: @escaping (AccessTokenRequest) -> Effect<AuthenticationAction, Error>,
        restoreSession: @escaping () -> Effect<AuthenticationAction, Error>,
        logout: @escaping () -> Effect<Void, Error>
    ) {
        self.login = login
        self.createAccessToken = createAccessToken
        self.restoreSession = restoreSession
        self.logout = logout
    }
}

public enum AuthenticationAction: Equatable {
    case noSession
    case needsAccessToken(AccessTokenRequest)
    case authenticated(AuthenticationResponse)
}

public struct LoginRequest: Equatable {
    public var username: String
    public var password: String
    public var storeInKeychainOnSuccess: Bool

    public init(
        username: String,
        password: String,
        storeInKeychainOnSuccess: Bool = true
    ) {
        self.username = username
        self.password = password
        self.storeInKeychainOnSuccess = storeInKeychainOnSuccess
    }
}

public struct AccessTokenRequest: Equatable {
    public var cookie: String
    public var emailAddress: String
    public var permissionStartAssignments: Bool
    public var permissionCreateReviews: Bool
    public var permissionCreateStudyMaterials: Bool
    public var permissionUpdateStudyMaterials: Bool
    public var permissionUpdateUser: Bool

    public init(
        cookie: String,
        emailAddress: String,
        permissionStartAssignments: Bool = false,
        permissionCreateReviews: Bool = false,
        permissionCreateStudyMaterials: Bool = false,
        permissionUpdateStudyMaterials: Bool = false,
        permissionUpdateUser: Bool = false
    ) {
        self.cookie = cookie
        self.emailAddress = emailAddress
        self.permissionStartAssignments = permissionStartAssignments
        self.permissionCreateReviews = permissionCreateReviews
        self.permissionCreateStudyMaterials = permissionCreateStudyMaterials
        self.permissionUpdateStudyMaterials = permissionUpdateStudyMaterials
        self.permissionUpdateUser = permissionUpdateUser
    }
}

public struct AuthenticationResponse: Equatable {
    public var cookie: String
    public var emailAddress: String
    public var accessToken: String

    public init(
        cookie: String,
        emailAddress: String,
        accessToken: String
    ) {
        self.cookie = cookie
        self.emailAddress = emailAddress
        self.accessToken = accessToken
    }
}

public enum AuthenticationError: Equatable, LocalizedError {
    case badCredentials
    case csrfTokenNotFound
    case accessTokenNotFound
    case emailNotFound
    case sessionCookieNotSet
    case invalidToken
    case unnavigableDocumentTree
    case serviceUnavailable
    case unhandledWaniKaniError(WaniKani.Error)
    case keychainError(Keychain.Error)

    init(
        _ error: WaniKani.Error
    ) {
        switch error.statusCode {
        case .unauthorized:
            self = .invalidToken
        case .internalServerError, .serviceUnavailable:
            self = .serviceUnavailable
        default:
            self = .unhandledWaniKaniError(error)
        }
    }

    public var errorDescription: String? {
        switch self {
        case .badCredentials:
            return "Unknown user credentials"
        case .csrfTokenNotFound:
            return "CSRF token not found"
        case .accessTokenNotFound:
            return "Access token not found"
        case .emailNotFound:
            return "Email address not found"
        case .sessionCookieNotSet:
            return "Session cookie not set"
        case .invalidToken:
            return "Unknown user access token"
        case .unnavigableDocumentTree:
            return "Unable to authenticate with WaniKani due to a schema change"
        case .serviceUnavailable:
            return "WaniKani is currently unavailable"
        case .unhandledWaniKaniError(let error):
            return "Unexpected WaniKani error – Code \(error.statusCode.rawValue)"
        case .keychainError:
            return nil
        }
    }
}
