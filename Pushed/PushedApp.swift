//
//  PushedApp.swift
//  Pushed
//
//  Created by Cassius Villareal on 2/10/25.
//

import SwiftUI
import SwiftData

@main
struct PushedApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State private var appController = AppController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appController)
                .onAppear {
                    appController.listenToAuthChanges()
                }
        }
    }
}
