//
//  Untitled.swift
//  Taskly
//
//  Created by Ritika Joshi on 10/16/25.
//


import SwiftUI
import SwiftData

struct TaskRow: View {
    @Environment(\.modelContext) private var context
    @Bindable var task: Task

    var body: some View {
        HStack(spacing: 12) {
            Button {
                task.isDone.toggle()
                Haptics.tick()
                try? context.save()
            } label: {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
                    .foregroundStyle(task.isDone ? .green : .gray)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.body.weight(.medium))
                    .strikethrough(task.isDone)
                    .foregroundStyle(task.isDone ? .secondary : .primary)

                if let notes = task.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                if let due = task.dueAt {
                    Text(due, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 0.5)
        )
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .padding(.vertical, 4)
    }
}
