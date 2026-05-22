//
//  UserRepository.swift
//  Arista
//
//  Created by Mathieu ARRIO on 10/03/2026.
//

import Foundation
import CoreData
import CryptoKit

extension User {
    /// Hashes a plain password using SHA256 and saves the hashed value.
    func setHashedPassword(_ plainText: String) {
        guard let data = plainText.data(using: .utf8) else { return }
        let hash = SHA256.hash(data: data)
        self.password = hash.map { String(format: "%02x", $0) }.joined()
    }

    /// Safe access to the firstName.
    var wrappedFirstName: String {
        firstName ?? ""
    }
    
    /// Safe access to the lastName.
    var wrappedLastName: String {
        lastName ?? ""
    }
    
    /// Safe access to the email.
    var wrappedEmail: String {
        email ?? ""
    }
    
    /// Safe access to the password.
    var wrappedPassword: String {
        password ?? ""
    }
}

struct UserRepository {
    let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    /// Get only the first user
    /// - Returns: user fetched
    func getUser() throws -> User? {
        let request = User.fetchRequest()
        request.fetchLimit = 1
        return try viewContext.fetch(request).first
    }
}
