//
//  ViewModelErrorTests.swift
//  AristaTests
//
//  Created by Mathieu ARRIO on 14/03/2026.
//

import XCTest
import CoreData
@testable import Arista

// MARK: - Fake repositories

/// Throws on every call — covers fetchFailed paths.
final class FailingExerciseRepository: ExerciseRepositoryProtocol {
    func getExercises() throws -> [Exercise] { throw AristaError.fetchFailed }
    func addExercise(category: String, duration: Int, intensity: Int, startDate: Date, user: User) throws { throw AristaError.saveFailed }
    func deleteExercise(_ exercise: Exercise) throws { throw AristaError.saveFailed }
    func deleteExercises(_ exercises: [Exercise]) throws { throw AristaError.saveFailed }
}

final class FailingSleepRepository: SleepRepositoryProtocol {
    func getSleepSessions() throws -> [Sleep] { throw AristaError.fetchFailed }
}

/// Returns nil for getUser() — triggers the guard path in AddExerciseViewModel.
private final class EmptyUserRepository: UserRepositoryProtocol {
    func getUser() throws -> User? { return nil }
}

/// Throws on getUser() — triggers the catch path in AddExerciseViewModel.
private final class FailingUserRepository: UserRepositoryProtocol {
    func getUser() throws -> User? { throw AristaError.fetchFailed }
}

/// Returns a real user but lets the exercise repository fail on save.
private final class SucceedingUserRepository: UserRepositoryProtocol {
    let user: User
    init(user: User) { self.user = user }
    func getUser() throws -> User? { return user }
}

// MARK: - Tests

/// A single NSManagedObjectModel shared across all tests.
/// Loading the model multiple times causes "Failed to find a unique match
/// for an NSEntityDescription" because Core Data maps entities to Swift
/// classes globally — duplicate models break that mapping.
private let sharedTestModel: NSManagedObjectModel = {
    let url = Bundle.main.url(forResource: "Arista", withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: url)!
}()

/// Creates an in-memory PersistenceController backed by the shared model.
/// Use this in every test instead of PersistenceController(inMemory: true).
func makeTestPersistenceController() -> PersistenceController {
    let container = NSPersistentContainer(name: "Arista", managedObjectModel: sharedTestModel)
    let description = NSPersistentStoreDescription()
    description.url = URL(fileURLWithPath: "/dev/null")
    description.type = NSInMemoryStoreType
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { _, error in
        if let error { fatalError("Failed to load test store: \(error)") }
    }
    container.viewContext.automaticallyMergesChangesFromParent = true
    return PersistenceController(container: container)
}

@MainActor
final class ViewModelErrorTests: XCTestCase {
    
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
    
    // MARK: - ExerciseListViewModel
    
    func test_WhenRepositoryThrows_FetchExercises_SetsHasError() async throws {
        // Given
        let viewModel = ExerciseListViewModel(
            context: context,
            repository: FailingExerciseRepository()
        )
        // When
        await viewModel.fetchExercises()
        
        // Then
        XCTAssertTrue(viewModel.hasError)
        XCTAssertEqual(viewModel.errorMessage, AristaError.fetchFailed.localizedDescription)
        XCTAssertTrue(viewModel.exercises.isEmpty)
    }
    
    func test_WhenRepositoryThrowsOnDelete_DeleteExercise_SetsHasError() async throws {
        // Given
        let user = makeUser()
        let exercise = makeExercise(user: user)
        try context.save()
        
        let viewModel = ExerciseListViewModel(
            context: context,
            repository: FailingExerciseRepository()
        )
        viewModel.exercises = [exercise]
        
        // Reset error state for clean test
        viewModel.hasError = false
        viewModel.errorMessage = nil

        // When
        await viewModel.deleteExercise(at: IndexSet(integer: 0))
        
        // Then
        XCTAssertTrue(viewModel.hasError, "hasError should be true when deletion fails")
        XCTAssertEqual(viewModel.errorMessage, AristaError.saveFailed.localizedDescription,
                       "errorMessage should match AristaError.saveFailed description")
    }
    
    // MARK: - SleepHistoryViewModel
    
    func test_WhenRepositoryThrows_FetchSleepSessions_SetsHasError() async throws {
        // Given
        let viewModel = SleepHistoryViewModel(
            context: context,
            repository: FailingSleepRepository()
        )
        // When
        await viewModel.fetchSleepSessions()
        
        // Then
        XCTAssertTrue(viewModel.hasError)
        XCTAssertEqual(viewModel.errorMessage, AristaError.fetchFailed.localizedDescription)
        XCTAssertTrue(viewModel.sleepSessions.isEmpty)
    }
    
    // MARK: - AddExerciseViewModel
    
    func test_WhenNoUserExists_AddExercise_ReturnsFalseWithFetchError() async throws {
        // Given
        let viewModel = AddExerciseViewModel(
            context: context,
            userRepository: EmptyUserRepository()
        )
        // When
        let success = await viewModel.addExercise()
        // Then
        XCTAssertFalse(success)
        XCTAssertTrue(viewModel.hasError)
        XCTAssertEqual(viewModel.errorMessage, AristaError.fetchFailed.localizedDescription)
    }
    
    func test_WhenUserFetchThrows_AddExercise_ReturnsFalseWithSaveError() async throws {
        // Given
        let viewModel = AddExerciseViewModel(
            context: context,
            userRepository: FailingUserRepository()
        )
        // When
        let success = await viewModel.addExercise()
        // Then
        XCTAssertFalse(success)
        XCTAssertTrue(viewModel.hasError)
        XCTAssertEqual(viewModel.errorMessage, AristaError.saveFailed.localizedDescription)
    }
    
    func test_WhenExerciseSaveFails_AddExercise_ReturnsFalseWithSaveError() async throws {
        // Given
        let user = makeUser()
        try context.save()
        
        let viewModel = AddExerciseViewModel(
            context: context,
            exerciseRepository: FailingExerciseRepository(),
            userRepository: SucceedingUserRepository(user: user)
        )
        viewModel.category = .running
        viewModel.duration = 30
        viewModel.intensity = 5
        // When
        let success = await viewModel.addExercise()
        // Then
        XCTAssertFalse(success)
        XCTAssertTrue(viewModel.hasError)
        XCTAssertEqual(viewModel.errorMessage, AristaError.saveFailed.localizedDescription)
    }

    // MARK: - Helpers
    
    private func makeUser() -> User {
        let user = User(context: context)
        user.firstName = "Test"
        user.lastName = "User"
        user.email = "test@example.com"
        user.password = "password"
        user.id = UUID()
        return user
    }
    
    private func makeExercise(user: User) -> Exercise {
        let exercise = Exercise(context: context)
        exercise.category = "Running"
        exercise.duration = 30
        exercise.intensity = 5
        exercise.startDate = Date()
        exercise.user = user
        exercise.id = UUID()
        return exercise
    }
}
