//
//  reminderApp.swift
//  reminder
//
//  Created by Esad on 05.11.24.
//

import SwiftUI
import CoreData

@main
struct ReminderApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(ReminderManager(context: persistenceController.container.viewContext))
        }
    }
}
