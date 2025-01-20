//
//  AddToDoView.swift
//  reminder
//
//  Created by Esad on 20.01.25.
//

import Foundation
import SwiftUI

struct AddToDoView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    @Environment(\.dismiss) var dismiss
    
    var reminderToEdit: ReminderEntity?
    
    @State private var title: String
    @State private var note: String
    @State private var dueDate: Date
    @State private var reminderOnDueDate: Bool
    @State private var reminderTime: Date
    @State private var enableReminderInterval: Bool
    @State private var selectedInterval: Int
    @State private var minuteInterval: Double
    @State private var hourInterval: Double
    @State private var dailyTime: Date
    @State private var weeklyTime: Date
    @State private var selectedDayOfWeek: Int
    
    init(reminderToEdit: ReminderEntity? = nil) {
        self.reminderToEdit = reminderToEdit
        _title = State(initialValue: reminderToEdit?.title ?? "")
        _note = State(initialValue: reminderToEdit?.note ?? "")
        let existingDueDate = reminderToEdit?.dueDate ?? Date()
        _dueDate = State(initialValue: Calendar.current.startOfDay(for: existingDueDate))
        _reminderOnDueDate = State(initialValue: reminderToEdit?.dueDate != nil)
        _reminderTime = State(initialValue: reminderToEdit?.dueDate ?? Date())
        _enableReminderInterval = State(initialValue: (reminderToEdit?.interval ?? -1) != -1)
        _selectedInterval = State(initialValue: Int(reminderToEdit?.interval ?? 0))
        _minuteInterval = State(initialValue: Double(reminderToEdit?.minuteInterval ?? 5))
        _hourInterval = State(initialValue: Double(reminderToEdit?.hourInterval ?? 1))
        _dailyTime = State(initialValue: reminderToEdit?.dailyTime ?? Date())
        _weeklyTime = State(initialValue: reminderToEdit?.weeklyTime ?? Date())
        _selectedDayOfWeek = State(initialValue: Int(reminderToEdit?.dayOfWeek ?? 0))
    }
    
    var body: some View {
        Form {
            Section(header: Text("Aufgabe Details")) {
                TextField("Titel", text: $title)
                TextEditor(text: $note)
                    .frame(height: 100)
                
                Toggle("Erinnerung am Fälligkeitsdatum", isOn: $reminderOnDueDate)
                
                if reminderOnDueDate {
                    DatePicker("Fälligkeitsdatum", selection: $dueDate, displayedComponents: [.date])
                        .environment(\.locale, Locale(identifier: "de_DE"))
                    DatePicker("Erinnerungszeit", selection: $reminderTime, displayedComponents: [.hourAndMinute])
                        .environment(\.locale, Locale(identifier: "de_DE"))
                }
                
                Toggle("Erinnerungsintervall aktivieren", isOn: $enableReminderInterval)
                
                if enableReminderInterval {
                    Picker("Intervall", selection: $selectedInterval) {
                        ForEach(Array(reminderIntervals.enumerated()), id: \.offset) { index, intervalText in
                            Text(intervalText).tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    switch selectedInterval {
                    case 0:
                        //Minuten
                        VStack {
                            let currentMinutes = Int(minuteInterval)
                            if currentMinutes == 1 {
                                Text("Intervall: 1 Minute")
                            } else {
                                Text("Intervall: \(currentMinutes) Minuten")
                            }
                            Slider(value: $minuteInterval, in: 1...60, step: 1)
                        }
                        
                    case 1:
                        // Stunden
                        VStack {
                            let currentHours = Int(hourInterval)
                            if currentHours == 1 {
                                Text("Intervall: 1 Stunde")
                            } else {
                                Text("Intervall: \(currentHours) Stunden")
                            }
                            Slider(value: $hourInterval, in: 1...24, step: 1)
                        }
                        
                    case 2:
                        // Täglich
                        DatePicker("Erinnerungszeit", selection: $dailyTime, displayedComponents: [.hourAndMinute])
                            .environment(\.locale, Locale(identifier: "de_DE"))
                        
                    case 3:
                        // Wöchentlich
                        Picker("Wochentag", selection: $selectedDayOfWeek) {
                            ForEach(Array(daysOfWeek.enumerated()), id: \.offset) { index, day in
                                Text(day).tag(index)
                            }
                        }
                        DatePicker("Erinnerungszeit", selection: $weeklyTime, displayedComponents: [.hourAndMinute])
                            .environment(\.locale, Locale(identifier: "de_DE"))

                    default:
                        EmptyView()
                    }
                }

            }
            
            Button("Speichern") {
                // combined due date
                let calendar = Calendar.current
                let combinedDueDate = calendar.date(
                    bySettingHour: calendar.component(.hour, from: reminderTime),
                    minute: calendar.component(.minute, from: reminderTime),
                    second: 0,
                    of: dueDate
                ) ?? dueDate
                
                if let reminderToEdit = reminderToEdit {
                    reminderToEdit.title = title
                    reminderToEdit.note = note
                    reminderToEdit.dueDate = reminderOnDueDate ? combinedDueDate : nil
                    reminderToEdit.interval = enableReminderInterval ? Int16(selectedInterval) : -1
                    reminderToEdit.minuteInterval = (selectedInterval == 0) ? Int16(minuteInterval) : 0
                    reminderToEdit.hourInterval = (selectedInterval == 1) ? Int16(hourInterval) : 0
                    reminderToEdit.dailyTime = (selectedInterval == 2) ? dailyTime : nil
                    reminderToEdit.weeklyTime = (selectedInterval == 3) ? weeklyTime : nil
                    reminderToEdit.dayOfWeek = (selectedInterval == 3) ? Int16(selectedDayOfWeek) : 0
                    
                    reminderManager.updateReminder(reminderToEdit)
                } else {
                    reminderManager.addReminder(
                        title: title,
                        note: note,
                        dueDate: reminderOnDueDate ? combinedDueDate : nil,
                        interval: enableReminderInterval ? Int16(selectedInterval) : -1,
                        minuteInterval: (selectedInterval == 0) ? Int16(minuteInterval) : nil,
                        hourInterval: (selectedInterval == 1) ? Int16(hourInterval) : nil,
                        dailyTime: (selectedInterval == 2) ? dailyTime : nil,
                        weeklyTime: (selectedInterval == 3) ? weeklyTime : nil,
                        dayOfWeek: (selectedInterval == 3) ? Int16(selectedDayOfWeek) : nil
                    )
                }
                
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .disabled(!isFormValid)
        }
        .navigationTitle(reminderToEdit == nil ? "Aufgabe hinzufügen" : "Aufgabe bearbeiten")
    }
    
    private var isFormValid: Bool {
        let titleTrimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let noteTrimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let hasTitleAndNote = !titleTrimmed.isEmpty && !noteTrimmed.isEmpty
        let hasAtLeastOneToggle = (reminderOnDueDate || enableReminderInterval)
        
        return hasTitleAndNote && hasAtLeastOneToggle
    }
    
}
