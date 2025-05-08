//
//  HabitEntityViewModel.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-05-06.
//

import Foundation
import SwiftUI
import CoreData

/*Handles the logic for the app to show and interact with habits, including weekView and date. Keeps track of currentdate, weekslider and navigation between weeks.
 Uses CoreData to handle habits in HabitEntity and filter them based on date.
 */

class HabitEntityViewModel: ObservableObject {
    //MARK: - properties
    @Published var currentDate: Date
    @Published var weekSlider: [[Date.WeekDay]] = []
    @Published var currentWeekIndex: Int = 2
    @Published var showingNewHabitSheet: Bool = false
    
    private let context: NSManagedObjectContext
    let calendar: Calendar
    
    //MARK: - initialization, sets up initial values
    init(context: NSManagedObjectContext) {
        
        //Sets up local timezone (CEST)
        self.context = context
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        self.calendar = calendar
        
        //Formatter to log dates in local time
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = calendar.timeZone
        
        // Sets currentdate to todays date by midnight
        let now = Date()
        self.currentDate = calendar.startOfDay(for: now)
        
        // Generates weekslider and updates
        self.weekSlider = HabitEntityViewModel.generateInitialWeeks(using: calendar)
        updateWeekSlider(for: self.currentDate)
    }
    
    //MARK: - methods
    
    //Deletes habit from CoreData.
    func deleteHabit(offsets: IndexSet, habits: FetchedResults<HabitEntity>) {
        withAnimation {
            offsets.map { habits[$0] }.forEach(context.delete)
            
            try? context.save()
        }
    }
    
    //Updates currentdate to the new date and updates weekslider
    func updateCurrentDate(to date: Date) {
        let normalizedDate = calendar.startOfDay(for: date)
        currentDate = normalizedDate
        updateWeekSlider(for: normalizedDate)
    }
    
    //Generates the array of 5 weeks for weekslider (two back, actual, two forward)
    static func generateInitialWeeks(using calendar: Calendar) -> [[Date.WeekDay]] {
        var weeks : [[Date.WeekDay]] = []
        let currentWeek = calendar.startOfDay(for: Date()).fetchWeek(using: calendar)
        
        if let first = currentWeek.first?.date {
            let oneWeekBack = first.createPreviousWeek(using: calendar)
            if let firstOfOneWeekBack = oneWeekBack.first?.date {
                weeks.append(firstOfOneWeekBack.createPreviousWeek(using: calendar))
            }
            weeks.append(oneWeekBack)
        }
        weeks.append(currentWeek)
        
        if let last = currentWeek.last?.date {
            let oneWeekForward = last.createNextWeek(using: calendar)
            weeks.append(oneWeekForward)
            if let lastOfOneWeekForward = oneWeekForward.last?.date {
                weeks.append(lastOfOneWeekForward.createNextWeek(using: calendar))
            }
        }
        return weeks
    }
    
    //Navigates to previous week in weekslider
    func navigateToPreviousWeek() {
        withAnimation {
            if currentWeekIndex > 0 {
                currentWeekIndex -= 1
            }
        }
    }
    
    //Navigates to next week in weekslider
    func navigateToNextWeek() {
        withAnimation {
            if currentWeekIndex < weekSlider.count - 1 {
                currentWeekIndex += 1
            }
        }
    }
    
    //Updates weekslider based on given date
    func updateWeekSlider(for date: Date) {
        var weeks : [[Date.WeekDay]] = []
        let selectedWeekStart = calendar.startOfDay(for: date)
        let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: selectedWeekStart)
        guard let weekStart = weekInterval?.start else { return }
        let selectedWeek = weekStart.fetchWeek(using: calendar)
        
        if let first = selectedWeek.first?.date {
            let oneWeekBack = first.createPreviousWeek(using: calendar)
            if let firstOfOneWeekBack = oneWeekBack.first?.date {
                let twoWeeksBack = firstOfOneWeekBack.createPreviousWeek(using: calendar)
                weeks.append(twoWeeksBack)
            }
            weeks.append(oneWeekBack)
        }
        weeks.append(selectedWeek)
        
        if let last = selectedWeek.last?.date {
            let oneWeekForward = last.createNextWeek(using: calendar)
            weeks.append(oneWeekForward)
            if let lastOfOneWeekForward = oneWeekForward.last?.date {
                let twoWeeksForward = lastOfOneWeekForward.createNextWeek(using: calendar)
                weeks.append(twoWeeksForward)
            }
        }
        weekSlider = weeks
        currentWeekIndex = 2
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = calendar.timeZone
    }
    
    //Determents if user can navigate back
    var canNavigateBack: Bool {
        currentWeekIndex > 0
    }
    
    //Determents if user can navigate forward
    var canNavigateForward: Bool {
        currentWeekIndex < weekSlider.count - 1
    }
    
    //Compares two dates to see if same day
    func isSameDate(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }
    
    //Filter habits based on given date
    func filterHabits(for date: Date, habits: FetchedResults<HabitEntity>) -> [HabitEntity] {
        let normalizedDate = calendar.startOfDay(for: date)
        return habits.filter { habit in
            if let createdDate = habit.createdDate {
                let normalizedCreatedDate = calendar.startOfDay(for: createdDate)
                
                return normalizedCreatedDate <= normalizedDate
            }
            return true
        }
    }
    
    //Checks if habit is completed on specific date
    func isHabitCompleted(_ habit: HabitEntity, on date: Date) -> Bool {
        guard let completedDates = habit.completedDates else { return false }
        let normalizedDate = calendar.startOfDay(for: date)
        return completedDates.contains { calendar.isDate($0, inSameDayAs: normalizedDate) }
    }
}
