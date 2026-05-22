//
//  ExerciseRepository.swift
//  Arista
//
//  Created by Mathieu ARRIO on 05/03/2026.
//

import Foundation
import CoreData

extension Exercise {
    /// Safe access to the category with a default 'Free' fallback.
    var wrappedCategory: String {
        category ?? "Free"
    }
    
    /// Provides the category icon directly from the enum.
    var iconName: String {
        ExerciseCategory(rawValue: wrappedCategory)?.iconName ?? "figure.run.square.stack"
    }
    
    /// Safe access to the start date.
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
    
    /// Safe access to the duration.
    var wrappedDuration: Int {
        Int(duration)
    }
    
    /// Safe access to the duration.
    var wrappedIntensity: Int {
        Int(intensity)
    }
}

enum ExerciseCategory: String, CaseIterable, Identifiable {
    case football = "Football"
    case swimming = "Natation"
    case running = "Running"
    case walking = "Marche"
    case biking = "Cyclisme"
    case free = "Libre"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .football: return "sportscourt"
        case .swimming: return "figure.pool.swim"
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .biking: return "figure.outdoor.cycle"
        case .free: return "figure.run.square.stack"
        }
    }
}

struct ExerciseRepository {
    let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    init() {
        self.viewContext = PersistenceController.shared.container.viewContext
    }
    
    func getExercises() throws -> [Exercise] {
        let request = Exercise.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(SortDescriptor<Exercise>(\.startDate, order: .reverse))]
        request.fetchBatchSize = 20
        return try viewContext.fetch(request)
    }
    
    func addExercise(category: String, duration: Int, intensity: Int, startDate: Date, user: User) throws {
        let newExercise = Exercise(context: viewContext)
        newExercise.id = UUID()
        newExercise.category = category
        newExercise.duration = Int64(duration)
        newExercise.intensity = Int64(intensity)
        newExercise.startDate = startDate
        newExercise.user = user
        try viewContext.save()
    }
    
    func deleteExercise(_ exercise: Exercise) throws {
        viewContext.delete(exercise)
        try viewContext.save()
    }

    func deleteExercises(_ exercises: [Exercise]) throws {
        guard !exercises.isEmpty else { return }
        let objectIDs = exercises.map { $0.objectID }
        let batchDeleteRequest = NSBatchDeleteRequest(objectIDs: objectIDs)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        let result = try viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
        if let deletedObjectIDs = result?.result as? [NSManagedObjectID] {
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                into: [viewContext]
            )
        }
    }
}

