//
//  TodoView.swift
//  Pushed
//
//  Created by Cassius Villareal on 2/10/25.
//

import SwiftUI

struct ReminderView: View {
    @State
    private var reminders: [Reminder] = []
    
    @State
    private var isAddReminderDialogPresented = false
    
    private func presentAddReminderView() {
        isAddReminderDialogPresented.toggle()
    }

    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("My Tasks")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button(action: presentAddReminderView) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top)
            
            if reminders.isEmpty {
                VStack {
                    Text("Click the button in the top right to add a new task")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                    
                    Text("OR")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.gray)
                        .padding(.vertical, 5)
                    
                    Text("Import a communal task from the Groups tab below")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach($reminders) { $reminder in
                            HStack {
                                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .imageScale(.large)
                                    .foregroundColor(.blue)
                                    .onTapGesture {
                                        reminder.isCompleted.toggle()
                                    }
                                Text(reminder.title)
                                    .font(.headline)
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isAddReminderDialogPresented) {
            AddReminderView { reminder in
                reminders.append(reminder)
            }
        }
    }
}

#Preview {
    ReminderView()
}
