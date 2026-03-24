//
//  UserRepository.swift
//  Arista
//
//  Created by Mathieu ARRIO on 10/03/2026.
//

import Foundation
import CoreData

extension User {
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
