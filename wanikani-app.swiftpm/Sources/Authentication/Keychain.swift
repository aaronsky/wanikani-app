import Foundation
import Security
import WaniKani

public enum Keychain {
    public enum Error: Swift.Error, Equatable {
        case noToken
        case unexpectedTokenData
        case unhandledError(status: OSStatus)
    }

    private static let domain = "api.wanikani.com"

    static func copyFirstTokenInDomain() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword, kSecAttrServer as String: domain,
            kSecMatchLimit as String: kSecMatchLimitOne, kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status != errSecItemNotFound else {
            throw Error.noToken
        }

        guard status == errSecSuccess else {
            throw Error.unhandledError(status: status)
        }

        guard let existingItem = item as? [String: Any],
            let data = existingItem[kSecValueData as String] as? Data,
            let token = String(data: data, encoding: .utf8)
        else {
            throw Error.unexpectedTokenData
        }

        return token
    }

    static func add(_ token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw Error.noToken
        }

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword, kSecAttrServer as String: domain,
            kSecValueData as String: data,
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            return try update(token)
        default:
            throw Error.unhandledError(status: status)
        }
    }

    static func update(_ token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw Error.noToken
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword, kSecAttrServer as String: domain,
        ]
        let attributes: [String: Any] = [kSecValueData as String: data]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        guard status == errSecSuccess else {
            throw Error.unhandledError(status: status)
        }
    }

    static func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword, kSecAttrServer as String: domain,
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw Error.unhandledError(status: status)
        }
    }
}
