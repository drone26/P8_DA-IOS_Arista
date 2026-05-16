//
//  ExercisePerformanceTests.swift
//  AristaTests
//

import XCTest
import CoreData
@testable import Arista

final class ExercisePerformanceTests: XCTestCase {
    var persistenceController: PersistenceController!
    var exerciseRepository: ExerciseRepository!

    override func setUp() {
        super.setUp()
        persistenceController = makeTestPersistenceController()
        exerciseRepository = ExerciseRepository(viewContext: persistenceController.container.viewContext)
    }

    private func addUser(context: NSManagedObjectContext) -> User {
        let newUser = User(context: context)
        newUser.firstName = "Test"
        newUser.lastName = "User"
        newUser.email = "test@example.com"
        newUser.password = "password"
        newUser.id = UUID()
        try! context.save()
        return newUser
    }

    func test_DeleteMultipleExercises_Performance() {
        let context = persistenceController.container.viewContext
        let user = addUser(context: context)

        // Add 100 exercises
        for i in 0..<100 {
            let newExercise = Exercise(context: context)
            newExercise.category = "Football"
            newExercise.duration = Int64(i)
            newExercise.intensity = 5
            newExercise.startDate = Date()
            newExercise.user = user
            newExercise.id = UUID()
        }
        try! context.save()

        let exercises = try! exerciseRepository.getExercises()
        XCTAssertEqual(exercises.count, 100)

        measure {
            do {
                try exerciseRepository.deleteExercises(exercises)
            } catch {
                XCTFail("Delete failed")
            }
        }
    }
}
