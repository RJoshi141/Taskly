//
//  ContentView.swift
//  Taskly
//
//  Created by Ritika Joshi on 10/16/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Task.createdAt, order: .reverse) private var tasks: [Task]

    @State private var showingAdd = false

    // MARK: - Derived Lists
    private var activeTasks: [Task] {
        tasks.filter { !$0.isDone }
    }

    private var completedTasks: [Task] {
        tasks.filter { $0.isDone }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                if activeTasks.isEmpty && completedTasks.isEmpty {
                    ContentUnavailableView("No tasks yet",
                                           systemImage: "checklist",
                                           description: Text("Tap the + to add your first task."))
                        .padding(.vertical, 40)
                }

                if !activeTasks.isEmpty {
                    Section("Active") {
                        ForEach(activeTasks) { task in
                            TaskRow(task: task)
                        }
                        .onDelete { offsets in deleteTasks(at: offsets, in: activeTasks) }
                    }
                }

                if !completedTasks.isEmpty {
                    Section("Completed") {
                        ForEach(completedTasks) { task in
                            TaskRow(task: task)
                        }
                        .onDelete { offsets in deleteTasks(at: offsets, in: completedTasks) }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Taskly")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddTaskView()
            }
        }
    }

    // MARK: - Deletion
    private func deleteTasks(at offsets: IndexSet, in list: [Task]) {
        for index in offsets {
            context.delete(list[index])
        }
        try? context.save()
    }
}

