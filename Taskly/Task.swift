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
    @Attribute(.unique) var id: UUID
    var title: String
    var notes: String?
    var isDone: Bool
    var createdAt: Date
    var dueAt: Date?

    init(title: String, notes: String? = nil, isDone: Bool = false, dueAt: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.isDone = isDone
        self.createdAt = Date()
        self.dueAt = dueAt
    }
}
