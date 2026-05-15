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
    
    /// Fetch User data / information from the repository and update view properties.
    func fetchUserData() async {
        // Reset state before fetching
        self.errorMessage = nil
        self.hasError = false

        do {
            if let user = try repository.getUser() {
                updateProperties(with: user)
            } else {
                clearProperties()
            }
        } catch {
            self.errorMessage = AristaError.fetchFailed.localizedDescription
            self.hasError = true
        }
    }

    /// Updates view properties with user data.
    private func updateProperties(with user: User) {
        self.firstName = user.wrappedFirstName
        self.lastName = user.wrappedLastName
        self.email = user.wrappedEmail
        self.password = user.wrappedPassword
    }

    /// Resets all view properties to their default empty values.
    private func clearProperties() {
        self.firstName = ""
        self.lastName = ""
        self.email = ""
        self.password = ""
    }
}
