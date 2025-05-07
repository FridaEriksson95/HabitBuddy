//
//  DateExtension.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-04-29.
//

import SwiftUI

extension Date {
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func fetchWeek() -> [WeekDay] {
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: self)
        
        let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: startOfDate)
        guard let startOfWeek = weekInterval?.start else { return [] }
        
        var week: [WeekDay] = []
        
        for index in (0..<7) {
        if let weekDay = calendar.date(byAdding: .day, value: index, to: startOfWeek) {
            week.append(.init(date: calendar.startOfDay(for: weekDay)))
                
            }
        }
        return week
    }
    
    func createNextWeek() -> [WeekDay] {
        let calendar = Calendar.current
        guard let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: self) else { return [] }
        return nextWeekStart.fetchWeek()
    }
    
    func createPreviousWeek() -> [WeekDay] {
        let calendar = Calendar.current
        guard let previousWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: self) else { return [] }
        return previousWeekStart.fetchWeek()
    }
    
    struct WeekDay: Identifiable {
        var id: UUID = .init()
        var date: Date
    }
}
