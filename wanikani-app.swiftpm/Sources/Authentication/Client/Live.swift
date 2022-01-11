import Combine
import ComposableArchitecture
import WaniKaniHelpers

extension AuthenticationClient {
    public static let live: AuthenticationClient = .init(
        login: performLogin,
        logout: .catching(Keychain.deleteAll)
    )
}

private func performLogin(
    request: LoginRequest,
    wanikaniClient: WaniKaniComposableClient
) -> Effect<AuthenticationResponse, Error> {
    Future<String, Error> { promise in
        if let token = request.token {
            return promise(.success(token))
        }
        do {
            let token = try Keychain.copyFirstTokenInDomain()
            return promise(.success(token))
        } catch {
            return promise(.failure(error))
        }
    }
    .flatMap { token in
        wanikaniClient.authorize(token)
            .tryMap { user -> AuthenticationResponse in
                if request.storeValidTokenInKeychain {
                    try Keychain.add(token)
                }
                return AuthenticationResponse(user: user)
            }
    }
    .mapError { error -> Error in
        if let error = error as? WaniKani.Error {
            return AuthenticationError(error)
        } else if let error = error as? Keychain.Error {
            return AuthenticationError.keychainError(error)
        } else {
            return error
        }
    }
    .eraseToEffect()
}
