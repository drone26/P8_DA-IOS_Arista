//
//  ExerciseListView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//  Modified by Mathieu Arrio on 05/03/2026.
//

import SwiftUI

struct ExerciseListView: View {
    var viewModel: ExerciseListViewModel
    @State private var showingAddExerciseView = false
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        NavigationStack {
            List {
                ForEach(viewModel.exercises, id: \.self) { exercise in
                    HStack {
                        Image(systemName: exercise.iconName)
                        VStack(alignment: .leading) {
                            Text(exercise.wrappedCategory)
                                .font(.headline)
                            Text("Durée: \(exercise.wrappedDuration) min")
                                .font(.subheadline)
                            Text(exercise.wrappedFormattedStartDate)
                                .font(.subheadline)
                        }
                        Spacer()
                        IntensityIndicator(intensity: Int(exercise.wrappedIntensity))
                    }
                    .listRowBackground(Color.white.opacity(0.1))
                }
                .onDelete { offsets in
                    Task { await viewModel.deleteExercise(at: offsets) }
                }            }
            .navigationTitle("Exercices")
            .scrollContentBackground(.hidden)
            .background {
                LiquidGlassBackground()
            }
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddExerciseView = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .task {
                await viewModel.fetchExercises()
            }        }
        .alert("Erreur", isPresented: $viewModel.hasError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Une erreur inconnue est survenue.")
        }
        .sheet(isPresented: $showingAddExerciseView, onDismiss: {
            Task { await viewModel.fetchExercises() }
        }) {
            AddExerciseView(viewModel: AddExerciseViewModel(context: viewModel.viewContext))
        }
    }
}

struct IntensityIndicator: View {
    var intensity: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(colorForIntensity(intensity), lineWidth: 5)
                .foregroundColor(colorForIntensity(intensity))
                .frame(width: 30, height: 30)
            Text("\(intensity)")
                .foregroundColor(colorForIntensity(intensity))
        }
    }
    
    func colorForIntensity(_ intensity: Int) -> Color {
        switch intensity {
        case 0...3:
            return .green
        case 4...6:
            return .yellow
        case 7...10:
            return .red
        default:
            return .gray
        }
    }
}

#Preview {
    ExerciseListView(viewModel: ExerciseListViewModel(context: PersistenceController(inMemory: true).container.viewContext))
}
