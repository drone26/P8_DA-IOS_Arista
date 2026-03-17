//
//  ExerciseRepositoryTests.swift
//  AristaTests
//
//  Created by Mathieu ARRIO on 11/03/2026.
//

import XCTest
import CoreData
@testable import Arista

final class ExerciseRepositoryTests: XCTestCase {
    var persistenceController: PersistenceController!
    var exerciseRepository: ExerciseRepository!
    
    private func emptyEntities(context: NSManagedObjectContext) {
        let fetchRequest = Exercise.fetchRequest()
        let objects = try! context.fetch(fetchRequest)
        
        for exercice in objects {
            context.delete(exercice)
        }
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
    
    private func addExercice(context: NSManagedObjectContext, category: String, duration: Int, intensity: Int, startDate: Date, user: User) {
        let newExercise = Exercise(context: context)
        newExercise.category = category
        newExercise.duration = Int64(duration)
        newExercise.intensity = Int64(intensity)
        newExercise.startDate = startDate
        newExercise.user = user
        newExercise.id = UUID()
        try! context.save()
    }
    
    func test_WhenNoExerciseIsInDatabase_GetExercise_ReturnEmptyList() {
        // Given
        persistenceController = makeTestPersistenceController()
        emptyEntities(context: persistenceController.container.viewContext)
        
        let exerciseRepository = ExerciseRepository(viewContext: persistenceController.container.viewContext)
        
        // When
        let exercises = try! exerciseRepository.getExercise()
        
        // Then
        XCTAssert(exercises.isEmpty == true)
    }
    
    func test_WhenAddingOneExerciseInDatabase_GetExercise_ReturnAListContainingTheExercise() {
        // Given
        persistenceController = makeTestPersistenceController()
        emptyEntities(context: persistenceController.container.viewContext)
        
        let date = Date()
        let user1 = addUser(context: persistenceController.container.viewContext, userFirstName: "Eric", userLastName: "Marcus", userEmail: "eric.marcus@example.com", userPassword: "mdp-lol-123")
        addExercice(context: persistenceController.container.viewContext, category: "Football", duration: 10, intensity: 5, startDate: date, user: user1)
        
        let exerciseRepository = ExerciseRepository(viewContext: persistenceController.container.viewContext)
        // When
        let exercises = try! exerciseRepository.getExercise()
        
        // Then
        XCTAssert(exercises.isEmpty == false)
        XCTAssert(exercises.first?.category == "Football")
        XCTAssert(exercises.first?.duration == 10)
        XCTAssert(exercises.first?.intensity == 5)
        XCTAssert(exercises.first?.startDate == date)
    }
    
    func test_WhenAddingOneExerciseInDatabase_AddExercise_ReturnAListContainingTheExercise() {
        // Given
        persistenceController = makeTestPersistenceController()
        emptyEntities(context: persistenceController.container.viewContext)
        
        let date = Date()
        let exerciseRepository = ExerciseRepository(viewContext: persistenceController.container.viewContext)
        let user1 = addUser(context: persistenceController.container.viewContext, userFirstName: "Eric", userLastName: "Marcus", userEmail: "eric.marcus@example.com", userPassword: "mdp-lol-123")
        // When / Then
        do {
            try exerciseRepository.addExercise(category: "Football", duration: 10, intensity: 5, startDate: date, user: user1)
            let exercises = try exerciseRepository.getExercise()
            XCTAssertFalse(exercises.isEmpty)
            XCTAssert(exercises.count == 1)
            XCTAssert(exercises.first?.wrappedCategory == "Football")
            XCTAssert(exercises.first?.wrappedDuration == 10)
            XCTAssert(exercises.first?.wrappedIntensity == 5)
            XCTAssert(exercises.first?.wrappedStartDate == date)
            XCTAssert(exercises.first?.user == user1)
        } catch {
            XCTFail("Fetch failed with error: \(error)")
        }
    }
    
    func test_WhenAddingMultipleExerciseInDatabase_GetExercise_ReturnAListContainingTheExerciseInTheRightOrder() {
        // Given
        persistenceController = makeTestPersistenceController()
        emptyEntities(context: persistenceController.container.viewContext)
        
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
        
        var user = addUser(context: persistenceController.container.viewContext, userFirstName: "Erica", userLastName: "Marcusi", userEmail: "erica.marcusi@example.com", userPassword: "mdp2-lol-123")
        addExercice(context: persistenceController.container.viewContext,
                    category: "Football",
                    duration: 10,
                    intensity: 5,
                    startDate: date1,
                    user: user)
        
        user = addUser(context: persistenceController.container.viewContext, userFirstName: "Erice", userLastName: "Marceau", userEmail: "erice.marceau@example.com", userPassword: "mpd3-lol-123")
        addExercice(context: persistenceController.container.viewContext,
                    category: "Running",
                    duration: 120,
                    intensity: 1,
                    startDate: date3,
                    user: user)
        
        user = addUser(context: persistenceController.container.viewContext, userFirstName: "Frédericd", userLastName: "Marcus", userEmail: "fredericd.marcus@example.com", userPassword: "mdp4-lol-123")
        addExercice(context: persistenceController.container.viewContext,
                    category: "Fitness",
                    duration: 30,
                    intensity: 5,
                    startDate: date2,
                    user: user)
        
        let exerciseRepository = ExerciseRepository(viewContext: persistenceController.container.viewContext)
        // When
        let exercises = try! exerciseRepository.getExercise()
        
        // Then
        XCTAssert(exercises.count == 3)
        XCTAssert(exercises[0].wrappedCategory == "Football")
        XCTAssert(exercises[1].wrappedCategory == "Fitness")
        XCTAssert(exercises[2].wrappedCategory == "Running")
    }
    
    func test_WhenDeletingMultipleExerciseInDatabase_DeleteExercise_ReturnEmptyList() {
        // Given
        persistenceController = makeTestPersistenceController()
        emptyEntities(context: persistenceController.container.viewContext)
        
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
        
        var user = addUser(context: persistenceController.container.viewContext, userFirstName: "Erica", userLastName: "Marcusi", userEmail: "erica.marcusi@example.com", userPassword: "mdp2-lol-123")
        addExercice(context: persistenceController.container.viewContext,
                    category: "Football",
                    duration: 10,
                    intensity: 5,
                    startDate: date1,
                    user: user)
        
        user = addUser(context: persistenceController.container.viewContext, userFirstName: "Erice", userLastName: "Marceau", userEmail: "erice.marceau@example.com", userPassword: "mpd3-lol-123")
        addExercice(context: persistenceController.container.viewContext,
                    category: "Running",
                    duration: 120,
                    intensity: 1,
                    startDate: date3,
                    user: user)
        
        user = addUser(context: persistenceController.container.viewContext, userFirstName: "Frédericd", userLastName: "Marcus", userEmail: "fredericd.marcus@example.com", userPassword: "mdp4-lol-123")
        addExercice(context: persistenceController.container.viewContext,
                    category: "Fitness",
                    duration: 30,
                    intensity: 5,
                    startDate: date2,
                    user: user)
        
        let exerciseRepository = ExerciseRepository(viewContext: persistenceController.container.viewContext)
        
        // When / Then
        do {
            var exercises = try! exerciseRepository.getExercise()
            try exerciseRepository.deleteExercise(exercises[2])
            try exerciseRepository.deleteExercise(exercises[1])
            try exerciseRepository.deleteExercise(exercises[0])
            exercises = try! exerciseRepository.getExercise()
            XCTAssertTrue(exercises.isEmpty)
        } catch {
            XCTFail("Fetch failed with error: \(error)")
        }
    }
    
    func test_ExerciseWrappedProperties_WhenValuesAreNotDefined() {
        // Given
        persistenceController = makeTestPersistenceController()
        emptyEntities(context: persistenceController.container.viewContext)
        
        // When
        // Create a user without setting optional properties
        let exercice = Exercise(context: persistenceController.container.viewContext)
        exercice.id = UUID()
        
        // Then
        XCTAssertEqual(exercice.wrappedCategory, "Free")
        XCTAssertEqual(exercice.wrappedDuration, 0)
        XCTAssertEqual(exercice.wrappedIntensity, 0)
        XCTAssertEqual(exercice.iconName, "figure.run.square.stack")
    }
    
    func test_ExerciseWrappedProperties_WhenValuesAreDefined() {
        // Given
        persistenceController = makeTestPersistenceController()
        emptyEntities(context: persistenceController.container.viewContext)
        
        // When
        // Create a user without setting optional properties
        let date = Date()
        let exercice = Exercise(context: persistenceController.container.viewContext)
        exercice.id = UUID()
        exercice.category = "Football"
        exercice.duration = 45
        exercice.intensity = 7
        exercice.startDate = date
        
        // Then
        XCTAssertEqual(exercice.wrappedCategory, "Football")
        XCTAssertEqual(exercice.wrappedDuration, 45)
        XCTAssertEqual(exercice.wrappedIntensity, 7)
        XCTAssertEqual(exercice.iconName, "sportscourt")
        XCTAssertEqual(exercice.wrappedFormattedStartDate, "\(date.formatted())")
    }
}
