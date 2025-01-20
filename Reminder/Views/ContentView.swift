import SwiftUI

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
                        .animation(.easeInOut, value: message)
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




