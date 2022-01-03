import SwiftUI
import WaniKani

@MainActor
class Services: ObservableObject {
    let session: URLSession
    let client: WaniKani

    private var operationsToRunInBackgroundOnceAuthenticated: [() async -> ()] = []

    @Published var user: User?
    @Published var authState: AuthStore.State = .unknown

    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
        self.client = WaniKani(transport: session)

        attemptToAuthenticate()
    }

    func send<R: Resource>(_ resource: R, pageOptions: PageOptions? = nil) async throws -> Response<R> where R.Content: Decodable {
        try await client.send(resource, pageOptions: pageOptions)
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }

    func attemptToAuthenticate() {
        Task {
            do {
                let token = try AuthStore.load()
                try await login(token, storeInKeychainOnSuccess: false)
                authState = .authenticated
            } catch {
                authState = .notAuthenticated
            }
        }
    }

    func login(_ token: String, storeInKeychainOnSuccess: Bool = true) async throws {
        let oldValue = client.token
        client.token = token

        do {
            let response = try await client.send(.me)
            user = response.data

            if storeInKeychainOnSuccess {
                try AuthStore.store(token: token)
            }

            authState = .authenticated
        } catch let error as WaniKani.Error {
            client.token = oldValue
            throw AuthenticationError(statusCode: error.statusCode) ?? error
        } catch {
            client.token = oldValue
            throw error
        }
    }

    func logout() throws {
        try AuthStore.reset()
        authState = .notAuthenticated
    }

    enum AuthenticationError: CategorizedError {
        case loginFailed
        case serviceUnavailable

        var category: ErrorCategory {
            .nonRetryable
        }

        init?(statusCode: StatusCode) {
            switch statusCode {
            case .unauthorized:
                self = .loginFailed
            case .internalServerError, .serviceUnavailable:
                self = .serviceUnavailable
            default:
                return nil
            }
        }
    }
}
