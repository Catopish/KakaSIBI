//
//  MachineLearningChallengeApp.swift
//  MachineLearningChallenge
//
//  Created by Al Amin Dwiesta on 11/06/25.
//

import SwiftUI

@main
struct MachineLearningChallengeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
        }
    }
}
