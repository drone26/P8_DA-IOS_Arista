//
//  AristaApp.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

@main
struct AristaApp: App {
    var persistenceController = PersistenceController.shared

    @State private var userDataViewModel: UserDataViewModel
    @State private var exerciseListViewModel: ExerciseListViewModel
    @State private var sleepHistoryViewModel: SleepHistoryViewModel

    init() {
        let context = PersistenceController.shared.container.viewContext
        _userDataViewModel = State(initialValue: UserDataViewModel(context: context))
        _exerciseListViewModel = State(initialValue: ExerciseListViewModel(context: context))
        _sleepHistoryViewModel = State(initialValue: SleepHistoryViewModel(context: context))
    }

    var body: some Scene {
        WindowGroup {
            @Bindable var bindableController = persistenceController

            TabView {
                UserDataView(viewModel: userDataViewModel)
                    .tabItem { Label("Utilisateur", systemImage: "person") }

                ExerciseListView(viewModel: exerciseListViewModel)
                    .tabItem { Label("Exercices", systemImage: "flame") }

                SleepHistoryView(viewModel: sleepHistoryViewModel)
                    .tabItem { Label("Sommeil", systemImage: "moon") }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .alert("Erreur Système", isPresented: $bindableController.hasError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(bindableController.errorMessage ?? "Une erreur critique est survenue avec la base de données.")
            }
            // loadStores() is called here so it can be awaited properly.
            // Keeping it out of PersistenceController.init() prevents
            // uncontrolled Tasks that race with tests or the SwiftUI lifecycle.
            .task {
                await persistenceController.loadStores()
            }
        }
    }
}
