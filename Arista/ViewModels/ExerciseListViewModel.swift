//
//  ExerciseListViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//  Modified by Mathieu Arrio on 05/03/2026.
//

import CoreData
import SwiftUI

@MainActor
@Observable
class ExerciseListViewModel {
    var exercises = [Exercise]()
    var errorMessage: String?
    var hasError: Bool = false

    let viewContext: NSManagedObjectContext
    private let repository: any ExerciseRepositoryProtocol

    init(context: NSManagedObjectContext, repository: (any ExerciseRepositoryProtocol)? = nil) {
        self.viewContext = context
        self.repository = repository ?? ExerciseRepository(viewContext: context)
        Task { await fetchExercises() }
    }

    /// Fetch exercises
    func fetchExercises() async {
        do {
            exercises = try repository.getExercises()
        } catch {
            self.errorMessage = AristaError.fetchFailed.localizedDescription
            self.hasError = true
        }
    }
    
    /// Delete an exercise
    /// - Parameter offsets: index of the exercise to delete
    func deleteExercise(at offsets: IndexSet) async {
        do {
            for index in offsets {
                try repository.deleteExercise(exercises[index])
            }
            await fetchExercises()
        } catch {
            self.errorMessage = AristaError.saveFailed.localizedDescription
            self.hasError = true
        }
    }
}
