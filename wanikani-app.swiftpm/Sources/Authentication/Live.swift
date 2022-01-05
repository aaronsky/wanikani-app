import ComposableArchitecture
import WaniKani

extension AuthenticationClient {
    public static let live = Self(login: Self.login, logout: Self.logout)

    private static func login(
        request: LoginRequest,
        wanikani: WaniKani
    ) -> Effect<AuthenticationResponse, Error> {
        Effect.task {
            let oldValue = wanikani.token

            do {
                let token = try request.token ?? Keychain.copyFirstTokenInDomain()
                wanikani.token = token

                let response = try await wanikani.send(.me)
                let user = response.data

                if request.storeValidTokenInKeychain {
                    try Keychain.add(token)
                }

                return AuthenticationResponse(user: user)
            } catch let error as WaniKani.Error {
                wanikani.token = oldValue

                throw AuthenticationError(error)
            } catch let error as Keychain.Error {
                wanikani.token = oldValue

                throw AuthenticationError.keychainError(error)
            } catch {
                throw error
            }
        }
    }

    private static func logout() -> Effect<Void, Error> {
        do {
            try Keychain.deleteAll()
            return Effect(value: ())
        } catch {
            return Effect(error: error)
        }
    }
}
