//
//  AppModel.swift
//  MachineLearningChallenge
//
//  Created by Al Amin Dwiesta on 12/06/25.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Optionally toggle as soon as the app finishes launching:
        toggleFullScreen()
    }

    func toggleFullScreen() {
        // Grab the key/main window and toggle fullscreen
        if let window = NSApp.keyWindow ?? NSApp.windows.first {
            window.toggleFullScreen(nil)
        }
    }
}
