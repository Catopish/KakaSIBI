//
//  CircleLevelView.swift
//  MachineLearningChallenge
//
//  Created by Al Amin Dwiesta on 13/06/25.
//
import SwiftUI

// MARK: - Circle Indicator
struct RectangleLevelView: View {
    let levelID: Int
    let isSelected: Bool

    var body: some View {
        ZStack {
            Rectangle()
                .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .frame(width: 300, height: 200)
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
    RectangleLevelView(levelID: 2 ,isSelected: true)
        .frame(minWidth: 600, minHeight: 400)
}
