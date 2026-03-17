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
    func getExercise() throws -> [Exercise] { throw AristaError.fetchFailed }
    func addExercise(category: String, duration: Int, intensity: Int, startDate: Date, user: User) throws { throw AristaError.saveFailed }
    func deleteExercise(_ exercise: Exercise) throws { throw AristaError.saveFailed }
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
        let viewModel = ExerciseListViewModel(
            context: context,
            repository: FailingExerciseRepository()
        )
        await viewModel.fetchExercises()
        
        XCTAssertTrue(viewModel.hasError)
        XCTAssertEqual(viewModel.errorMessage, AristaError.fetchFailed.localizedDescription)
        XCTAssertTrue(viewModel.exercises.isEmpty)
    }
    
    func test_WhenRepositoryThrowsOnDelete_DeleteExercise_SetsHasError() async throws {
        // Seed one real exercise so exercises[0] exists
        let user = makeUser()
        let exercise = makeExercise(user: user)
        try context.save()
        
        let viewModel = ExerciseListViewModel(
            context: context,
            repository: FailingExerciseRepository()
        )
        viewModel.exercises = [exercise]
        
        await viewModel.deleteExercise(at: IndexSet(integer: 0))
        
        XCTAssertTrue(viewModel.hasError)
        XCTAssertEqual(viewModel.errorMessage, AristaError.saveFailed.localizedDescription)
    }
    
    // MARK: - SleepHistoryViewModel
    
    func test_WhenRepositoryThrows_FetchSleepSessions_SetsHasError() async throws {
        let viewModel = SleepHistoryViewModel(
            context: context,
            repository: FailingSleepRepository()
        )
        await viewModel.fetchSleepSessions()
        
        XCTAssertTrue(viewModel.hasError)
        XCTAssertEqual(viewModel.errorMessage, AristaError.fetchFailed.localizedDescription)
        XCTAssertTrue(viewModel.sleepSessions.isEmpty)
    }
    
    // MARK: - AddExerciseViewModel
    
    func test_WhenNoUserExists_AddExercise_ReturnsFalseWithFetchError() async throws {
        let viewModel = AddExerciseViewModel(
            context: context,
            userRepository: EmptyUserRepository()
        )
        
        let success = await viewModel.addExercise()
        
        XCTAssertFalse(success)
        XCTAssertTrue(viewModel.hasError)
        XCTAssertEqual(viewModel.errorMessage, AristaError.fetchFailed.localizedDescription)
    }
    
    func test_WhenUserFetchThrows_AddExercise_ReturnsFalseWithSaveError() async throws {
        let viewModel = AddExerciseViewModel(
            context: context,
            userRepository: FailingUserRepository()
        )
        
        let success = await viewModel.addExercise()
        
        XCTAssertFalse(success)
        XCTAssertTrue(viewModel.hasError)
        XCTAssertEqual(viewModel.errorMessage, AristaError.saveFailed.localizedDescription)
    }
    
    func test_WhenExerciseSaveFails_AddExercise_ReturnsFalseWithSaveError() async throws {
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
        
        let success = await viewModel.addExercise()
        
        XCTAssertFalse(success)
        XCTAssertTrue(viewModel.hasError)
        XCTAssertEqual(viewModel.errorMessage, AristaError.saveFailed.localizedDescription)
    }
/*
    func test_HandleStoreError_SetsErrorState() {
        let controller = makeTestPersistenceController()
        
        controller.handleStoreError()
        
        XCTAssertTrue(controller.hasError)
        XCTAssertEqual(
            controller.errorMessage,
            AristaError.persistenceFailure.localizedDescription
        )
    }
*/
    // MARK: - Helpers
    
    @discardableResult
    private func makeUser() -> User {
        let user = User(context: context)
        user.firstName = "Test"
        user.lastName = "User"
        user.email = "test@example.com"
        user.password = "password"
        user.id = UUID()
        return user
    }
    
    @discardableResult
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
