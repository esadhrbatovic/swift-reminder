//
//  DoneView.swift
//  reminder
//
//  Created by Esad on 20.01.25.
//

import Foundation
import Foundation
import SwiftUI
import CoreData


struct DoneView: View {
    @EnvironmentObject var reminderManager: ReminderManager

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.completedDate, order: .reverse)],
        predicate: NSPredicate(format: "completedDate != nil"),
        animation: .default
    ) private var doneReminders: FetchedResults<ReminderEntity>

    var body: some View {
        List {
            ForEach(doneReminders) { reminder in
                VStack(alignment: .leading) {
                    Text(reminder.title)
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    if let completed = reminder.completedDate {
                        Text("Abgeschlossen am: \(DateFormatter.localizedDateFormatter.string(from: completed))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        DispatchQueue.main.async {
                            reminderManager.deleteReminder(reminder)
                        }
                    } label: {
                        Label("Löschen", systemImage: "trash")
                    }
                }
            }
        }
    }
}
