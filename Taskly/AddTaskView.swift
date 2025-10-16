//
//  AddTaskView.swift
//  Taskly
//
//  Created by Ritika Joshi on 10/16/25.
//


import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var hasDueDate = false
    @State private var dueAt: Date = .now.addingTimeInterval(86400)

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Title", text: $title)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(1...3)
                }

                Section("Due Date") {
                    Toggle("Add due date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Due", selection: $dueAt, displayedComponents: [.date])
                    }
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newTask = Task(
                            title: title.trimmingCharacters(in: .whitespaces),
                            notes: notes.isEmpty ? nil : notes,
                            dueAt: hasDueDate ? dueAt : nil
                        )
                        context.insert(newTask)
                        try? context.save()
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
