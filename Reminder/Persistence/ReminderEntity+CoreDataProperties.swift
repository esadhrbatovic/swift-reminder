//
//  ReminderEntity+CoreDataProperties.swift
//  reminder
//
//  Created by Esad on 20.01.25.
//
//

import Foundation
import CoreData


extension ReminderEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReminderEntity> {
        return NSFetchRequest<ReminderEntity>(entityName: "ReminderEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var note: String
    @NSManaged public var dueDate: Date?
    @NSManaged public var interval: Int16
    @NSManaged public var minuteInterval: Int16
    @NSManaged public var hourInterval: Int16
    @NSManaged public var dailyTime: Date?
    @NSManaged public var weeklyTime: Date?
    @NSManaged public var dayOfWeek: Int16
    @NSManaged public var completedDate: Date?

}

extension ReminderEntity : Identifiable {

}
