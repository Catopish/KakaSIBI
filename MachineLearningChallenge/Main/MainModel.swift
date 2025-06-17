//
//  MainModel.swift
//  MachineLearningChallenge
//
//  Created by Al Amin Dwiesta on 13/06/25.
//

import Foundation

// MARK: - Model

struct Level: Identifiable {
    let id: Int
    let title: String
    let content: String
}

let levels: [Level] = [
    .init(id: 1,
          title: "Kata Ganti",
          content:
                  """
                  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor \
                  incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud \
                  exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute \
                  irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla \
                  pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia \
                  deserunt mollit anim id est laborum.
                  """
         ),
    .init(id: 2, title: "Level 2 Title", content: "Detail content for level 2..."),
    .init(id: 3, title: "Level 3 Title", content: "Detail content for level 3..."),
    .init(id: 4, title: "Level 4 Title", content: "Detail content for level 4..."),
    .init(id: 5, title: "Level 5 Title", content: "Detail content for level 5...")
]
