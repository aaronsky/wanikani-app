import Security
import SwiftUI

enum AuthStore {
    enum State {
        case unknown
        case notAuthenticated
        case authenticated
    }

    enum KeychainError: Error {
        case noToken
        case unexpectedTokenData
        case unhandledError(status: OSStatus)
    }

    private static let server = "api.wanikani.com"

    static func load() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status != errSecItemNotFound else {
            throw KeychainError.noToken
        }

        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }

        guard let existingItem = item as? [String: Any],
              let tokenData = existingItem[kSecValueData as String] as? Data,
              let token = String(data: tokenData, encoding: .utf8) else {
                  throw KeychainError.unexpectedTokenData
              }

        return token
    }

    static func store(token: String) throws {
        let tokenData = token.data(using: .utf8)!
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecValueData as String: tokenData,
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)

        guard status != errSecDuplicateItem else {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassInternetPassword,
                kSecAttrServer as String: server
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: tokenData,
            ]

            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, attributes as CFDictionary)

            guard updateStatus == errSecSuccess else {
                throw KeychainError.unhandledError(status: status)
            }

            return
        }

        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    static func reset() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}
