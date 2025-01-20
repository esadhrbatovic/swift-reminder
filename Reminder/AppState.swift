//
//  AppState.swift
//  reminder
//
//  Created by Esad on 20.01.25.
//

import Foundation
import Combine
import CoreData

class AppState: ObservableObject {
    @Published var selectedReminder: ReminderEntity? = nil
}

