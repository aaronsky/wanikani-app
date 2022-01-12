import Foundation
import Security

public enum Keychain {
    public enum Error: Swift.Error, Equatable {
        case noCredential
        case unexpectedCredentialData
        case unhandledError(status: OSStatus)
    }

    private static let domain = "api.wanikani.com"

    static func copyFirstCredentialInDomain() throws -> (account: String, password: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: domain,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status != errSecItemNotFound else {
            throw Error.noCredential
        }

        guard status == errSecSuccess else {
            throw Error.unhandledError(status: status)
        }

        guard let existingItem = item as? [String: Any],
            let data = existingItem[kSecValueData as String] as? Data,
            let password = String(data: data, encoding: .utf8),
            let account = existingItem[kSecAttrAccount as String] as? String
        else {
            throw Error.unexpectedCredentialData
        }

        if account.isEmpty || password.isEmpty {
            throw Error.unexpectedCredentialData
        }

        return (account, password)
    }

    static func add(account: String, credential: String) throws {
        guard let data = credential.data(using: .utf8) else {
            throw Error.noCredential
        }

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: domain,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            return try update(account: account, credential: credential)
        default:
            throw Error.unhandledError(status: status)
        }
    }

    static func update(account: String, credential: String) throws {
        guard let data = credential.data(using: .utf8) else {
            throw Error.noCredential
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: domain,
            kSecAttrAccount as String: account,
        ]
        let attributes: [String: Any] = [kSecValueData as String: data]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        guard status == errSecSuccess else {
            throw Error.unhandledError(status: status)
        }
    }

    static func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: domain,
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw Error.unhandledError(status: status)
        }
    }
}
