//
//  KeychainManager.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 7/11/25.
//

import Foundation
import Security

final class KeychainManager {
    static let instance = KeychainManager()
    private init() {}
    
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
        case noData
        case unexpectedData
    }
    
    func saveToken(_ token: String, forKey key: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw KeychainError.unexpectedData
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        // Try to update existing item first
        let updateAttributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let updateStatus = SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)
        
        if updateStatus == errSecItemNotFound {
            // Item doesn't exist, add new one
            let addQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
            ]
            
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainError.unknown(addStatus)
            }
        } else if updateStatus != errSecSuccess {
            throw KeychainError.unknown(updateStatus)
        }
    }
    
    func getToken(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }

        return nil
    }
    
    func deleteToken(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }
}
