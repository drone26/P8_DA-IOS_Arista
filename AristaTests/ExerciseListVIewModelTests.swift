//
//  ExerciseListVIewModelTests.swift
//  AristaTests
//
//  Created by Mathieu ARRIO on 12/03/2026.
//

import XCTest
import CoreData
@testable import Arista

@MainActor
final class ExerciseListViewModelTests: XCTestCase {
    var persistenceController: PersistenceController!
    var viewModel: ExerciseListViewModel!

    override func setUp() async throws {
        try await super.setUp()
        persistenceController = makeTestPersistenceController()
        emptyEntities(context: persistenceController.container.viewContext)
    }

    override func tearDown() async throws {
        viewModel = nil
        persistenceController = nil
        try await super.tearDown()
    }

    // MARK: - Fetch tests

    func test_WhenNoExerciseIsInDatabase_FetchExercise_ReturnEmptyList() async throws {
        // Given
        viewModel = ExerciseListViewModel(context: persistenceController.container.viewContext)
        // When
        await viewModel.fetchExercises()

        // Then
        XCTAssertTrue(viewModel.exercises.isEmpty)
    }

    func test_WhenAddingOneExercise_FetchExercise_ReturnAListContainingTheExercise() async throws {
        // Given
        let context = persistenceController.container.viewContext
        let date = Date()
        let user = addUser(context: context, firstName: "Eric", lastName: "Marcus",
                           email: "eric.marcus@example.com", password: "mdp-lol-123")
        addExercise(context: context, category: "Football", duration: 10,
                    intensity: 5, startDate: date, user: user)

        viewModel = ExerciseListViewModel(context: context)
        // When
        await viewModel.fetchExercises()

        // Then
        XCTAssertFalse(viewModel.exercises.isEmpty)
        XCTAssertEqual(viewModel.exercises.first?.category, "Football")
        XCTAssertEqual(viewModel.exercises.first?.duration, 10)
        XCTAssertEqual(viewModel.exercises.first?.intensity, 5)
        XCTAssertEqual(viewModel.exercises.first?.startDate, date)
    }

    func test_WhenAddingMultipleExercises_FetchExercise_ReturnListInReverseChronologicalOrder() async throws {
        // Given
        let context = persistenceController.container.viewContext
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))

        let u1 = addUser(context: context, firstName: "A", lastName: "A", email: "a@a.com", password: "p")
        let u2 = addUser(context: context, firstName: "B", lastName: "B", email: "b@b.com", password: "p")
        let u3 = addUser(context: context, firstName: "C", lastName: "C", email: "c@c.com", password: "p")
        addExercise(context: context, category: "Football", duration: 10,  intensity: 5, startDate: date1, user: u1)
        addExercise(context: context, category: "Running",  duration: 120, intensity: 1, startDate: date3, user: u2)
        addExercise(context: context, category: "Fitness",  duration: 30,  intensity: 5, startDate: date2, user: u3)

        viewModel = ExerciseListViewModel(context: context)
        // When
        await viewModel.fetchExercises()

        // Then
        XCTAssertEqual(viewModel.exercises.count, 3)
        XCTAssertEqual(viewModel.exercises[0].category, "Football") // date1 — most recent
        XCTAssertEqual(viewModel.exercises[1].category, "Fitness")  // date2
        XCTAssertEqual(viewModel.exercises[2].category, "Running")  // date3 — oldest
    }

    // MARK: - Delete tests

    func test_WhenDeletingOneExercise_ExercisesListHasOneFewerItem() async throws {
        // Given
        let context = persistenceController.container.viewContext
        let user = addUser(context: context, firstName: "A", lastName: "A", email: "a@a.com", password: "p")
        addExercise(context: context, category: "Football", duration: 10, intensity: 5, startDate: Date(), user: user)
        addExercise(context: context, category: "Running",  duration: 30, intensity: 3, startDate: Date(timeIntervalSinceNow: -3600), user: user)

        viewModel = ExerciseListViewModel(context: context)
        // When
        await viewModel.fetchExercises()
        
        // Then
        XCTAssertEqual(viewModel.exercises.count, 2)

        // When
        await viewModel.deleteExercise(at: IndexSet(integer: 0))

        // Then
        XCTAssertEqual(viewModel.exercises.count, 1)
        XCTAssertFalse(viewModel.hasError)
    }

    func test_WhenDeletingOneExercise_CorrectExerciseIsRemoved() async throws {
        // Given
        let context = persistenceController.container.viewContext
        let user = addUser(context: context, firstName: "A", lastName: "A", email: "a@a.com", password: "p")
        addExercise(context: context, category: "Football", duration: 10, intensity: 5, startDate: Date(), user: user)
        addExercise(context: context, category: "Running",  duration: 30, intensity: 3, startDate: Date(timeIntervalSinceNow: -3600), user: user)

        viewModel = ExerciseListViewModel(context: context)
        // When
        await viewModel.fetchExercises()

        // exercises[0] is "Football" (most recent) — delete it
        await viewModel.deleteExercise(at: IndexSet(integer: 0))
        
        // Then
        XCTAssertEqual(viewModel.exercises.first?.category, "Running")
    }

    func test_WhenDeletingAllExercises_ExerciseListIsEmpty() async throws {
        // Given
        let context = persistenceController.container.viewContext
        let user = addUser(context: context, firstName: "A", lastName: "A", email: "a@a.com", password: "p")
        addExercise(context: context, category: "Football", duration: 10, intensity: 5, startDate: Date(), user: user)
        addExercise(context: context, category: "Running",  duration: 30, intensity: 3, startDate: Date(timeIntervalSinceNow: -3600), user: user)
        addExercise(context: context, category: "Fitness",  duration: 45, intensity: 7, startDate: Date(timeIntervalSinceNow: -7200), user: user)

        viewModel = ExerciseListViewModel(context: context)
        
        // When
        await viewModel.fetchExercises()
        // Then
        XCTAssertEqual(viewModel.exercises.count, 3)

        // When
        await viewModel.deleteExercise(at: IndexSet(viewModel.exercises.indices))

        // Then
        XCTAssertTrue(viewModel.exercises.isEmpty)
        XCTAssertFalse(viewModel.hasError)
    }

    func test_WhenDeletingExercise_FetchExercisesIsCalledAfterDeletion() async throws {
        // Given
        let context = persistenceController.container.viewContext
        let user = addUser(context: context, firstName: "A", lastName: "A", email: "a@a.com", password: "p")
        addExercise(context: context, category: "Football", duration: 10, intensity: 5, startDate: Date(), user: user)

        viewModel = ExerciseListViewModel(context: context)
        // When
        await viewModel.fetchExercises()

        await viewModel.deleteExercise(at: IndexSet(integer: 0))

        // Then
        XCTAssertTrue(viewModel.exercises.isEmpty)

        // When
        let repo = ExerciseRepository(viewContext: context)
        let remaining = try repo.getExercises()
        // Then
        XCTAssertTrue(remaining.isEmpty)
    }

    // MARK: - Helpers

    private func emptyEntities(context: NSManagedObjectContext) {
        let objects = try! context.fetch(Exercise.fetchRequest())
        objects.forEach { context.delete($0) }
        try! context.save()
    }

    private func addUser(context: NSManagedObjectContext, firstName: String, lastName: String,
                         email: String, password: String) -> User {
        let user = User(context: context)
        user.firstName = firstName
        user.lastName = lastName
        user.email = email
        user.password = password
        user.id = UUID()
        try! context.save()
        return user
    }

    private func addExercise(context: NSManagedObjectContext, category: String, duration: Int,
                              intensity: Int, startDate: Date, user: User) {
        let exercise = Exercise(context: context)
        exercise.category = category
        exercise.duration = Int64(duration)
        exercise.intensity = Int64(intensity)
        exercise.startDate = startDate
        exercise.user = user
        exercise.id = UUID()
        try! context.save()
    }
}
