import ComposableArchitecture
import Foundation

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
        let csrfToken = HTML(data: data)!.csrfToken!  // FIXME: extract BUT NOT WITH REGEX
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

        if firstCookie == secondCookie {
            throw AuthenticationError.badCredentials
        } else if response.url != dashboardURL {
            throw AuthenticationError.unnavigableDocumentTree
        }

        return secondCookie
    }

    private static func getEmailAddress(cookie: String) async throws -> String {
        var req = URLRequest(url: accountSettingsURL)
        req.authorize(cookie)

        let (data, _) = try await URLSession.shared.data(for: req)

        return HTML(data: data)!.emailAddress!  // FIXME: extract BUT NOT WITH REGEX
    }

    private static func getAccessToken(cookie: String) async throws -> String? {
        var req = URLRequest(url: accessTokenSettingsURL)
        req.authorize(cookie)

        let (data, _) = try await URLSession.shared.data(for: req)

        return HTML(data: data)?.accessToken  // FIXME: extract BUT NOT WITH REGEX
    }

    private static func createNewAccessToken(request: AccessTokenRequest) async throws -> String {
        var req = URLRequest(url: accessTokenSettingsURL)
        req.authorize(request.cookie)

        var (data, _) = try await URLSession.shared.data(for: req)
        let csrfToken = HTML(data: data)!.csrfToken  // FIXME: extract BUT NOT WITH REGEX

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

        guard let accessToken = HTML(data: data)?.accessToken else {  // FIXME: extract BUT NOT WITH REGEX
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
    fileprivate static let rfc3986Unreserved = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
    )
}

extension URLRequest {
    fileprivate mutating func authorize(_ cookie: String) {
        addValue("\(wanikaniSessionCookieName)=\(cookie)", forHTTPHeaderField: "Cookie")
    }

    fileprivate mutating func setFormBody(method: String, queryItems: [URLQueryItem] = []) {
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
    fileprivate var wanikaniSessionCookie: String {
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

// FIXME: Do not parse HTML with Regex, you'll welcome Zalgo into your home
private struct HTML {
    private static let csrfTokenPattern = try! NSRegularExpression(
        pattern: #"<meta name="csrf-token" content="([^"]*)"#
    )
    private static let accessTokenPattern = try! NSRegularExpression(
        pattern:
            #"personal-access-token-description">\s*\#(appName)\s*</td>\s*<td class="personal-access-token-token">\s*<code>([a-f0-9-]{36})</code>"#
    )
    private static let emailAddressPattern = try! NSRegularExpression(
        pattern: #"<input[^>]+value="([^"]+)"[^>]+id="user_email""#
    )

    private var string: String

    var csrfToken: String? {
        firstMatch(pattern: Self.csrfTokenPattern)
    }

    var accessToken: String? {
        firstMatch(pattern: Self.accessTokenPattern)
    }

    var emailAddress: String? {
        firstMatch(pattern: Self.emailAddressPattern)
    }

    init?(
        data: Data
    ) {
        guard let string = String(data: data, encoding: .utf8) else {
            return nil
        }

        self.string = string
    }

    private func firstMatch(pattern: NSRegularExpression) -> String? {
        guard
            let match = pattern.firstMatch(
                in: string,
                range: NSRange(
                    string.startIndex...,
                    in: string
                )
            ),
            let range = Range(match.range(at: 1), in: string)
        else {
            return nil
        }

        return String(string[range])
    }
}
