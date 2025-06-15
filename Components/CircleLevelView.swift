//
//  CircleLevelView.swift
//  MachineLearningChallenge
//
//  Created by Al Amin Dwiesta on 13/06/25.
//
import SwiftUI

// MARK: - Circle Indicator
struct CircleLevelView: View {
    let levelID: Int
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .frame(width: 50, height: 50)
            Text("\(levelID)")
                .font(.headline)
                .foregroundColor(isSelected ? .white : .black)
        }
        .shadow(color: isSelected ? Color.blue.opacity(0.4) : .clear,
                radius: 4, x: 0, y: 2)
        .animation(nil, value: isSelected)
    }
}

#Preview {
    CircleLevelView(levelID: 2 ,isSelected: true)
        .frame(minWidth: 100, minHeight: 100)
}
