//
//  TasklyApp.swift
//  Taskly
//
//  Created by Ritika Joshi on 10/16/25.
//

import SwiftUI
import SwiftData

@main
struct TasklyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Task.self)
    }
}

