//
//  HabitViewModel.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-05-06.
//

import Foundation
import SwiftUI
import CoreData

class HabitViewModel: ObservableObject {
    @Published private var habit: HabitEntity
    @Published var isCompletedToday: Bool
    @Published var streak: Int
    @Published var title: String
    @Published var symbolName: String
    
    private let context: NSManagedObjectContext
    
    init(habit: HabitEntity, context: NSManagedObjectContext) {
        self.habit = habit
        self.context = context
        self.isCompletedToday = habit.isCompletedToday
        self.streak = Int(habit.streak)
        self.title = habit.title ?? "din habit"
        self.symbolName = habit.symbolName ?? "questionmark.circle"
        if habit.createdDate == nil {
            habit.createdDate = Calendar.current.startOfDay(for: Date())
            save()
        }
        checkTodayStatus()
    }
    
    var daysThisWeek: Int {
        streak % 7
    }
    
    var fullWeeks: Int {
        streak / 7
    }
    
    var progressValue: Double {
        Double(daysThisWeek) / 7.0
    }
    
    func markAsCompleted(on date: Date) {
        guard !isHabitCompleted(on: date) else { return }
        
        var completedDates = habit.completedDates ?? []
        let normalizedDate = Calendar.current.startOfDay(for: date)
        completedDates.append(normalizedDate)
        habit.completedDates = completedDates
        
        if Calendar.current.isDateInToday(normalizedDate) {
            isCompletedToday = true
            habit.isCompletedToday = true
            habit.lastCompletedDate = normalizedDate
            streak += 1
            habit.streak = Int16(streak)
        }
        
        save()
    }
    
    func isHabitCompleted(on date: Date) -> Bool {
        guard let completedDates = habit.completedDates else { return false }
        let normalizedDate = Calendar.current.startOfDay(for: date)
        return completedDates.contains { Calendar.current.isDate($0, inSameDayAs: normalizedDate) }
    }
    
    func updateHabit(newTitle: String, newSymbol: String) {
        habit.title = newTitle.isEmpty ? "din habit" : newTitle
        habit.symbolName = newSymbol
        title = habit.title ?? "din habit"
        symbolName = habit.symbolName ?? "questionmark.circle"
        save()
    }
    
    private func checkTodayStatus() {
        if let lastDate = habit.lastCompletedDate {
            if !Calendar.current.isDateInToday(lastDate) {
                isCompletedToday = false
                habit.isCompletedToday = false
                save()
            }
        }
    }
    
    private func save() {
        do {
            try context.save()
        } catch {
            print("Fel vid sparning: \(error.localizedDescription)")
        }
    }


func completedDatesInMonth(year: Int, month: Int) -> [Date] {
    let calendar = Calendar.current
    guard let completedDates = habit.completedDates else { return [] }
    
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = 1
    
    guard let firstDayOfMonth = calendar.date(from: components),
          let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth),
          let lastDayOfMonth = calendar.date(byAdding: .day, value: range.count - 1, to: firstDayOfMonth) else { return [] }
    
    return completedDates.filter { date in
        calendar.isDate(date, equalTo: firstDayOfMonth, toGranularity: .month)
        
        }
    }
}
