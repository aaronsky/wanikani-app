import ComposableArchitecture
import Foundation
import HTML

extension AuthenticationClient {
    public static let live: AuthenticationClient = .init(
        login: { req in
            .task {
                try await Self.login(request: req)
            }
        },
        createAccessToken: { req in
            .task {
                try await Self.createAccessToken(request: req)
            }
        },
        restoreSession: {
            .task {
                try await Self.restoreSession()
            }
        },
        logout: {
            .catching {
                try Self.logout()
            }
        }
    )

    private static func login(request: LoginRequest) async throws -> AuthenticationAction {
        let cookie = try await getLoginCookie(username: request.username, password: request.password)

        if request.storeInKeychainOnSuccess {
            try Keychain.add(account: request.username, credential: request.password)
        }

        let (emailAddress, accessToken) = try await (getEmailAddress(cookie: cookie), getAccessToken(cookie: cookie))

        guard let accessToken = accessToken else {
            return .needsAccessToken(AccessTokenRequest(cookie: cookie, emailAddress: emailAddress))
        }

        return .authenticated(
            AuthenticationResponse(cookie: cookie, emailAddress: emailAddress, accessToken: accessToken)
        )
    }

    private static func createAccessToken(request: AccessTokenRequest) async throws -> AuthenticationAction {
        let accessToken = try await createNewAccessToken(request: request)

        return .authenticated(
            AuthenticationResponse(cookie: request.cookie, emailAddress: request.emailAddress, accessToken: accessToken)
        )
    }

    private static func restoreSession() async throws -> AuthenticationAction {
        let (username, password) = try Keychain.copyFirstCredentialInDomain()

        return try await login(
            request: LoginRequest(username: username, password: password, storeInKeychainOnSuccess: false)
        )
    }

    private static func logout() throws {
        try Keychain.deleteAll()
    }

    private static func getLoginCookie(username: String, password: String) async throws -> String {
        let session = URLSession(configuration: .ephemeral)

        let firstCookie: String
        let secondCookie: String

        var req = URLRequest(url: loginURL)
        req.httpShouldHandleCookies = true

        let (data, _) = try await session.data(for: req)

        guard let doc = try? html(data: data, encoding: .utf8),
            let csrfToken = try? doc.csrfToken
        else {
            throw AuthenticationError.csrfTokenNotFound
        }

        firstCookie = try session.wanikaniSessionCookie

        req = URLRequest(url: loginURL)
        req.httpShouldHandleCookies = true
        req.setFormBody(
            method: "POST",
            queryItems: [
                URLQueryItem(name: "user[login]", value: username),
                URLQueryItem(name: "user[password]", value: password),
                URLQueryItem(name: "user[remember_me]", value: "0"),
                URLQueryItem(name: "authenticity_token", value: csrfToken),
                URLQueryItem(name: "utf8", value: "✓"),
            ]
        )

        let (_, response) = try await session.data(for: req)
        secondCookie = try session.wanikaniSessionCookie

        guard firstCookie != secondCookie && response.url == dashboardURL else {
            throw AuthenticationError.badCredentials
        }

        return secondCookie
    }

    private static func getEmailAddress(cookie: String) async throws -> String {
        var req = URLRequest(url: accountSettingsURL)
        req.authorize(cookie)

        let (data, _) = try await URLSession.shared.data(for: req)

        guard let doc = try? html(data: data, encoding: .utf8),
            let emailAddress = try? doc.emailAddress
        else {
            throw AuthenticationError.emailNotFound
        }

        return emailAddress
    }

    private static func getAccessToken(cookie: String) async throws -> String? {
        var req = URLRequest(url: accessTokenSettingsURL)
        req.authorize(cookie)

        let (data, _) = try await URLSession.shared.data(for: req)

        guard let doc = try? html(data: data, encoding: .utf8),
            let accessToken = try? doc.accessToken(for: appName)
        else {
            throw AuthenticationError.accessTokenNotFound
        }

        return accessToken
    }

    private static func createNewAccessToken(request: AccessTokenRequest) async throws -> String {
        var req = URLRequest(url: accessTokenSettingsURL)
        req.authorize(request.cookie)

        var (data, _) = try await URLSession.shared.data(for: req)

        guard let doc = try? html(data: data, encoding: .utf8),
            let csrfToken = try? doc.csrfToken
        else {
            throw AuthenticationError.csrfTokenNotFound
        }

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "personal_access_token[description]", value: appName),
            URLQueryItem(name: "authenticity_token", value: csrfToken),
            URLQueryItem(name: "utf8", value: "✓"),
        ]

        if request.permissionStartAssignments {
            queryItems.append(URLQueryItem(name: "personal_access_token[permissions][assignments][start]", value: "1"))
        }
        if request.permissionCreateReviews {
            queryItems.append(URLQueryItem(name: "personal_access_token[permissions][reviews][create]", value: "1"))
        }
        if request.permissionCreateStudyMaterials {
            queryItems.append(
                URLQueryItem(name: "personal_access_token[permissions][study_materials][create]", value: "1")
            )
        }
        if request.permissionUpdateStudyMaterials {
            queryItems.append(
                URLQueryItem(name: "personal_access_token[permissions][study_materials][update]", value: "1")
            )
        }
        if request.permissionUpdateUser {
            queryItems.append(URLQueryItem(name: "personal_access_token[permissions][user][update]", value: "1"))
        }

        req = URLRequest(url: accessTokenSettingsURL)
        req.authorize(request.cookie)
        req.setFormBody(method: "POST", queryItems: queryItems)

        (data, _) = try await URLSession.shared.data(for: req)

        guard let doc = try? html(data: data, encoding: .utf8),
            let accessToken = try? doc.accessToken(for: appName)
        else {
            throw AuthenticationError.accessTokenNotFound
        }

        return accessToken
    }
}

// MARK: - Constants

private let appName = "wanikani-ios"
private let loginURL = URL(string: "https://www.wanikani.com/login")!
private let dashboardURL = URL(string: "https://www.wanikani.com/dashboard")!
private let accountSettingsURL = URL(string: "https://www.wanikani.com/settings/account")!
private let accessTokenSettingsURL = URL(string: "https://www.wanikani.com/settings/personal_access_tokens")!
private let wanikaniSessionCookieName = "_wanikani_session"

// MARK: - Extensions

extension CharacterSet {
    static let rfc3986Unreserved = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
    )
}

extension URLRequest {
    mutating func authorize(_ cookie: String) {
        addValue("\(wanikaniSessionCookieName)=\(cookie)", forHTTPHeaderField: "Cookie")
    }

    mutating func setFormBody(method: String, queryItems: [URLQueryItem] = []) {
        httpMethod = method

        httpBody =
            queryItems
            .compactMap { item in
                guard let name = item.name.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved),
                    let value = item.value?.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)
                else {
                    return nil
                }

                return "\(name)=\(value)"
            }
            .joined(separator: "&")
            .data(using: .utf8)

        if let count = httpBody?.count {
            setValue(String(count), forHTTPHeaderField: "Content-Length")
        }

        setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    }
}

extension URLSession {
    var wanikaniSessionCookie: String {
        get throws {
            guard let cookies = configuration.httpCookieStorage?.cookies,
                  let cookie = cookies.first(where: { $0.name == wanikaniSessionCookieName })
            else {
                throw AuthenticationError.sessionCookieNotSet
            }

            return cookie.value
        }
    }
}
