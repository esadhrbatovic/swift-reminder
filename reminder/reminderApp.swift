//
//  reminderApp.swift
//  reminder
//
//  Created by Esad on 05.11.24.
//

import SwiftUI


@main
struct ReminderApp: App {
    @StateObject private var reminderManager = ReminderManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(reminderManager)
        }
    }
}


