//
//  Haptics.swift
//  Taskly
//
//  Created by Ritika Joshi on 10/16/25.
//


import UIKit

enum Haptics {
    static func tick() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
