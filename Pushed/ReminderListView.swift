//
//  ReminderList.swift
//  Pushed
//
//  Created by Cassius Villareal on 2/10/25.
//

import SwiftUI

struct ReminderListCell: View {
    @Binding var reminder: Reminder
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: self.reminder.isCompleted ? "checkmark.square.fill" : "square")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(self.reminder.isCompleted ? Color(UIColor.systemBlue) : Color.secondary)
                .padding(.all, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.headline)
                
                if !reminder.description.isEmpty {
                    Text(reminder.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            self.reminder.isCompleted.toggle()
        }
    }
}

struct ReminderListView: View {
    @State
    private var reminders: [Reminder] = []
    
    @State
    private var isAddReminderDialogPresented = false
    
    private func presentAddReminderView() {
        isAddReminderDialogPresented.toggle()
    }
    
    private func deleteReminder(at offsets: IndexSet) {
        reminders.remove(atOffsets: offsets)
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
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                List {
                    ForEach($reminders) { $reminder in
                        ReminderListCell(reminder: $reminder)
                    }
                    .onDelete(perform: deleteReminder)
                }
                .listStyle(PlainListStyle())
                .padding(.all, 10)
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
    ReminderListView()
}
