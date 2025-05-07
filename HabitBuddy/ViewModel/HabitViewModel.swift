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
        completedDates.append(date)
        habit.completedDates = completedDates
        
        if Calendar.current.isDateInToday(date) {
            isCompletedToday = true
            habit.isCompletedToday = true
            habit.lastCompletedDate = date
        }
        
        streak += 1
        habit.streak = Int16(streak)
        
        save()
    }
    
    func isHabitCompleted(on date: Date) -> Bool {
        guard let completedDates = habit.completedDates else { return false }
        return completedDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
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
}
