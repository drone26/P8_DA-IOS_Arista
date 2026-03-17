import XCTest
import CoreData
@testable import Arista

@MainActor
final class PersistenceControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let controller = PersistenceController.shared
        controller.hasError = false
        controller.errorMessage = nil
    }

    // MARK: - Helper Mock
    
    /// A mock container that successfully loads an in-memory store (to prevent
    /// DefaultData save crashes), but passes a fake error to the completion handler.
    class MockFailingPersistentContainer: NSPersistentContainer, @unchecked Sendable {
        override func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
            
            // 1. Force it to be an in-memory store
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            self.persistentStoreDescriptions = [description]
            
            // 2. Call super to ACTUALLY load the in-memory store.
            // This guarantees `DefaultData` has a valid context to save to, preventing crashes.
            super.loadPersistentStores { desc, _ in
                
                // 3. Intercept the completion and pass a FAKE error back to `PersistenceController`.
                let fakeError = NSError(domain: "com.arista.test", code: 999, userInfo: nil)
                block(desc, fakeError)
            }
        }
    }

    // MARK: - Async Store Loading Failure Test

    func testLoadStoresFailure() async throws {
        // Given
        // Use our mock container
        let mockContainer = MockFailingPersistentContainer(name: "Arista")
        let controller = PersistenceController(container: mockContainer)
        
        XCTAssertFalse(controller.hasError, "Precondition: hasError should initially be false.")
        XCTAssertNil(controller.errorMessage, "Precondition: errorMessage should initially be nil.")
        
        // When
        await controller.loadStores()
        
        // Allow the detached MainActor task time to update the UI state
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertTrue(controller.hasError, "hasError should be set to true because we passed a fake error.")
        XCTAssertEqual(
            controller.errorMessage,
            AristaError.persistenceFailure.localizedDescription,
            "The error message should be mapped to the persistence failure localized description."
        )
    }

    // MARK: - Error Handling Tests

    func testHandleStoreError() {
        // Given
        let controller = PersistenceController.shared
        
        // When
        controller.handleStoreError()
        
        // Then
        XCTAssertTrue(controller.hasError)
        XCTAssertEqual(controller.errorMessage, AristaError.persistenceFailure.localizedDescription)
    }
    
    // MARK: - Initialization Tests
    
    func testSharedControllerInitialization() {
        // Given / When
        let controller = PersistenceController.shared
        
        // Then
        XCTAssertNotNil(controller.container)
        XCTAssertEqual(controller.container.name, "Arista")
        XCTAssertTrue(controller.container.viewContext.automaticallyMergesChangesFromParent)
    }
}
