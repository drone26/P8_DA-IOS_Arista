//
//  DefaultDataTests.swift
//  AristaTests
//
//  Created by Jules on 14/03/2026.
//

import XCTest
import CoreData
@testable import Arista

final class DefaultDataTests: XCTestCase {
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var defaultData: DefaultData!

    override func setUp() {
        super.setUp()
        persistenceController = makeTestPersistenceController()
        context = persistenceController.container.viewContext
        defaultData = DefaultData(viewContext: context)
    }

    override func tearDown() {
        context = nil
        persistenceController = nil
        defaultData = nil
        super.tearDown()
    }

    private func fetchUsers() throws -> [User] {
        let request = User.fetchRequest()
        return try context.fetch(request)
    }

    private func fetchSleepSessions() throws -> [Sleep] {
        let request = Sleep.fetchRequest()
        return try context.fetch(request)
    }

    func test_Apply_WhenNoUserExists_CreatesDefaultUserAndSleepSessions() throws {
        // Given: Empty context
        XCTAssertEqual(try fetchUsers().count, 0)
        XCTAssertEqual(try fetchSleepSessions().count, 0)

        // When
        try defaultData.apply()

        // Then
        let users = try fetchUsers()
        XCTAssertEqual(users.count, 1)
        let user = users.first!
        XCTAssertEqual(user.firstName, "Charlotte")
        XCTAssertEqual(user.lastName, "Razoul")
        XCTAssertEqual(user.email, "charlotte.razoul@example.com")

        let sleepSessions = try fetchSleepSessions()
        XCTAssertEqual(sleepSessions.count, 5)
        for sleep in sleepSessions {
            XCTAssertNotNil(sleep.user)
            XCTAssertEqual(sleep.user, user)
            XCTAssertTrue((0...900).contains(sleep.duration))
            XCTAssertTrue((0...10).contains(sleep.quality))
            XCTAssertNotNil(sleep.startDate)
            XCTAssertNotNil(sleep.id)
        }
    }

    func test_Apply_WhenUserAlreadyExists_DoesNotCreateData() throws {
        // Given: A user already exists
        let user = User(context: context)
        user.firstName = "Existing"
        user.lastName = "User"
        user.email = "existing@example.com"
        user.password = "password"
        user.id = UUID()
        try context.save()

        XCTAssertEqual(try fetchUsers().count, 1)

        // When
        try defaultData.apply()

        // Then: No new user or sleep sessions should be created
        XCTAssertEqual(try fetchUsers().count, 1)
        XCTAssertEqual(try fetchSleepSessions().count, 0)
        XCTAssertEqual(try fetchUsers().first?.firstName, "Existing")
    }

    func test_Apply_WhenNoUserButSleepSessionsExist_CreatesUserAndDefaultSleepSessions() throws {
        // Given: Some sleep sessions exist but no user (edge case)
        let sleep = Sleep(context: context)
        sleep.quality = 5
        sleep.duration = 60
        sleep.startDate = Date()
        sleep.id = UUID()
        try context.save()

        XCTAssertEqual(try fetchUsers().count, 0)
        XCTAssertEqual(try fetchSleepSessions().count, 1)

        // When
        try defaultData.apply()

        // Then: A new user should be created, and 5 default sleep sessions should be created
        // because they are nested inside the if (user == nil) block in DefaultData.swift
        XCTAssertEqual(try fetchUsers().count, 1)
        XCTAssertEqual(try fetchSleepSessions().count, 6) // 1 manual + 5 default
        XCTAssertEqual(try fetchUsers().first?.firstName, "Charlotte")
    }
}
