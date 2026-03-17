//
//  Persistence.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//  Modified by Mathieu Arrio on 06/03/2026.
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
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
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
    
    func loadStores() async {
        // Use withCheckedContinuation to bridge the completion handler to async/await
        let storeLoadedSuccessfully: Bool = await withCheckedContinuation { continuation in
            container.loadPersistentStores { [weak self] _, error in
                if let error = error {
                    // If an error occurred, handle it on the main actor
                    Task { @MainActor [weak self] in
                        self?.handleStoreError()
                    }
                    // Signal to the continuation that store loading failed
                    continuation.resume(returning: false)
                } else {
                    // If no error, signal success
                    continuation.resume(returning: true)
                }
            }
        }
        
        // Only attempt to apply default data if the persistent stores loaded successfully
        if storeLoadedSuccessfully {
            try? DefaultData(viewContext: container.viewContext).apply()
        }
    }
    
    func handleStoreError() {
        errorMessage = AristaError.persistenceFailure.localizedDescription
        hasError = true
    }
}
