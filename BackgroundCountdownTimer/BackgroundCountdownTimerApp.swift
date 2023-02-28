//
//  BackgroundCountdownTimerApp.swift
//  BackgroundCountdownTimer
//
//  Created by 仲純平 on 2023/02/28.
//

import SwiftUI

@main
struct BackgroundCountdownTimerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
