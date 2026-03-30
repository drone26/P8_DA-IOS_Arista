//
//  AddExerciseViewModelTests.swift
//  AristaTests
//
//  Created by Mathieu ARRIO on 13/03/2026.
//

import XCTest
import CoreData
import Combine
@testable import Arista

@MainActor
final class AddExerciseViewModelTests: XCTestCase {
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var viewModel: AddExerciseViewModel!
    var exerciseRepository: ExerciseRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        emptyEntities(context: context)
        viewModel = AddExerciseViewModel(context: context)
        exerciseRepository = ExerciseRepository(viewContext: context)
    }
    
    override func tearDown() async throws {
        viewModel = nil
        exerciseRepository = nil
        context = nil
        persistenceController = nil
        try await super.tearDown()
    }
    
    func test_WhenAddingOneExerciseInDatabase_AddExercise_ReturnAListContainingTheExercise() async throws {
        // Given
        _ = addUser(context: context, userFirstName: "Eric", userLastName: "Marcus", userEmail: "eric.marcus@example.com", userPassword: "mdp-lol-123")
        
        let expectedCategory = ExerciseCategory.running
        let expectedDuration = 45
        let expectedIntensity = 7
        let testDate = Date()
        
        viewModel.category = expectedCategory
        viewModel.duration = expectedDuration
        viewModel.intensity = expectedIntensity
        viewModel.startDate = testDate
        
        // When
        let success = await viewModel.addExercise()
        
        // Then
        XCTAssertTrue(success, "L'ajout d'exercice devrait réussir")
        
        let exercises = try exerciseRepository.getExercises()
        XCTAssertEqual(exercises.count, 1, "Il devrait y avoir un exercice en base")
        XCTAssertEqual(exercises.first?.category, expectedCategory.rawValue)
        XCTAssertEqual(exercises.first?.duration, Int64(expectedDuration))
        XCTAssertEqual(exercises.first?.intensity, Int64(expectedIntensity))
    }
    
    // MARK: - Duration Validator

    func test_WhenDurationIsZero_isDurationValid_ReturnsFalse() {
        viewModel.duration = 0
        XCTAssertFalse(viewModel.isDurationValid)
    }

    func test_WhenDurationIsNegative_isDurationValid_ReturnsFalse() {
        viewModel.duration = -5
        XCTAssertFalse(viewModel.isDurationValid)
    }

    func test_WhenDurationIsPositive_isDurationValid_ReturnsTrue() {
        viewModel.duration = 1
        XCTAssertTrue(viewModel.isDurationValid)

        viewModel.duration = 60
        XCTAssertTrue(viewModel.isDurationValid)
    }

    // MARK: - Intensity Validator

    func test_WhenIntensityIsNegative_isIntensityValid_ReturnsFalse() {
        viewModel.intensity = -1
        XCTAssertFalse(viewModel.isIntensityValid)
    }

    func test_WhenIntensityIsAboveTen_isIntensityValid_ReturnsFalse() {
        viewModel.intensity = 11
        XCTAssertFalse(viewModel.isIntensityValid)
    }

    func test_WhenIntensityIsZero_isIntensityValid_ReturnsTrue() {
        viewModel.intensity = 0
        XCTAssertTrue(viewModel.isIntensityValid)
    }

    func test_WhenIntensityIsTen_isIntensityValid_ReturnsTrue() {
        viewModel.intensity = 10
        XCTAssertTrue(viewModel.isIntensityValid)
    }

    func test_WhenIntensityIsMidRange_isIntensityValid_ReturnsTrue() {
        viewModel.intensity = 5
        XCTAssertTrue(viewModel.isIntensityValid)
    }

    // MARK: - Form Validator

    func test_WhenDurationAndIntensityAreValid_isFormValid_ReturnsTrue() {
        viewModel.duration = 30
        viewModel.intensity = 5
        XCTAssertTrue(viewModel.isFormValid)
    }

    func test_WhenDurationIsInvalid_isFormValid_ReturnsFalse() {
        viewModel.duration = 0
        viewModel.intensity = 5
        XCTAssertFalse(viewModel.isFormValid)
    }

    func test_WhenIntensityIsInvalid_isFormValid_ReturnsFalse() {
        viewModel.duration = 30
        viewModel.intensity = -1
        XCTAssertFalse(viewModel.isFormValid)
    }

    func test_WhenBothAreInvalid_isFormValid_ReturnsFalse() {
        viewModel.duration = 0
        viewModel.intensity = 11
        XCTAssertFalse(viewModel.isFormValid)
    }

    // MARK: - Helpers
    
    private func emptyEntities(context: NSManagedObjectContext) {
        let fetchRequest = Exercise.fetchRequest()
        let objects = try! context.fetch(fetchRequest)
        for exercice in objects { context.delete(exercice) }
        try! context.save()
    }
    
    private func addUser(context: NSManagedObjectContext, userFirstName: String, userLastName: String, userEmail: String, userPassword: String) -> User {
        let newUser = User(context: context)
        newUser.firstName = userFirstName
        newUser.lastName = userLastName
        newUser.email = userEmail
        newUser.password = userPassword
        newUser.id = UUID()
        try! context.save()
        return newUser
    }
}
