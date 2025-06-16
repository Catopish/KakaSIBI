//
//  PrimaryButtonStyle.swift
//  MachineLearningChallenge
//
//  Created by Al Amin Dwiesta on 13/06/25.
//

import SwiftUI

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
