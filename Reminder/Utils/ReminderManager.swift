//
//  ReminderManager.swift
//  reminder
//
//  Created by Esad on 20.01.25.
//
//

import Foundation
import UserNotifications
import CoreData

class ReminderManager: ObservableObject {
    @Published var completionMessage: String?

    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        requestNotificationPermission()
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            } else if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    func addReminder(
        title: String,
        note: String,
        dueDate: Date?,
        interval: Int16?,
        minuteInterval: Int16?,
        hourInterval: Int16?,
        dailyTime: Date?,
        weeklyTime: Date?,
        dayOfWeek: Int16?
    ) {
        let newReminder = ReminderEntity(context: context)
        newReminder.id = UUID()
        newReminder.title = title
        newReminder.note = note
        newReminder.dueDate = dueDate
        newReminder.interval = interval ?? -1
        newReminder.minuteInterval = minuteInterval ?? -1
        newReminder.hourInterval = hourInterval ?? -1
        newReminder.dailyTime = dailyTime
        newReminder.weeklyTime = weeklyTime
        newReminder.dayOfWeek = dayOfWeek ?? -1
        newReminder.completedDate = nil

        do {
            try context.save()
            scheduleNotifications(for: newReminder)
        } catch {
            print("Error saving new reminder: \(error)")
        }
    }
    
    func updateReminder(_ reminder: ReminderEntity) {
        removeNotifications(for: reminder)
        scheduleNotifications(for: reminder)
        
        do {
            try context.save()
        } catch {
            print("Error updating reminder: \(error)")
        }
    }
    
    func deleteReminder(_ reminder: ReminderEntity) {
        
        removeNotifications(for: reminder)
        context.delete(reminder)
        do {
            try context.save()
        } catch {
            print("Error deleting reminder: \(error)")
        }
    }
    
    func completeReminder(_ reminder: ReminderEntity) {
        reminder.completedDate = Date()
        removeNotifications(for: reminder)
        
        do {
            try context.save()
        } catch {
            print("Error marking reminder complete: \(error)")
        }
        
        completionMessage = "Good job!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.completionMessage = nil
        }
    }
    
    func scheduleNotifications(for reminder: ReminderEntity) {
        let reminderID = reminder.id

        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.note
        content.sound = .default

        var triggers: [UNNotificationTrigger] = []

        // one time notification
        if let dueDate = reminder.dueDate {
            let comps = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: dueDate
            )
            let oneTimeTrigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let oneTimeRequest = UNNotificationRequest(
                identifier: reminderID.uuidString + "_dueDate",
                content: content,
                trigger: oneTimeTrigger
            )
            triggers.append(oneTimeTrigger)
            UNUserNotificationCenter.current().add(oneTimeRequest) { error in
                if let error = error {
                    print("Error scheduling one-time notification: \(error)")
                }
            }
        }

        // schedule repeating notification
        if reminder.interval != -1 {
            let repeatRequestID = reminderID.uuidString + "_interval"
            switch reminder.interval {
            case 0:
                // "Alle paar Minuten"
                let minutes = reminder.minuteInterval
                guard minutes > 0 else { break }
                let intervalInSeconds = Double(minutes) * 60
                let intervalTrigger = UNTimeIntervalNotificationTrigger(timeInterval: intervalInSeconds, repeats: true)
                let intervalRequest = UNNotificationRequest(
                    identifier: repeatRequestID,
                    content: content,
                    trigger: intervalTrigger
                )
                triggers.append(intervalTrigger)
                UNUserNotificationCenter.current().add(intervalRequest) { error in
                    if let error = error {
                        print("Error scheduling minute-interval notification: \(error)")
                    }
                }
                
            case 1:
                // "Alle paar Stunden"
                let hours = reminder.hourInterval
                guard hours > 0 else { break }
                let intervalInSeconds = Double(hours) * 3600
                let intervalTrigger = UNTimeIntervalNotificationTrigger(timeInterval: intervalInSeconds, repeats: true)
                let intervalRequest = UNNotificationRequest(
                    identifier: repeatRequestID,
                    content: content,
                    trigger: intervalTrigger
                )
                triggers.append(intervalTrigger)
                UNUserNotificationCenter.current().add(intervalRequest) { error in
                    if let error = error {
                        print("Error scheduling hour-interval notification: \(error)")
                    }
                }
                
            case 2:
                // "Täglich"
                if let dailyTime = reminder.dailyTime {
                    let comps = Calendar.current.dateComponents([.hour, .minute], from: dailyTime)
                    let dailyTrigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
                    let dailyRequest = UNNotificationRequest(
                        identifier: repeatRequestID,
                        content: content,
                        trigger: dailyTrigger
                    )
                    triggers.append(dailyTrigger)
                    UNUserNotificationCenter.current().add(dailyRequest) { error in
                        if let error = error {
                            print("Error scheduling daily notification: \(error)")
                        }
                    }
                }
                
            case 3:
                // "Wöchentlich" 
                if let weeklyTime = reminder.weeklyTime {
                    let weekday = reminder.dayOfWeek // Assuming 1 = Sunday, 2 = Monday
                    guard weekday >= 1 && weekday <= 7 else { break }
                    var comps = Calendar.current.dateComponents([.hour, .minute], from: weeklyTime)
                    comps.weekday = Int(reminder.dayOfWeek)
                    let weeklyTrigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
                    let weeklyRequest = UNNotificationRequest(
                        identifier: repeatRequestID,
                        content: content,
                        trigger: weeklyTrigger
                    )
                    triggers.append(weeklyTrigger)
                    UNUserNotificationCenter.current().add(weeklyRequest) { error in
                        if let error = error {
                            print("Error scheduling weekly notification: \(error)")
                        }
                    }
                }
                
            default:
                break
            }
        }

    }
    
    func removeNotifications(for reminder: ReminderEntity) {
        let reminderID = reminder.id
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [
                reminderID.uuidString + "_dueDate",
                reminderID.uuidString + "_interval"
            ]
        )
    }
}

