//
//  LiquidGlassCommon.swift
//  Arista
//
//  Created by Mathieu ARRIO on 12/03/2026.
//

import SwiftUI

extension Color {
    static let deepPurple = Color(red: 0.1, green: 0.0, blue: 0.2)
}

struct LiquidGlassBackground: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.aristaBlue.opacity(0.7), .aristaBlue.opacity(0.0)]), startPoint: .top, endPoint: .bottomLeading)
            .edgesIgnoringSafeArea(.all)
            .accessibilityHidden(true)
    }
}

struct CustomGlassTextField: View {
    let placeholder: String
    @Binding var text: String
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.2)))
    }
}

#Preview {
    LiquidGlassBackground()
}
