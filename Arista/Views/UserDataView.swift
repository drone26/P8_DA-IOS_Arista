//
//  UserDataView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//  Modified by Mathieu Arrio on 12/03/2026.
//

import SwiftUI

struct UserDataView: View {
    var viewModel: UserDataViewModel

    var body: some View {
        @Bindable var viewModel = viewModel
        ZStack {
            LiquidGlassBackground()

            VStack(alignment: .leading) {
                Spacer()

                // "Hello" + nom combinés en un seul élément pour VoiceOver
                VStack(alignment: .leading, spacing: 0) {
                    Text("Hello")
                        .font(.largeTitle)
                        .foregroundColor(.primary)
                    Text("\(viewModel.firstName) \(viewModel.lastName)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .padding()
                        .scaleEffect(1.2)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Hello, \(viewModel.firstName) \(viewModel.lastName)")

                Spacer()
            }
            .edgesIgnoringSafeArea(.all)
            .task {
                await viewModel.fetchUserData()
            }
        }
    }
}

#Preview {
    UserDataView(viewModel: UserDataViewModel(context: PersistenceController(inMemory: true).container.viewContext))
}
