//
//  SleepRepository.swift
//  Arista
//
//  Created by Mathieu ARRIO on 10/03/2026.
//

import Foundation
import CoreData

extension Sleep {
    /// Safe access to the startDate.
    var wrappedStartDate: Date {
        startDate ?? Date()
    }
    
    /// Safe access to the start date in formatted string format.
    var wrappedFormattedStartDate: String {
        wrappedStartDate.formatted()
    }
    
    /// Safe access to the duration
    var wrappedDuration: Int {
        Int(duration)
    }
    
    /// Safe access to the duration
    var wrappedDurationInHour: String {
        let hours = Double(duration) / 60.0
        return String(format: "Durée : %.1f heures", hours)
    }
    
    /// Safe access to quality (Int64 to Int)
    var wrappedQuality: Int {
        Int(quality)
    }
}

struct SleepRepository {
    let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func getSleepSessions() throws -> [Sleep] {
        let request = Sleep.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(SortDescriptor<Sleep>(\.startDate, order: .reverse))]
        return try viewContext.fetch(request)
    }
}

