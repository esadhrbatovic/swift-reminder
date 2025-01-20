//
//  ToDoView.swift
//  reminder
//
//  Created by Esad on 20.01.25.
//

import Foundation
import SwiftUI
import CoreData

struct ToDoView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.dueDate, order: .forward)
        ],
        predicate: NSPredicate(format: "id != nil && dueDate != nil && completedDate == nil"),
        animation: .default
    ) private var toDoReminders: FetchedResults<ReminderEntity>
    
    @State private var editReminder: ReminderEntity?
    @State private var isEditing = false
    
    var body: some View {
        List {
            ForEach(toDoReminders) { reminder in
                Button {
                    editReminder = reminder
                    isEditing = true
                } label: {
                    VStack(alignment: .leading) {
                        Text(reminder.title)
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        if let note = reminder.note, !note.isEmpty {
                            Text(note)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let dueDate = reminder.dueDate {
                            Text("Fällig am: \(DateFormatter.localizedDateFormatter.string(from: dueDate))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        let intervalVal = Int(reminder.interval)
                        if intervalVal > 0 && intervalVal < reminderIntervals.count {
                            Text("Intervall: \(reminderIntervals[intervalVal])")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        reminderManager.completeReminder(reminder)
                    } label: {
                        Label("Complete", systemImage: "checkmark.circle.fill")
                    }
                    .tint(.green)
                    
                    Button(role: .destructive) {
                        if editReminder == reminder {
                            isEditing = false
                            editReminder = nil
                        }
                        DispatchQueue.main.async {

                            reminderManager.deleteReminder(reminder)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                }
            }
        }
        .background(
            NavigationLink(
                destination: AddToDoView(reminderToEdit: editReminder),
                isActive: $isEditing
            ) {
                EmptyView()
            }
            .hidden()
        )
        .onChange(of: isEditing) { newValue in
            if !newValue {
                editReminder = nil
            }
        }
    }
}
