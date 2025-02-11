//
//  AuthView.swift
//  Pushed
//
//  Created by Cassius Villareal on 2/10/25.
//

import SwiftUI

struct AuthView: View {
    
    @Environment(AppController.self) private var appController
    
    @State private var isSignUp = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text(isSignUp ? "Signup to Tackle" : "Login to Tackle")
                .font(.title)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                TextField("Email", text: Bindable(appController).email)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                SecureField("Password", text: Bindable(appController).password).textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal, 30)

            Button(action: authenticate) {
                Text(isSignUp ? "Signup" : "Login")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 30)

            // Toggle Sign-Up/Sign-In
            Button(action: { isSignUp.toggle() }) {
                HStack {
                    Text(isSignUp ? "Already have an account?" : "Don’t have an account?")
                    Text(isSignUp ? "Login" : "Sign up")
                        .underline()
                        .foregroundColor(.blue)
                }
                .font(.footnote)
            }
                
            Spacer()

            // Footer Text
            Text("Get things done, together.")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom)
        }.padding()
    }
    
    func authenticate() {
        isSignUp ? signUp() : signIn()
    }
    
    func signUp() {
        Task {
            do {
                try await appController.signUp()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func signIn() {
        Task {
            do {
                try await appController.signIn()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    AuthView()
}
