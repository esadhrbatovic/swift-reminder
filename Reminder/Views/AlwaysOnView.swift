//
//  AlwaysOnView.swift
//  reminder
//
//  Created by Esad on 20.01.25.
//
import Foundation
import SwiftUI
import CoreData

struct AlwaysOnView: View {
    @EnvironmentObject var reminderManager: ReminderManager

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.dueDate, order: .forward) // Sort by dueDate ascending
        ],
        predicate: NSPredicate(format: "id != nil && dueDate == nil && completedDate == nil && interval != -1"),
        animation: .default
    ) private var alwaysOnReminders: FetchedResults<ReminderEntity>
    
    @State private var editReminder: ReminderEntity?
    @State private var isEditing = false
    
    private let reminderIntervals = ["Alle paar Minuten", "Alle paar Stunden", "Täglich", "Wöchentlich"]

    var body: some View {
        List {
        
            ForEach(0..<reminderIntervals.count, id: \.self) { intervalIndex in
                let group = alwaysOnReminders.filter { $0.interval == Int16(intervalIndex) }
                if !group.isEmpty {
                    Section(header: Text(reminderIntervals[intervalIndex])) {
                        ForEach(group) { reminder in
                            VStack(alignment: .leading) {
                                Text(reminder.title)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                if let intervalText = intervalText(reminder) {
                                    Text(intervalText)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                if let note = reminder.note, !note.isEmpty {
                                    Text(note)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editReminder = reminder
                                isEditing = true
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    DispatchQueue.main.async {
                                        reminderManager.deleteReminder(reminder)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                        }
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
            if !newValue { editReminder = nil }
        }
    }

    func intervalText(_ reminder: ReminderEntity) -> String? {
        let i = Int(reminder.interval)
        switch i {
        case 0:
            // "Alle paar Minuten"
            let minutes = reminder.minuteInterval
            if minutes == 1 {
                return "Jede Minute"
            } else {
                return "Alle \(minutes) Minuten"
            }

        case 1:
            // "Alle paar Stunden"
            let hours = reminder.hourInterval
            if hours == 1 {
                return "Jede Stunde"
            } else {
                return "Alle \(hours) Stunden"
            }

        case 2:
            // "Täglich"
            if let time = reminder.dailyTime {
                return "Täglich um \(DateFormatter.localizedGermanTimeFormatter.string(from: time))"
            }

        case 3:
            // "Wöchentlich"
            if let time = reminder.weeklyTime {
                let weekdayIndex = Int(reminder.dayOfWeek)
                guard weekdayIndex >= 0 && weekdayIndex < daysOfWeek.count else { return nil }
                let weekday = daysOfWeek[weekdayIndex]
                let timeString = DateFormatter.localizedGermanTimeFormatter.string(from: time)
                return "Jeden \(weekday) um \(timeString)"
            }

        default:
            return nil
        }
        return nil
    }

}

