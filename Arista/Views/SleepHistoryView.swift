//
//  SleepHistoryView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//  Modified by Mathieu Arrio on 05/03/2026.
//

import SwiftUI

struct SleepHistoryView: View {
    var viewModel: SleepHistoryViewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        NavigationStack {
            List(viewModel.sleepSessions) { session in
                HStack {
                    
                    VStack(alignment: .leading) {
                        Text("Début : \(session.wrappedFormattedStartDate)")
                            .font(.headline)
                        Text(session.wrappedDurationInHour)
                            .font(.subheadline)
                    }
                    Spacer()
                    QualityIndicator(quality: Int(session.wrappedQuality))
                }
                .listRowBackground(Color.white.opacity(0.1))
            }
            .navigationTitle("Historique de Sommeil")
            .scrollContentBackground(.hidden)
            .background {
                LiquidGlassBackground()
            }
        }
        .task {
            // Fetch sleep sessions when view appear
            await viewModel.fetchSleepSessions()
        }
        
    }
}

struct QualityIndicator: View {
    let quality: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(qualityColor(quality), lineWidth: 5)
                .foregroundColor(qualityColor(quality))
                .frame(width: 30, height: 30)
            Text("\(quality)")
                .foregroundColor(qualityColor(quality))
        }
    }
    
    func qualityColor(_ quality: Int) -> Color {
        switch (10-quality) {
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
    SleepHistoryView(viewModel: SleepHistoryViewModel(context: PersistenceController(inMemory: true).container.viewContext))
}
