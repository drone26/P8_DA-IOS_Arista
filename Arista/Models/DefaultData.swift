//
//  DefaultData.swift
//  Arista
//
//  Created by Mathieu ARRIO on 10/03/2026.
//  Modified by Mathieu Arrio on 06/03/2026.
//

import Foundation
import CoreData

struct DefaultData {
    let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    /// Apply default data to CoreData instance
    func apply() throws {
        let userRepository = UserRepository(viewContext: viewContext)
        let sleepRepository = SleepRepository(viewContext: viewContext)
        if (try? userRepository.getUser()) == nil {
            let initialUser = User(context: viewContext)
            initialUser.firstName = "Charlotte"
            initialUser.lastName = "Razoul"
            initialUser.email = "charlotte.razoul@example.com"
            initialUser.password = "password1234"
            initialUser.id = UUID()
            
            if try sleepRepository.getSleepSessions().isEmpty {
                let timeIntervalForADay: TimeInterval = 60 * 60 * 24
                
                for dayOffset in (1...5).reversed() {
                    let sleep = Sleep(context: viewContext)
                    sleep.id = UUID()
                    sleep.duration = (0...900).randomElement()!
                    sleep.quality = (0...10).randomElement()!
                    sleep.startDate = Date(timeIntervalSinceNow: -timeIntervalForADay * Double(dayOffset))
                    sleep.user = initialUser
                }
            }
            
            try? viewContext.save()
        }
    }
}
