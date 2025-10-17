//
//  Item.swift
//  Taskly
//
//  Created by Ritika Joshi on 10/16/25.
//

import Foundation
import SwiftData

@Model
final class Task {
    var title: String
    var notes: String?
    var isDone: Bool
    var createdAt: Date
    var dueAt: Date?
    var location: String?          // 📍 new
    @Relationship(deleteRule: .cascade) var subtasks: [Subtask] = [] // ✅ new

    init(title: String, notes: String? = nil, dueAt: Date? = nil, location: String? = nil) {
        self.title = title
        self.notes = notes
        self.isDone = false
        self.createdAt = .now
        self.dueAt = dueAt
        self.location = location
    }
}

@Model
final class Subtask {
    var title: String
    var isDone: Bool
    var dueAt: Date?

    init(title: String, isDone: Bool = false, dueAt: Date? = nil) {
        self.title = title
        self.isDone = isDone
        self.dueAt = dueAt
    }
}
