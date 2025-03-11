//
//  ProfileView.swift
//  Pushed
//
//  Created by Cassius Villareal on 2/10/25.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(AppController.self) private var appController
    
    var body: some View {
        VStack {
            Text("Logged in as: " + appController.email)
            
            Button("Logout") {
                do {
                    try appController.signOut()
                } catch {
                    print(error.localizedDescription)
                }
            }
            
        }
    }
}

#Preview {
    ProfileView()
}
