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

// @MainActor matches the isolation of AddExerciseViewModel, allowing direct
// await calls on its async methods without crossing actor boundaries.
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
        _ = addUser(context: context, userFirstName: "Eric", userLastName: "Marcus", userEmail: "eric.marcus@example.com", userPassword: "mdp-lol-123")
        
        let expectedCategory = ExerciseCategory.running
        let expectedDuration = 45
        let expectedIntensity = 7
        let testDate = Date()
        
        viewModel.category = expectedCategory
        viewModel.duration = expectedDuration
        viewModel.intensity = expectedIntensity
        viewModel.startDate = testDate
        
        let success = await viewModel.addExercise()
        
        XCTAssertTrue(success, "L'ajout d'exercice devrait réussir")
        
        let exercises = try exerciseRepository.getExercise()
        XCTAssertEqual(exercises.count, 1, "Il devrait y avoir un exercice en base")
        XCTAssertEqual(exercises.first?.category, expectedCategory.rawValue)
        XCTAssertEqual(exercises.first?.duration, Int64(expectedDuration))
        XCTAssertEqual(exercises.first?.intensity, Int64(expectedIntensity))
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
