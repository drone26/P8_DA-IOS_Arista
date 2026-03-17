//
//  AddExerciseView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct AddExerciseView: View {
    @Environment(\.presentationMode) var presentationMode
    var viewModel: AddExerciseViewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        NavigationStack {
            VStack {
                Form {
                    Section {
                        Picker("Catégorie", selection: $viewModel.category) {
                            ForEach(ExerciseCategory.allCases) { category in
                                Label(category.rawValue, systemImage: category.iconName)
                                    .tag(category)
                            }
                        }
                        
                        DatePicker(
                            "Sélectionnes une date et une heure",
                            selection: $viewModel.startDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        
                        // Champ Durée avec label à gauche et saisie à droite
                        HStack {
                            Text("Durée (en minutes)")
                            Spacer()
                            TextField("Ex: 30", value: $viewModel.duration, format: .number)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                        }
                        
                        // Champ Intensité avec label à gauche et saisie à droite
                        HStack {
                            Text("Intensité (0 à 10)")
                            Spacer()
                            TextField("Ex: 5", value: $viewModel.intensity, format: .number)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.1))
                }.formStyle(.grouped)
                
                Spacer()
                
                Button("Ajouter l'exercice") {
                    // Button action is a sync closure; bridge to async with an
                    // unstructured Task. The Task inherits @MainActor isolation
                    // from the view's context, so the dismiss call stays on main thread.
                    Task {
                        if await viewModel.addExercise() {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }.buttonStyle(.borderedProminent)
            }
            .navigationTitle("Nouvel Exercice ...")
            .scrollContentBackground(.hidden)
            .background {
                LiquidGlassBackground()
            }
        }
    }
}

#Preview {
    AddExerciseView(viewModel: AddExerciseViewModel(context: PersistenceController(inMemory: true).container.viewContext))
}
