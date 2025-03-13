//
//  ReminderList.swift
//  Pushed
//
//  Created by Cassius Villareal on 2/10/25.
//

import SwiftUI
import FirebaseAuth

struct ReminderListCell: View {
    let reminder: Reminder
    let toggleAction: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: reminder.isCompleted ? "checkmark.square.fill" : "square")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(reminder.isCompleted ? Color(UIColor.systemBlue) : Color.secondary)
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
            toggleAction()
        }
    }
}

struct ReminderListView: View {
    @State private var reminders: [Reminder] = []
    @State private var isAddReminderDialogPresented = false
    @State private var isAIGenerateDialogPresented = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var completedTaskCount: Int = 0
    @State private var aiPrompt: String = ""
    
    // Services
    private let taskService = TaskService()
    private let statsService = StatsService()
    private let aiTaskService = AITaskService()

    private let userId = Auth.auth().currentUser?.uid ?? "1"
    
    private func loadData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Fetch tasks
                let fetchedReminders = try await taskService.fetchTasks(userId: userId)
                
                // Fetch stats
                let completedCount = try await statsService.getCompletedTaskCount(userId: userId)
                
                await MainActor.run {
                    reminders = fetchedReminders
                    completedTaskCount = completedCount
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Error loading data: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func addReminder(_ reminder: Reminder) {
        Task {
            do {
                // Create a new reminder with the current user ID
                var newReminder = reminder
                newReminder.user_id = userId
                
                let createdReminder = try await taskService.createTask(reminder: newReminder)
                await MainActor.run {
                    reminders.append(createdReminder)
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Error adding task: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func generateAITask() {
        guard !aiPrompt.isEmpty else { return }
        
        Task {
            do {
                let newTask = try await aiTaskService.generateTask(userId: userId, prompt: aiPrompt)
                
                await MainActor.run {
                    reminders.append(newTask)
                    aiPrompt = ""
                    isAIGenerateDialogPresented = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to generate task: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func toggleCompletion(for reminder: Reminder) {
        Task {
            do {
                var updatedReminder = reminder
                updatedReminder.isCompleted.toggle()
                
                let savedReminder = try await taskService.updateTask(reminder: updatedReminder)
                
                await MainActor.run {
                    if let index = reminders.firstIndex(where: { $0.id == savedReminder.id }) {
                        reminders[index] = savedReminder
                    }
                    
                    // Refresh stats after toggling completion
                    Task {
                        do {
                            completedTaskCount = try await statsService.getCompletedTaskCount(userId: userId)
                        } catch {
                            print("Error updating stats: \(error.localizedDescription)")
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Error updating task: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func deleteReminder(at offsets: IndexSet) {
        // Get the IDs of the items to delete
        let idsToDelete = offsets.map { reminders[$0].id }
        
        // Remove items from the UI immediately for responsiveness
        reminders.remove(atOffsets: offsets)
        
        // Then delete from the server
        for id in idsToDelete.compactMap({ $0 }) {
            Task {
                do {
                    _ = try await taskService.deleteTask(id: id)
                    
                    let updatedCount = try await statsService.getCompletedTaskCount(userId: userId)
                    await MainActor.run {
                        completedTaskCount = updatedCount
                    }
                } catch {
                    print("Error deleting task \(id): \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func presentAddReminderView() {
        isAddReminderDialogPresented.toggle()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("My Tasks")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Lifetime Completed: \(completedTaskCount)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Menu {
                    Button(action: presentAddReminderView) {
                        Label("Add Task", systemImage: "plus")
                    }
                    
                    Button(action: { isAIGenerateDialogPresented = true }) {
                        Label("Generate with AI", systemImage: "wand.and.stars")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top)
            
            if isLoading {
                ProgressView("Loading tasks...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if let error = errorMessage {
                VStack {
                    Text(error)
                        .foregroundColor(.red)
                    Button("Try Again") {
                        loadData()
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if reminders.isEmpty {
                VStack {
                    Text("Click the + button to add a new task or generate one with AI")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                List {
                    ForEach(reminders) { reminder in
                        ReminderListCell(
                            reminder: reminder,
                            toggleAction: {
                                toggleCompletion(for: reminder)
                            }
                        )
                    }
                    .onDelete(perform: deleteReminder)
                }
                .listStyle(PlainListStyle())
                .padding(.all, 10)
            }
        }
        .sheet(isPresented: $isAddReminderDialogPresented) {
            AddReminderView { reminder in
                addReminder(reminder)
            }
        }
        .sheet(isPresented: $isAIGenerateDialogPresented) {
            // AI Task Generation Dialog
            NavigationStack {
                VStack(spacing: 20) {
                    Text("Generate Task with AI")
                        .font(.headline)
                    
                    TextField("Describe the task you want to create...", text: $aiPrompt, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(4...)
                        .padding()
                    
                    Button("Generate Task") {
                        generateAITask()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(aiPrompt.isEmpty)
                    
                    Spacer()
                }
                .padding()
                .navigationBarItems(trailing: Button("Cancel") {
                    isAIGenerateDialogPresented = false
                })
            }
        }
        .onAppear {
            loadData()
        }
        .refreshable {
            loadData()
        }
    }
}
