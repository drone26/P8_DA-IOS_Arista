//
//  SleepRepositoryTests.swift
//  AristaTests
//
//  Created by Mathieu ARRIO on 11/03/2026.
//

import XCTest
import CoreData
@testable import Arista

final class SleepRepositoryTests: XCTestCase {
    var persistenceController: PersistenceController!
    var sleepRepository: SleepRepository!
    
    private func emptyEntities(context: NSManagedObjectContext) {
        let fetchRequest = Sleep.fetchRequest()
        let objects = try! context.fetch(fetchRequest)
        
        for sleep in objects {
            context.delete(sleep)
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
    
    private func addSleep(context: NSManagedObjectContext, quality: Int, duration: Int, startDate: Date, user: User) {
        let newSleep = Sleep(context: context)
        newSleep.quality = Int64(quality)
        newSleep.duration = Int64(duration)
        newSleep.startDate = startDate
        newSleep.user = user
        newSleep.id = UUID()
        try! context.save()
    }
    
    func test_WhenNoSleepIsInDatabase_GetSleepSessions_ReturnEmptyList() {
        
        // Clean manually all data
        persistenceController = makeTestPersistenceController()
        emptyEntities(context: persistenceController.container.viewContext)
        
        let sleepRepository = SleepRepository(viewContext: persistenceController.container.viewContext)
        
        let sleeps = try! sleepRepository.getSleepSessions()
        
        XCTAssert(sleeps.isEmpty == true)
    }
 
    func test_WhenAddingOneSleepInDatabase_GetSleepSessions_ReturnAListContainingTheSleeps() {
        
        // Clean manually all data
        persistenceController = makeTestPersistenceController()
        emptyEntities(context: persistenceController.container.viewContext)
        
        let date = Date()
        let user1 = addUser(context: persistenceController.container.viewContext, userFirstName: "Eric", userLastName: "Marcus", userEmail: "eric.marcus@example.com", userPassword: "mdp-lol-123")
        addSleep(context: persistenceController.container.viewContext, quality: 5, duration: 10, startDate: date, user: user1)
        
        let sleepRepository = SleepRepository(viewContext: persistenceController.container.viewContext)
        let sleeps = try! sleepRepository.getSleepSessions()
        
        XCTAssert(sleeps.isEmpty == false)
        XCTAssert(sleeps.first?.duration == 10)
        XCTAssert(sleeps.first?.quality == 5)
        XCTAssert(sleeps.first?.startDate == date)
    }
    
    func test_WhenAddingMultipleSleepInDatabase_GetSleep_ReturnAListContainingTheSleepInTheRightOrder() {
        
        // Clean manually all data
        persistenceController = makeTestPersistenceController()
        emptyEntities(context: persistenceController.container.viewContext)
        
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
        
        var user = addUser(context: persistenceController.container.viewContext, userFirstName: "Erica", userLastName: "Marcusi", userEmail: "erica.marcusi@example.com", userPassword: "mdp2-lol-123")
        addSleep(context: persistenceController.container.viewContext, quality: 1, duration: 10, startDate: date1, user: user)
        
        user = addUser(context: persistenceController.container.viewContext, userFirstName: "Erice", userLastName: "Marceau", userEmail: "erice.marceau@example.com", userPassword: "mpd3-lol-123")
        addSleep(context: persistenceController.container.viewContext, quality: 4, duration: 10, startDate: date3, user: user)
        
        user = addUser(context: persistenceController.container.viewContext, userFirstName: "Frédericd", userLastName: "Marcus", userEmail: "fredericd.marcus@example.com", userPassword: "mdp4-lol-123")
        addSleep(context: persistenceController.container.viewContext, quality: 8, duration: 10, startDate: date2, user: user)
        
        let sleepRepository = SleepRepository(viewContext: persistenceController.container.viewContext)
        let sleeps = try! sleepRepository.getSleepSessions()
        
        XCTAssert(sleeps.count == 3)
        XCTAssert(sleeps[0].quality == 1)
        XCTAssert(sleeps[1].quality == 8)
        XCTAssert(sleeps[2].quality == 4)
    }

    func test_SleepWrappedProperties_WhenValuesAreNotDefined() {
        
        // Clean manually all data
        persistenceController = makeTestPersistenceController()
        emptyEntities(context: persistenceController.container.viewContext)
        
        // Create a user without setting optional properties
        let sleep = Sleep(context: persistenceController.container.viewContext)
        sleep.id = UUID()
        
        XCTAssertEqual(sleep.wrappedQuality, 0, "Should return 0")
        XCTAssertEqual(sleep.wrappedDuration, 0, "Should return 0")
    }
    
    func test_SleepWrappedProperties_WhenValuesAreDefined() {
        
        // Clean manually all data
        persistenceController = makeTestPersistenceController()
        emptyEntities(context: persistenceController.container.viewContext)
        
        // Create a user without setting optional properties
        let date = Date()
        let sleep = Sleep(context: persistenceController.container.viewContext)
        sleep.id = UUID()
        sleep.duration = 60
        sleep.quality = 5
        sleep.startDate = date
        
        XCTAssertEqual(sleep.wrappedQuality, 5)
        XCTAssertEqual(sleep.wrappedDuration, 60)
        XCTAssertEqual(sleep.wrappedStartDate, date)
        XCTAssertEqual(sleep.wrappedDurationInHour, String(format: "Durée : %.1f heures", 60 / 60.0))
        XCTAssertEqual(sleep.wrappedFormattedStartDate, date.formatted())
    }
}
