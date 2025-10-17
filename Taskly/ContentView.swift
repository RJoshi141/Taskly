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
    @State private var showingTaskToEdit: Task?

    private var activeTasks: [Task] { tasks.filter { !$0.isDone } }
    private var completedTasks: [Task] { tasks.filter { $0.isDone } }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tasklyBackground.ignoresSafeArea()

                List {
                    if activeTasks.isEmpty && completedTasks.isEmpty {
                        VStack {
                            Spacer(minLength: 120)
                            ContentUnavailableView(
                                "No tasks yet",
                                systemImage: "checklist",
                                description: Text("Tap the + to add your first task.")
                            )
                            .padding(.vertical, 40)
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }

                    if !activeTasks.isEmpty {
                        Section("Active") {
                            ForEach(activeTasks) { task in
                                Button {
                                    showingTaskToEdit = task
                                } label: {
                                    TaskRow(task: task)
                                }
                                .buttonStyle(.plain)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                            }
                            .onDelete { offsets in deleteTasks(at: offsets, in: activeTasks) }
                        }
                    }

                    if !completedTasks.isEmpty {
                        Section("Completed") {
                            ForEach(completedTasks) { task in
                                Button {
                                    showingTaskToEdit = task
                                } label: {
                                    TaskRow(task: task)
                                }
                                .buttonStyle(.plain)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                            }
                            .onDelete { offsets in deleteTasks(at: offsets, in: completedTasks) }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                .listRowSeparator(.hidden)
            }

            .navigationTitle("Taskly")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.tasklyPlum)
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                        .tint(Color.tasklyPlum)
                }
            }

            .sheet(isPresented: $showingAdd) {
                AddTaskView()

            }
            .sheet(item: $showingTaskToEdit) { task in
                AddTaskView(existingTask: task)
            }

            .tint(Color.tasklyLavender)
        }
    }

    private func deleteTasks(at offsets: IndexSet, in list: [Task]) {
        for index in offsets {
            context.delete(list[index])
        }
        try? context.save()
    }
}

