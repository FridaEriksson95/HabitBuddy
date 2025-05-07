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
    @Published var didUpdateNotes = false
    
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
    
    private var notes: [Date: String] {
        get {
            if let notesData = habit.notes, let notesDict = try? JSONSerialization.jsonObject(with: notesData, options: []) as? [String: String] {
                return Dictionary(uniqueKeysWithValues: notesDict.map { (Calendar.current.startOfDay(for: DateFormatter.iso8601.date(from: $0) ?? Date()), $1) })
            }
            return [:]
        }
        set {
            let notesDict = Dictionary(uniqueKeysWithValues: newValue.map { (DateFormatter.iso8601.string(from: Calendar.current.startOfDay(for: $0)), $1) })
            do {
                let notesData = try JSONSerialization.data(withJSONObject: notesDict, options: [])
                habit.notes = notesData
                save()
                didUpdateNotes.toggle()
            } catch {
                print("Failed to encode notes: \(error.localizedDescription)")
            }
        }
    }
    
    func getNote(for date: Date) -> String? {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        return notes[normalizedDate]
    }
    
    func addNote(for date: Date, note: String) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        var updatedNotes = notes
        updatedNotes[normalizedDate] = note.isEmpty ? nil : note
        notes = updatedNotes
    }
}

extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar.current
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}
