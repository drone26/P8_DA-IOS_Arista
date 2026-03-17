//
//  UserDataViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//  Modified by Mathieu Arrio on 05/03/2026.
//

import Foundation
import CoreData

@MainActor
@Observable
class UserDataViewModel {
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var password: String = ""
    var errorMessage: String?
    var hasError: Bool = false

    let viewContext: NSManagedObjectContext
    private let repository: any UserRepositoryProtocol

    init(context: NSManagedObjectContext, repository: (any UserRepositoryProtocol)? = nil) {
        self.viewContext = context
        self.repository = repository ?? UserRepository(viewContext: context)
    }
    
    /// Fetch User data / information
    func fetchUserData() async {
        do {
            if let user = try repository.getUser() {
                self.firstName = user.wrappedFirstName
                self.lastName = user.wrappedLastName
                self.email = user.wrappedEmail
                self.password = user.wrappedPassword
            }
        } catch {
            self.errorMessage = AristaError.fetchFailed.localizedDescription
            self.hasError = true
        }
    }
}
