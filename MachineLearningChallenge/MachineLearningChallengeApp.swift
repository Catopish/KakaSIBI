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
    //MARK: GATAU CARA APUS APPSTORAGE/APPNYA COMMENT/Uncomment ini buat hapus appstorage for now
    private let shouldWipeAppStorage = true

    init() {
        #if DEBUG
        if shouldWipeAppStorage {
            let bundleID = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
            print("🔨 AppStorage wiped for \(bundleID)")
        }
        #endif
    }
    var body: some Scene {
        WindowGroup {
            GamePreview()
//            ContentView()
                .frame(minWidth: 800, minHeight: 600)
        }
    }
}
