//
//  Persistence.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//  Modified by Mathieu Arrio on 05/03/2026.
//

import CoreData

@MainActor
@Observable
class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    var errorMessage: String?
    var hasError: Bool = false
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Arista")

        // Configure the store to use complete file protection for security.
        let description = container.persistentStoreDescriptions.first ?? NSPersistentStoreDescription()
        description.setOption(NSFileProtectionComplete as NSObject, forKey: NSPersistentStoreFileProtectionKey)
        container.persistentStoreDescriptions = [description]

        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
            container.loadPersistentStores { _, _ in }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    /// Testing init — accepts a pre-configured container backed by the shared
    /// test model. Never call this from production code.
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    // MARK: - Production store loading
    
    /// Load CoreData Store
    func loadStores() async {
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                container.loadPersistentStores { _, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            }
            // Store loaded successfully → apply default data
            try? DefaultData(viewContext: container.viewContext).apply()
        } catch {
            handleStoreError()
        }
    }
    
    func handleStoreError() {
        errorMessage = AristaError.persistenceFailure.localizedDescription
        hasError = true
    }
}
