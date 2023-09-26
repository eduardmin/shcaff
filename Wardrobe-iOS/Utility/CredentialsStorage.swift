//
//  CredentialsStorage.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/1/20.
//

import UIKit
import KeychainSwift

enum CredentialKey: String {
    case authToken = "authToken"
    case password = "password"
}

class CredentialsStorage {
   static private let keychain = KeychainSwift()

    class func credentialWithKey(_ key: CredentialKey) -> String? {
        return keychain.get(key.rawValue)
    }
    
    class func setCredentialWithKey(_ credential: String, withKey key: CredentialKey) {
        keychain.set(credential, forKey: key.rawValue)
    }
    
    class func removeCredentialWithKey(_ key: CredentialKey) {
        keychain.delete(key.rawValue)
    }
    
    class func clearAll() {
        removeCredentialWithKey(.authToken)
        removeCredentialWithKey(.password)
    }
}
