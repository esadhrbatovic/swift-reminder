//
//  SplashScreenView.swift
//  Reminder
//
//  Created by Esad on 20.01.25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                Spacer()
                
                Image("AppIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                Text("Welcome to Reminder")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
            .onAppear {
                    withAnimation {
                        self.isActive = true
                    }
                
            }
        }
    }
}
