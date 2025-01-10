import SwiftUI
import UserNotifications

let reminderIntervals = ["Alle paar Minuten", "Alle paar Stunden", "Jeden Tag", "Wöchentlich"]
let daysOfWeek = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]

struct ContentView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            VStack {
                if let message = reminderManager.completionMessage {
                    Text(message)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding([.top, .horizontal])
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut)
                }

                TabView(selection: $selectedTab) {
                    ToDoView()
                        .tabItem {
                            Label("To-Do", systemImage: "list.bullet")
                        }
                        .tag(0)

                    AlwaysOnView()
                        .tabItem {
                            Label("Always On", systemImage: "infinity")
                        }
                        .tag(1)

                    DoneView()
                        .tabItem {
                            Label("Erledigt", systemImage: "checkmark.circle")
                        }
                        .tag(2)

                    PomodoroView()
                        .tabItem {
                            Label("Pomodoro", systemImage: "timer")
                        }
                        .tag(3)
                }
                .navigationTitle(navigationTitle)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: AddToDoView()) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                        }
                    }
                }
            }
        }
    }
    
    private var navigationTitle: String {
        switch selectedTab {
        case 0: return "To-Do"
        case 1: return "Always On"
        case 2: return "Erledigt"
        case 3: return "Pomodoro"
        default: return "Erinnerungen"
        }
    }
}


struct AddToDoView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    @Environment(\.presentationMode) var presentationMode

    var reminderToEdit: Reminder?
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
    
    init(reminderToEdit: Reminder? = nil) {
        self.reminderToEdit = reminderToEdit
        _title = State(initialValue: reminderToEdit?.title ?? "")
        _note = State(initialValue: reminderToEdit?.note ?? "")
        _dueDate = State(initialValue: Calendar.current.startOfDay(for: reminderToEdit?.dueDate ?? Date()))
        _reminderOnDueDate = State(initialValue: reminderToEdit?.dueDate != nil)
        _reminderTime = State(initialValue: reminderToEdit?.dueDate ?? Date())
        _enableReminderInterval = State(initialValue: reminderToEdit?.interval != nil)
        _selectedInterval = State(initialValue: reminderToEdit?.interval ?? 0)
        _minuteInterval = State(initialValue: Double(reminderToEdit?.minuteInterval ?? 5))
        _hourInterval = State(initialValue: Double(reminderToEdit?.hourInterval ?? 1))
        _dailyTime = State(initialValue: reminderToEdit?.dailyTime ?? Date())
        _weeklyTime = State(initialValue: reminderToEdit?.weeklyTime ?? Date())
        _selectedDayOfWeek = State(initialValue: reminderToEdit?.dayOfWeek ?? 0)
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
                        ForEach(0..<reminderIntervals.count) { index in
                            Text(reminderIntervals[index]).tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    if selectedInterval == 0 {
                        VStack {
                            Text("Intervall: \(Int(minuteInterval)) Minuten")
                            Slider(value: $minuteInterval, in: 1...60, step: 1)
                        }
                    } else if selectedInterval == 1 {
                        VStack {
                            Text("Intervall: \(Int(hourInterval)) Stunden")
                            Slider(value: $hourInterval, in: 1...24, step: 1)
                        }
                    } else if selectedInterval == 2 {
                        DatePicker("Erinnerungszeit", selection: $dailyTime, displayedComponents: [.hourAndMinute])
                            .environment(\.locale, Locale(identifier: "de_DE"))
                    } else if selectedInterval == 3 {
                        Picker("Wochentag", selection: $selectedDayOfWeek) {
                            ForEach(0..<daysOfWeek.count) { index in
                                Text(daysOfWeek[index]).tag(index)
                            }
                        }
                        DatePicker("Erinnerungszeit", selection: $weeklyTime, displayedComponents: [.hourAndMinute])
                            .environment(\.locale, Locale(identifier: "de_DE"))
                    }
                }
            }
            Button("Speichern") {
                var calendar = Calendar.current
                let combinedDueDate = calendar.date(bySettingHour: calendar.component(.hour, from: reminderTime),
                                                    minute: calendar.component(.minute, from: reminderTime),
                                                    second: 0,
                                                    of: dueDate) ?? dueDate

                let newReminder = Reminder(
                    title: title,
                    note: note,
                    dueDate: reminderOnDueDate ? combinedDueDate : nil,
                    interval: enableReminderInterval ? selectedInterval : nil,
                    minuteInterval: selectedInterval == 0 ? Int(minuteInterval) : nil,
                    hourInterval: selectedInterval == 1 ? Int(hourInterval) : nil,
                    dailyTime: selectedInterval == 2 ? dailyTime : nil,
                    weeklyTime: selectedInterval == 3 ? weeklyTime : nil,
                    dayOfWeek: selectedInterval == 3 ? selectedDayOfWeek : nil
                )
                
                if let reminderToEdit = reminderToEdit {
                    reminderManager.updateReminder(reminderToEdit, with: newReminder)
                } else {
                    reminderManager.addReminder(newReminder)
                }
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle(reminderToEdit == nil ? "Aufgabe hinzufügen" : "Aufgabe bearbeiten")
    }
}


struct Reminder: Identifiable, Equatable, Codable {
    let id = UUID()
    var title: String
    var note: String
    var dueDate: Date?
    var interval: Int?
    var minuteInterval: Int?
    var hourInterval: Int?
    var dailyTime: Date?
    var weeklyTime: Date?
    var dayOfWeek: Int?
    var completedDate: Date?
    
    static func == (lhs: Reminder, rhs: Reminder) -> Bool {
        lhs.id == rhs.id
    }
}


class ReminderManager: ObservableObject {
    @Published var toDoReminders: [Reminder] = []
    @Published var alwaysOnReminders: [Reminder] = []
    @Published var doneReminders: [Reminder] = []
    @Published var completionMessage: String?
    
    private let toDoKey = "toDoReminders"
    private let alwaysOnKey = "alwaysOnReminders"
    private let doneKey = "doneReminders"

    init() {
        requestNotificationPermission()
        loadReminders()
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    func addReminder(_ reminder: Reminder) {
        if reminder.dueDate != nil {
            toDoReminders.append(reminder)
        } else if reminder.interval != nil {
            alwaysOnReminders.append(reminder)
        }
        saveReminders()
        scheduleNotification(for: reminder)
    }
    
    func deleteReminder(_ reminder: Reminder) {
        if let index = toDoReminders.firstIndex(where: { $0.id == reminder.id }) {
            toDoReminders.remove(at: index)
        } else if let index = alwaysOnReminders.firstIndex(where: { $0.id == reminder.id }) {
            alwaysOnReminders.remove(at: index)
        }
        saveReminders()
        removeNotification(for: reminder)
    }
    
    func completeReminder(_ reminder: Reminder) {
        deleteReminder(reminder)
        var completedReminder = reminder
        completedReminder.completedDate = Date()
        doneReminders.append(completedReminder)
        saveReminders()
        
        completionMessage = "Good job!"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.completionMessage = nil
        }
    }
    
    func updateReminder(_ oldReminder: Reminder, with newReminder: Reminder) {
        deleteReminder(oldReminder)
        addReminder(newReminder)
    }
    
    private func saveReminders() {
        let encoder = JSONEncoder()
        if let toDoData = try? encoder.encode(toDoReminders) {
            UserDefaults.standard.set(toDoData, forKey: toDoKey)
        }
        if let alwaysOnData = try? encoder.encode(alwaysOnReminders) {
            UserDefaults.standard.set(alwaysOnData, forKey: alwaysOnKey)
        }
        if let doneData = try? encoder.encode(doneReminders) {
            UserDefaults.standard.set(doneData, forKey: doneKey)
        }
    }

    private func loadReminders() {
        let decoder = JSONDecoder()
        
        if let toDoData = UserDefaults.standard.data(forKey: toDoKey),
           let loadedToDoReminders = try? decoder.decode([Reminder].self, from: toDoData) {
            toDoReminders = loadedToDoReminders
        }
        
        if let alwaysOnData = UserDefaults.standard.data(forKey: alwaysOnKey),
           let loadedAlwaysOnReminders = try? decoder.decode([Reminder].self, from: alwaysOnData) {
            alwaysOnReminders = loadedAlwaysOnReminders
        }
        
        if let doneData = UserDefaults.standard.data(forKey: doneKey),
           let loadedDoneReminders = try? decoder.decode([Reminder].self, from: doneData) {
            doneReminders = loadedDoneReminders
        }
    }
    
    func scheduleNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.note.isEmpty ? "You have a reminder!" : reminder.note
        content.sound = .default
        
        let trigger: UNNotificationTrigger
        
        if let dueDate = reminder.dueDate {
            // Termin
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        } else if let interval = reminder.interval {
            switch interval {
            case 0:
                // Alle paar minuten
                let intervalInSeconds = Double(reminder.minuteInterval ?? 5) * 60
                trigger = UNTimeIntervalNotificationTrigger(timeInterval: intervalInSeconds, repeats: true)
                
            case 1:
                // Alle paar Stunden
                let intervalInSeconds = Double(reminder.hourInterval ?? 1) * 3600
                trigger = UNTimeIntervalNotificationTrigger(timeInterval: intervalInSeconds, repeats: true)
                
            case 2:
                // Täglich
                guard let dailyTime = reminder.dailyTime else { return }
                let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: dailyTime)
                trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
                
            case 3:
                // Wöchentlich
                guard let weeklyTime = reminder.weeklyTime else { return }
                var triggerDate = Calendar.current.dateComponents([.weekday, .hour, .minute], from: weeklyTime)
                triggerDate.weekday = reminder.dayOfWeek
                trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
                
            default:
                return
            }
        } else {
            return
        }
        
        let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    private func removeNotification(for reminder: Reminder) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
    }
}

struct ToDoView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    @State private var editReminder: Reminder?
    @State private var isEditing = false

    var body: some View {
        List {
            ForEach(reminderManager.toDoReminders) { reminder in
                Button(action: {
                    editReminder = reminder
                    isEditing = true
                }) {
                    VStack(alignment: .leading) {
                        Text(reminder.title)
                            .font(.headline)
                            .foregroundColor(.blue)
                    

                        if !reminder.note.isEmpty {
                            Text(reminder.note)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let dueDate = reminder.dueDate {
                            Text("Fällig am: \(DateFormatter.localizedDateFormatter.string(from: dueDate))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        if let interval = reminder.interval {
                            Text("Intervall: \(reminderIntervals[interval])")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .background(
                    NavigationLink(destination: AddToDoView(reminderToEdit: editReminder), isActive: $isEditing) {
                        EmptyView()
                    }
                    .hidden()
                )
                .swipeActions(edge: .trailing) {
                    Button {
                        reminderManager.completeReminder(reminder)
                    } label: {
                        Label("Complete", systemImage: "checkmark.circle.fill")
                    }
                    .tint(.green)
                    
                    Button(role: .destructive) {
                        reminderManager.deleteReminder(reminder)
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                }
            }
        }
        .onChange(of: isEditing) { newValue in
            if !newValue { editReminder = nil }
        }
    }
}

struct AlwaysOnView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    @State private var editReminder: Reminder?
    @State private var isEditing = false

    var body: some View {
        List {
            ForEach(0..<reminderIntervals.count, id: \.self) { intervalIndex in
                let remindersForInterval = reminders(for: intervalIndex)

                if !remindersForInterval.isEmpty {
                    Section(header: Text("Intervall: \(reminderIntervals[intervalIndex])")) {
                        ForEach(remindersForInterval) { reminder in
                            ReminderRow(reminder: reminder, intervalIndex: intervalIndex)
                                .onTapGesture {
                                    editReminder = reminder
                                    isEditing = true
                                }
                                .background(
                                    NavigationLink(destination: AddToDoView(reminderToEdit: editReminder), isActive: $isEditing) {
                                        EmptyView()
                                    }
                                    .hidden()
                                )
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        reminderManager.deleteReminder(reminder)
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                }
                        }
                    }
                }
            }
        }
        .onChange(of: isEditing) { newValue in
            if !newValue { editReminder = nil }
        }
    }

    private func reminders(for intervalIndex: Int) -> [Reminder] {
        reminderManager.alwaysOnReminders.filter { $0.interval == intervalIndex }
    }
}

struct ReminderRow: View {
    let reminder: Reminder
    let intervalIndex: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text(reminder.title)
                .font(.headline)
                .foregroundColor(.blue)

            if let intervalText = intervalText() {
                Text(intervalText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if !reminder.note.isEmpty {
                Text(reminder.note)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .contentShape(Rectangle())
    }

    private func intervalText() -> String? {
        switch intervalIndex {
        case 0:
            if let minuteInterval = reminder.minuteInterval {
                return "Alle \(minuteInterval) Minuten"
            }
        case 1:
            if let hourInterval = reminder.hourInterval {
                return "Alle \(hourInterval) Stunden"
            }
        case 2:
            if let dailyTime = reminder.dailyTime {
                return "Täglich um \(DateFormatter.localizedGermanTimeFormatter.string(from: dailyTime))"
            }
        case 3:
            if let weeklyTime = reminder.weeklyTime {
                let weekday = daysOfWeek[reminder.dayOfWeek ?? 0]
                return "Jeden \(weekday) um \(DateFormatter.localizedGermanTimeFormatter.string(from: weeklyTime))"
            }
        default:
            break
        }
        return nil
    }
}


extension DateFormatter {
    static var localizedGermanDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }
    
    static var localizedGermanTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }
    
    static var localizedDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }
}

struct DoneView: View {
    @EnvironmentObject var reminderManager: ReminderManager

    var body: some View {
        List {
            ForEach(reminderManager.doneReminders) { reminder in
                VStack(alignment: .leading) {
                    Text(reminder.title)
                        .font(.headline)
                        .foregroundColor(.blue)
                    if let date = reminder.completedDate {
                        
                        Text("Abgeschlossen am: \(DateFormatter.localizedDateFormatter.string(from: date))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}


struct PomodoroView: View {
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeRemaining = 25 * 60
    @State private var isRunning = false
    @State private var isBreak = false

    private let workDuration = 25 * 60
    private let breakDuration = 5 * 60

    var body: some View {
        VStack(spacing: 20) {
            Image("pomodoro")
                .resizable()
                .frame(width: 100, height: 100)
                .padding(.top, 10)

            Text(isBreak ? "Pausenzeit" : "Arbeitszeit")
                .font(.title)
                .padding()

            Text(timeString(from: timeRemaining))
                .font(.system(size: 50, weight: .bold, design: .monospaced))
                .padding()

            HStack(spacing: 20) {
                Button(action: startTimer) {
                    Text("Start")
                        .padding()
                        .background(isRunning ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isRunning)

                Button(action: pauseTimer) {
                    Text("Pause")
                        .padding()
                        .background(!isRunning ? Color.gray : Color.yellow)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!isRunning)

                Button(action: resetTimer) {
                    Text("Zurücksetzen")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.top, 40)
        }
        .onReceive(timer) { _ in
            guard isRunning else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                toggleSession()
            }
        }
        .padding()
    }

    private func startTimer() {
        isRunning = true
    }

    private func pauseTimer() {
        isRunning = false
    }

    private func resetTimer() {
        isRunning = false
        timeRemaining = isBreak ? breakDuration : workDuration
    }

    private func toggleSession() {
        isBreak.toggle()
        timeRemaining = isBreak ? breakDuration : workDuration
        isRunning = false
    }

    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ReminderManager())
    }
}
