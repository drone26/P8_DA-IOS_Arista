//
//  RepositoryProtocols.swift
//  Arista
//
//  Created by Mathieu ARRIO on 14/03/2026.
//

import Foundation
import CoreData

// MARK: - Protocols

protocol ExerciseRepositoryProtocol {
    func getExercises() throws -> [Exercise]
    func addExercise(category: String, duration: Int, intensity: Int, startDate: Date, user: User) throws
    func deleteExercise(_ exercise: Exercise) throws
    func deleteExercises(_ exercises: [Exercise]) throws
}

protocol SleepRepositoryProtocol {
    func getSleepSessions() throws -> [Sleep]
}

protocol UserRepositoryProtocol {
    func getUser() throws -> User?
}

// MARK: - Conformances (no logic changes)

extension ExerciseRepository: ExerciseRepositoryProtocol {}
extension SleepRepository: SleepRepositoryProtocol {}
extension UserRepository: UserRepositoryProtocol {}
