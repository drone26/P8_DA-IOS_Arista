//
//  AddExerciseViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData
import Observation

@MainActor
@Observable
class AddExerciseViewModel {
    var category: ExerciseCategory = .free
    var startDate: Date = Date()
    var duration: Int = 0
    var intensity: Int = 0
    var errorMessage: String?
    var hasError: Bool = false

    let viewContext: NSManagedObjectContext
    private let exerciseRepository: any ExerciseRepositoryProtocol
    private let userRepository: any UserRepositoryProtocol

    init(context: NSManagedObjectContext,
         exerciseRepository: (any ExerciseRepositoryProtocol)? = nil,
         userRepository: (any UserRepositoryProtocol)? = nil) {
        self.viewContext = context
        self.exerciseRepository = exerciseRepository ?? ExerciseRepository(viewContext: context)
        self.userRepository = userRepository ?? UserRepository(viewContext: context)
    }

    func addExercise() async -> Bool {
        do {
            guard let user = try userRepository.getUser() else {
                self.errorMessage = AristaError.fetchFailed.localizedDescription
                self.hasError = true
                return false
            }
            try exerciseRepository.addExercise(
                category: category.rawValue,
                duration: duration,
                intensity: intensity,
                startDate: startDate,
                user: user
            )
            return true
        } catch {
            self.errorMessage = AristaError.saveFailed.localizedDescription
            self.hasError = true
            return false
        }
    }
}
