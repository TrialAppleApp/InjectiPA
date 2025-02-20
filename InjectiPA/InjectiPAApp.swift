//
//  InjectiPAApp.swift
//  InjectiPA
//
//  Created by TrialMacApp on 2025-02-17.
//

import Sparkle
import SwiftUI

@main
struct InjectiPAApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: UpdaterManager.shared.updater)
            }
            
            CommandGroup(replacing: .help) {
                Link("GitHub", destination: URL(string: "https://github.com/TrialAppleApp/InjectiPA/")!)
            }
        }
    }
}

