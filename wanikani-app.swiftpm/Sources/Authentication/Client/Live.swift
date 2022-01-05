import ComposableArchitecture
import WaniKani

extension AuthenticationClient {
    public static let live = Self(
        login: Self.login,
        logout: .catching(Keychain.deleteAll)
    )

    private static func login(
        request: LoginRequest,
        wanikaniClient: WaniKani
    ) -> Effect<AuthenticationResponse, Error> {
        Effect.task {
            let oldValue = wanikaniClient.token

            do {
                let token = try request.token ?? Keychain.copyFirstTokenInDomain()
                wanikaniClient.token = token

                let response = try await wanikaniClient.send(.me)
                let user = response.data

                if request.storeValidTokenInKeychain {
                    try Keychain.add(token)
                }

                return AuthenticationResponse(user: user)
            } catch let error as WaniKani.Error {
                wanikaniClient.token = oldValue

                throw AuthenticationError(error)
            } catch let error as Keychain.Error {
                wanikaniClient.token = oldValue

                throw AuthenticationError.keychainError(error)
            } catch {
                throw error
            }
        }
    }
}
