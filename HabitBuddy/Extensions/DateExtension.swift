//
//  DateExtension.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-04-29.
//

import SwiftUI

/*
 Expands Date type with methods to format dates, control days date and generate weekdays. Easier to handle dates for app with weekview and formatting dates.
 */
extension Date {
    
//MARK: - methods
    //Formats date to given string
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
    
    //Checks if date is today based on actual calendar
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    //Catches an array of weekdays for the actual weeks where date is
    func fetchWeek(using calendar: Calendar) -> [WeekDay] {
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
    
    //Creates an array of next weekdays
    func createNextWeek(using calendar: Calendar) -> [WeekDay] {
        guard let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: self) else { return [] }
        return nextWeekStart.fetchWeek(using: calendar)
    }
    //Creates an array of previous weekdays
    func createPreviousWeek(using calendar: Calendar) -> [WeekDay] {
        guard let previousWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: self) else { return [] }
        return previousWeekStart.fetchWeek(using: calendar)
    }
    
    //Represent a day in week with unic id and date
    struct WeekDay: Identifiable {
        var id: UUID = .init()
        var date: Date
    }
}
