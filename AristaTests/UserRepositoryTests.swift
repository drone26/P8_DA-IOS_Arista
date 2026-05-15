//
//  UserRepositoryTests.swift
//  AristaTests
//
//  Created by Mathieu ARRIO on 11/03/2026.
//

import XCTest
import CoreData
@testable import Arista

final class UserRepositoryTests: XCTestCase {
    var persistenceController: PersistenceController!
    var userRepository: UserRepository!
    
    private func emptyEntities(context: NSManagedObjectContext) {
        let fetchRequest = User.fetchRequest()
        let objects = try! context.fetch(fetchRequest)
        
        for user in objects {
            context.delete(user)
        }
        try! context.save()
    }
    
    private func addUser(context: NSManagedObjectContext, userFirstName: String, userLastName: String, userEmail: String) -> User {
        let newUser = User(context: context)
        newUser.firstName = userFirstName
        newUser.lastName = userLastName
        newUser.email = userEmail
        newUser.id = UUID()
        try! context.save()
        return newUser
    }
    
    func test_WhenNoUserIsInDatabase_GetUser_ReturnEmptyList() {
        // Given
        persistenceController = makeTestPersistenceController()
        emptyEntities(context: persistenceController.container.viewContext)
        
        let userRepository = UserRepository(viewContext: persistenceController.container.viewContext)
        
        // When / Then
        do {
            let user = try userRepository.getUser()
            XCTAssertNil(user, "The result should be nil when no user exists in the database.")
        } catch {
            XCTFail("Fetching user failed with error: \(error)")
        }
    }
    
    func test_WhenAddingOneUserInDatabase_GetUser_ReturnAListContainingTheUser() {
        // Given
        persistenceController = makeTestPersistenceController()
        emptyEntities(context: persistenceController.container.viewContext)
        
        let userRepository = UserRepository(viewContext: persistenceController.container.viewContext)
        
        // When / Then
        do {
            _ = addUser(context: persistenceController.container.viewContext, userFirstName: "Eric", userLastName: "Marcus", userEmail: "eric.marcus@example.com")
            let user = try userRepository.getUser()
            XCTAssert(user?.email == "eric.marcus@example.com")
            XCTAssert(user?.firstName == "Eric")
            XCTAssert(user?.lastName == "Marcus")
        } catch {
            XCTFail("Fetching user failed with error: \(error)")
        }
    }
    
    func test_UserWrappedProperties_WhenValuesAreNotDefined() {
        // Given
        persistenceController = makeTestPersistenceController()
        emptyEntities(context: persistenceController.container.viewContext)
        
        // When
        let user = User(context: persistenceController.container.viewContext)
        user.id = UUID()
        
        // Then
        XCTAssertEqual(user.wrappedFirstName, "", "Should return empty string when firstName is nil")
        XCTAssertEqual(user.wrappedLastName, "", "Should return empty string when lastName is nil")
        XCTAssertEqual(user.wrappedEmail, "", "Should return empty string when email is nil")
    }
}
