//
//  UserDataViewModelTests.swift
//  AristaTests
//
//  Created by Mathieu ARRIO on 14/03/2026.
//

import XCTest
import CoreData
@testable import Arista

// MARK: - Fakes

/// Throws on getUser() — triggers the catch path.
private final class FailingUserRepository: UserRepositoryProtocol {
    func getUser() throws -> User? { throw AristaError.fetchFailed }
}

/// Returns nil — the if let branch is skipped, properties stay at default values.
private final class EmptyUserRepository: UserRepositoryProtocol {
    func getUser() throws -> User? { return nil }
}

// MARK: - Tests

@MainActor
final class UserDataViewModelTests: XCTestCase {

    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!

    override func setUp() async throws {
        try await super.setUp()
        persistenceController = makeTestPersistenceController()
        context = persistenceController.container.viewContext
    }

    override func tearDown() async throws {
        context = nil
        persistenceController = nil
        try await super.tearDown()
    }

    // MARK: - Error path

    func test_WhenRepositoryThrows_FetchUserData_SetsHasError() async throws {
        // Arrange
        let viewModel = UserDataViewModel(context: context, repository: FailingUserRepository())

        // Act : Nous devons maintenant appeler la méthode explicitement
        await viewModel.fetchUserData()

        // Assert
        XCTAssertTrue(viewModel.hasError)
        XCTAssertEqual(viewModel.errorMessage, AristaError.fetchFailed.localizedDescription)
        XCTAssertEqual(viewModel.firstName, "")
        XCTAssertEqual(viewModel.lastName, "")
        XCTAssertEqual(viewModel.email, "")
        XCTAssertEqual(viewModel.password, "")
    }

    // MARK: - Nil user path (no error, properties stay empty)

    func test_WhenNoUserExists_FetchUserData_PropertiesStayEmpty() async throws {
        // Arrange
        let viewModel = UserDataViewModel(context: context, repository: EmptyUserRepository())

        // Act
        await viewModel.fetchUserData()

        // Assert
        XCTAssertFalse(viewModel.hasError)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.firstName, "")
        XCTAssertEqual(viewModel.lastName, "")
    }

    // MARK: - Nominal path

    func test_WhenUserExists_FetchUserData_PopulatesProperties() async throws {
        // Arrange : Add a real user to the in-memory store
        let user = User(context: context)
        user.firstName = "Charlotte"
        user.lastName = "Razoul"
        user.email = "charlotte.razoul@example.com"
        user.password = "password1234"
        user.id = UUID()
        try context.save()

        let viewModel = UserDataViewModel(context: context)

        // Act
        await viewModel.fetchUserData()

        // Assert
        XCTAssertFalse(viewModel.hasError)
        XCTAssertEqual(viewModel.firstName, "Charlotte")
        XCTAssertEqual(viewModel.lastName, "Razoul")
        XCTAssertEqual(viewModel.email, "charlotte.razoul@example.com")
        XCTAssertEqual(viewModel.password, "password1234")
    }
}
