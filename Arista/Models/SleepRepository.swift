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
    
    /// Static DateFormatter to avoid reallocating formatting objects.
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    /// Safe access to the start date in formatted string format.
    var wrappedFormattedStartDate: String {
        Self.dateFormatter.string(from: wrappedStartDate)
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
    
    /// Fetch / Get all sleep sessions
    /// - Returns: array of Sleep sessions
    func getSleepSessions() throws -> [Sleep] {
        let request = Sleep.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(SortDescriptor<Sleep>(\.startDate, order: .reverse))]
        request.fetchBatchSize = 20
        return try viewContext.fetch(request)
    }
}

