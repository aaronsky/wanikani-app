import Combine
import ComposableArchitecture
import WaniKani
import WaniKaniComposableClient

public struct LoginRequest {
    public var token: String?
    public var storeValidTokenInKeychain: Bool

    public init(
        token: String?,
        storeValidTokenInKeychain: Bool = true
    ) {
        self.token = token
        self.storeValidTokenInKeychain = storeValidTokenInKeychain
    }
}

public struct AuthenticationResponse: Equatable {
    public var user: User

    public init(
        user: User
    ) {
        self.user = user
    }
}

public enum AuthenticationError: Equatable, LocalizedError {
    case invalidToken
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
        case .invalidToken:
            return "Unknown user access token"
        case .serviceUnavailable:
            return "WaniKani is currently unavailable"
        case .unhandledWaniKaniError(let error):
            return "Unexpected WaniKani error – Code \(error.statusCode.rawValue)"
        case .keychainError:
            return nil
        }
    }
}

public struct AuthenticationClient {
    public var login: (LoginRequest, WaniKaniComposableClient) -> Effect<AuthenticationResponse, Error>
    public var logout: Effect<Void, Error>

    public init(
        login: @escaping (LoginRequest, WaniKaniComposableClient) -> Effect<AuthenticationResponse, Error>,
        logout: Effect<Void, Error>
    ) {
        self.login = login
        self.logout = logout
    }
}
