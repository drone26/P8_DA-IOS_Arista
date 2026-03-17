//
//  SleepHistoryViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

@MainActor
@Observable
class SleepHistoryViewModel {
    var sleepSessions = [Sleep]()
    var errorMessage: String?
    var hasError: Bool = false

    let viewContext: NSManagedObjectContext
    private let repository: any SleepRepositoryProtocol

    init(context: NSManagedObjectContext, repository: (any SleepRepositoryProtocol)? = nil) {
        self.viewContext = context
        self.repository = repository ?? SleepRepository(viewContext: context)
    }

    func fetchSleepSessions() async {
        do {
            sleepSessions = try repository.getSleepSessions()
        } catch {
            self.errorMessage = AristaError.fetchFailed.localizedDescription
            self.hasError = true
        }
    }
}
