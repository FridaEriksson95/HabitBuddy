//
//  OffsetKey.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-04-29.
//

import SwiftUI

struct OffsetKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
