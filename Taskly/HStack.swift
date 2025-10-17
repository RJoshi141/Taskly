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
                    .foregroundStyle(task.isDone ? Color.tasklyPlum : .gray.opacity(0.4))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .strikethrough(task.isDone)
                    .foregroundStyle(task.isDone ? Color.tasklyTextSecondary : Color.tasklyTextPrimary)

                if let notes = task.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.footnote)
                        .foregroundStyle(Color.tasklyTextSecondary.opacity(0.90))
                        .lineLimit(2)
                }

                if let due = task.dueAt {
                    Text(due, style: .date)
                        .font(.caption2)
                        .foregroundStyle(Color.tasklyLavender)
                }

                if let location = task.location, !location.isEmpty {
                    Label(location, systemImage: "mappin.and.ellipse")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if !task.subtasks.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "list.bullet")
                        Text("\(task.subtasks.filter { $0.isDone }.count)/\(task.subtasks.count) subtasks")
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.tasklyBackground, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.tasklyLavender.opacity(0.25), radius: 5, x: 0, y: 3)
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }
}
