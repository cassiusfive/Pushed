//
//  ContentView.swift
//  Pushed
//
//  Created by Cassius Villareal on 2/10/25.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(AppController.self) private var appController

    var body: some View {
        Group {
            switch appController.authState {
            case .undefined: 
                ProgressView()
            case .notAuthenticated: 
                AuthView()
            case .authenticated:
                TabView {
                    ReminderListView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                    
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                }
                
            }
        }
    }
}

#Preview {
    ContentView()
}
