//
//  PomodoroView.swift
//  reminder
//
//  Created by Esad on 20.01.25.
//

import Foundation
import SwiftUI
import AudioToolbox


struct PomodoroView: View {
    
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeRemaining = 25 * 60
    @State private var isRunning = false
    @State private var isBreak = false

    
    private let workDuration = 25 * 60
    private let breakDuration = 5 * 60

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)

                if isLandscape {
                    HStack(alignment: .top, spacing: 40) {
                        VStack(spacing: 20) {
                            Image("pomodoro")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
                                .padding(.top, 10)

                            Text(isBreak ? "Pausenzeit" : "Arbeitszeit")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)

                            Text(timeString(from: timeRemaining))
                                .font(.system(size: 40, weight: .bold, design: .monospaced))
                                .padding()
                                .foregroundColor(isBreak ? Color.blue : Color.red)

                            Spacer()
                        }

                        VStack(spacing: 20) {
                            HStack(spacing: 20) {
                                Button(action: startTimer) {
                                    Image(systemName: "play.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .padding()
                                        .background(isRunning ? Color.gray : Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .disabled(isRunning)
                                .accessibilityLabel("Start Timer")

                                Button(action: pauseTimer) {
                                    Image(systemName: "pause.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .padding()
                                        .background(!isRunning ? Color.gray : Color.yellow)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .disabled(!isRunning)
                                .accessibilityLabel("Pause Timer")
                            }

                            Button(action: resetTimer) {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .accessibilityLabel("Reset Timer")

                            Spacer()
                        }
                        .frame(width: geometry.size.width * 0.3)
                    }
                    .padding()
                    .transition(.move(edge: .trailing))
                } else {
                    VStack(spacing: 20) {
                        Image("pomodoro")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding(.top, 10)

                        Text(isBreak ? "Pausenzeit" : "Arbeitszeit")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)

                        Text(timeString(from: timeRemaining))
                            .font(.system(size: 50, weight: .bold, design: .monospaced))
                            .padding()
                            .foregroundColor(isBreak ? Color.blue : Color.red)

                        HStack(spacing: 20) {
                            Button(action: startTimer) {
                                Image(systemName: "play.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding()
                                    .background(isRunning ? Color.gray : Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(isRunning)
                            .accessibilityLabel("Start Timer")

                            Button(action: pauseTimer) {
                                Image(systemName: "pause.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding()
                                    .background(!isRunning ? Color.gray : Color.yellow)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(!isRunning)
                            .accessibilityLabel("Pause Timer")

                            Button(action: resetTimer) {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .accessibilityLabel("Reset Timer")
                        }
                        .padding(.top, 40)

                        Spacer()
                    }
                    .padding()
                    .transition(.move(edge: .bottom))
                }
            }
            .onReceive(timer) { _ in
                guard isRunning else { return }
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    toggleSession()
                }
            }
            .onDisappear {
                timer.upstream.connect().cancel()
            }
        }
        
    }

    private func startTimer() {
        isRunning = true
    }

    private func pauseTimer() {
        isRunning = false
    }

    private func resetTimer() {
        isRunning = false
        isBreak = false
        timeRemaining = workDuration
    }

    private func toggleSession() {
        isBreak.toggle()
        timeRemaining = isBreak ? breakDuration : workDuration
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        AudioServicesPlaySystemSound(SystemSoundID(1005))

    }

    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
