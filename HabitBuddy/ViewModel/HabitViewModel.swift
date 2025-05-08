//
//  HabitViewModel.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-05-06.
//

import Foundation
import SwiftUI
import CoreData

/*
 Handled the logic for specific habit, like defining done, update icon/title and handle streaks and notes.
 Uses coreData to save changes in habit. Syncronise date with given calendar for correct timezone.
 */
class HabitViewModel: ObservableObject {
    @Published private var habit: HabitEntity
    @Published var isCompletedToday: Bool
    @Published var streak: Int
    @Published var title: String
    @Published var symbolName: String
    @Published var didUpdateNotes = false
    
    private let context: NSManagedObjectContext
    private let calendar: Calendar
    
    //MARK: - initialization
    init(habit: HabitEntity, context: NSManagedObjectContext, calendar: Calendar) {
        self.habit = habit
        self.context = context
        self.calendar = calendar
        self.isCompletedToday = habit.isCompletedToday
        self.streak = Int(habit.streak)
        self.title = habit.title ?? "din habit"
        self.symbolName = habit.symbolName ?? "questionmark.circle"
        //Sets createddate for days date
        if habit.createdDate == nil {
            habit.createdDate = calendar.startOfDay(for: Date())
            save()
        } else if calendar.startOfDay(for: habit.createdDate!) < calendar.startOfDay(for: Date()) {
            habit.createdDate = calendar.startOfDay(for: Date())
            save()
        }
        checkTodayStatus()
    }
    
    //Count amount of days in actual week based on streak
    var daysThisWeek: Int {
        streak % 7
    }
    
    //Count amount of full weeks based on streak
    var fullWeeks: Int {
        streak / 7
    }
    
    //Counts progressvalue for weeks streak
    var progressValue: Double {
        Double(daysThisWeek) / 7.0
    }
    
    //MARK: - methods
    //Mark habit as done for specifik date
    func markAsCompleted(on date: Date) {
        guard !isHabitCompleted(on: date) else { return }
        
        var completedDates = habit.completedDates ?? []
        let normalizedDate = calendar.startOfDay(for: date)
        completedDates.append(normalizedDate)
        habit.completedDates = completedDates
        
        if calendar.isDateInToday(normalizedDate) {
            isCompletedToday = true
            habit.isCompletedToday = true
            habit.lastCompletedDate = normalizedDate
            streak += 1
            habit.streak = Int16(streak)
        }
        
        save()
    }
    
    //Controls if habit is marked done for specific date
    func isHabitCompleted(on date: Date) -> Bool {
        guard let completedDates = habit.completedDates else { return false }
        let normalizedDate = calendar.startOfDay(for: date)
        return completedDates.contains { calendar.isDate($0, inSameDayAs: normalizedDate) }
    }
    
    //Updates habits title and icon
    func updateHabit(newTitle: String, newSymbol: String) {
        habit.title = newTitle.isEmpty ? "din habit" : newTitle
        habit.symbolName = newSymbol
        title = habit.title ?? "din habit"
        symbolName = habit.symbolName ?? "questionmark.circle"
        save()
    }
    
    //Checks if habit is still done based on last marked date
    private func checkTodayStatus() {
        if let lastDate = habit.lastCompletedDate {
            if !calendar.isDateInToday(lastDate) {
                isCompletedToday = false
                habit.isCompletedToday = false
                save()
            }
        }
    }
    
    //Save to CoreData
    private func save() {
        do {
            try context.save()
        } catch {
            print("Fel vid sparning: \(error.localizedDescription)")
        }
    }

//Fetches all completed dates for specific month
func completedDatesInMonth(year: Int, month: Int) -> [Date] {
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
    
    //Handles the notes for habit with date and text
    private var notes: [Date: String] {
        get {
            //Converts JSON-data to dictionary with date and notes
            if let notesData = habit.notes, let notesDict = try? JSONSerialization.jsonObject(with: notesData, options: []) as? [String: String] {
                return Dictionary(uniqueKeysWithValues: notesDict.map { (calendar.startOfDay(for: DateFormatter.iso8601.date(from: $0) ?? Date()), $1) })
            }
            return [:]
        }
        set {
            //Saves notes as JSON-data in CoreData
            let notesDict = Dictionary(uniqueKeysWithValues: newValue.map { (DateFormatter.iso8601.string(from: calendar.startOfDay(for: $0)), $1) })
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
    
    //Fetches note for specific date
    func getNote(for date: Date) -> String? {
        let normalizedDate = calendar.startOfDay(for: date)
        return notes[normalizedDate]
    }
    
    //Adds or updates note for specific date
    func addNote(for date: Date, note: String) {
        let normalizedDate = calendar.startOfDay(for: date)
        var updatedNotes = notes
        updatedNotes[normalizedDate] = note.isEmpty ? nil : note
        notes = updatedNotes
    }
}

//MARK: - extension
//A static formatter to convert dates to ISO 8601 format
extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar.current
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}
