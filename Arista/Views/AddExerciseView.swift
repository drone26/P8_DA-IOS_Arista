//
//  AddExerciseView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//  Modified by Mathieu Arrio on 05/03/2026.
//

import SwiftUI

struct AddExerciseView: View {
    @Environment(\.dismiss) var dismiss
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
                        
                        // Duration field with label on the left and input on the right
                        HStack {
                            Text("Durée (en minutes)")
                            Spacer()
                            TextField("Ex: 30", value: $viewModel.duration, format: .number)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                        }
                        if !viewModel.isDurationValid {
                            Text("La durée doit être supérieure à 0")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // Intensity field with label on the left and input on the right
                        HStack {
                            Text("Intensité (0 à 10)")
                            Spacer()
                            TextField("Ex: 5", value: $viewModel.intensity, format: .number)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                        }
                        if !viewModel.isIntensityValid {
                            Text("L'intensité doit être comprise entre 0 et 10")
                                .font(.caption)
                                .foregroundColor(.red)
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
                            dismiss()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isFormValid)
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
