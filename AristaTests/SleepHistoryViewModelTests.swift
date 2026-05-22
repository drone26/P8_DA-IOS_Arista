//
//  SleepHistoryViewModelTests.swift
//  AristaTests
//
//  Created by Mathieu ARRIO on 13/03/2026.
//

import XCTest
import CoreData
import Combine
@testable import Arista

final class SleepHistoryViewModelTests: XCTestCase {
    var persistenceController: PersistenceController!
    var viewModel: SleepHistoryViewModel!
    
    func test_WhenNoSleepSessionIsInDatabase_FetchSleepSessions_ReturnEmptyList() async {
        // Given
        persistenceController = makeTestPersistenceController()
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        viewModel = SleepHistoryViewModel(context: context)
        // When
        await viewModel.fetchSleepSessions()
        
        // Then
        XCTAssertTrue(viewModel.sleepSessions.isEmpty, "The sleep session list should be empty.")
    }
    
    func test_WhenAddingMultipleSleepSessionInDatabase_FetchSleepSessions_ReturnAListContainingTheSleepSessionsInTheRightOrder() async {
        // Given
        persistenceController = makeTestPersistenceController()
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
        
        let user = addUser(context: context, userFirstName: "Erica", userLastName: "Marcusi", userEmail: "erica.marcusi@example.com", userPassword: "mdp2-lol-123")
        addSleep(context: context,
                 duration: 600,
                 quality: 1,
                 startDate: date1,
                 user: user)
        addSleep(context: context,
                 duration: 6000,
                 quality: 8,
                 startDate: date2,
                 user: user)
        addSleep(context: context,
                 duration: 4000,
                 quality: 6,
                 startDate: date3,
                 user: user)
        
        viewModel = SleepHistoryViewModel(context: context)
        
        // When
        await viewModel.fetchSleepSessions()
        
        // Then
        XCTAssert(viewModel.sleepSessions.count == 3)
        XCTAssert(viewModel.sleepSessions[0].duration == 600)
        XCTAssert(viewModel.sleepSessions[1].duration == 6000)
        XCTAssert(viewModel.sleepSessions[2].duration == 4000)
    }
    
    private func emptyEntities(context: NSManagedObjectContext) {
        let fetchRequest = Sleep.fetchRequest()
        let objects = try! context.fetch(fetchRequest)
        
        for sleepSession in objects {
            context.delete(sleepSession)
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
    
    private func addSleep(context: NSManagedObjectContext, duration: Int, quality: Int, startDate: Date, user: User) {
        let newSleep = Sleep(context: context)
        newSleep.duration = Int64(duration)
        newSleep.quality = Int64(quality)
        newSleep.startDate = startDate
        newSleep.user = user
        newSleep.id = UUID()
        try! context.save()
    }
}
