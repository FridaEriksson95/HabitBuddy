//
//  HabitEntityViewModel.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-05-06.
//

import Foundation
import SwiftUI
import CoreData

class HabitEntityViewModel: ObservableObject {
    @Published var currentDate: Date = .init()
    @Published var weekSlider: [[Date.WeekDay]] = []
    @Published var currentWeekIndex: Int = 2
    @Published var showingNewHabitSheet: Bool = false
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.weekSlider = HabitEntityViewModel.generateInitialWeeks()
    }
    
    func deleteHabit(offsets: IndexSet, habits: FetchedResults<HabitEntity>) {
        withAnimation {
            offsets.map { habits[$0] }.forEach(context.delete)
            
            try? context.save()
        }
    }
    
    func updateCurrentDate(to date: Date) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        currentDate = normalizedDate
        updateWeekSlider(for: normalizedDate)
    }
    
    static func generateInitialWeeks() -> [[Date.WeekDay]] {
        var weeks : [[Date.WeekDay]] = []
        let calendar = Calendar.current
        let currentWeek = calendar.startOfDay(for: Date()).fetchWeek()
        
        if let first = currentWeek.first?.date {
            let oneWeekBack = first.createPreviousWeek()
            if let firstOfOneWeekBack = oneWeekBack.first?.date {
                weeks.append(firstOfOneWeekBack.createPreviousWeek())
            }
            weeks.append(oneWeekBack)
        }
        weeks.append(currentWeek)
        
        if let last = currentWeek.last?.date {
            let oneWeekForward = last.createNextWeek()
            weeks.append(oneWeekForward)
            if let lastOfOneWeekForward = oneWeekForward.last?.date {
                weeks.append(lastOfOneWeekForward.createNextWeek())
            }
        }
        return weeks
    }
    
    func navigateToPreviousWeek() {
        withAnimation {
            if currentWeekIndex > 0 {
                currentWeekIndex -= 1
            }
        }
    }
    
    func navigateToNextWeek() {
        withAnimation {
            if currentWeekIndex < weekSlider.count - 1 {
                currentWeekIndex += 1
            }
        }
    }
    
    func updateWeekSlider(for date: Date) {
        var weeks : [[Date.WeekDay]] = []
        let calendar = Calendar.current
        let selectedWeekStart = calendar.startOfDay(for: date)
        let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: selectedWeekStart)
        guard let weekStart = weekInterval?.start else { return }
        let selectedWeek = weekStart.fetchWeek()
        
        if let first = selectedWeek.first?.date {
            let oneWeekBack = first.createPreviousWeek()
            if let firstOfOneWeekBack = oneWeekBack.first?.date {
                let twoWeeksBack = firstOfOneWeekBack.createPreviousWeek()
                weeks.append(twoWeeksBack)
            }
            weeks.append(oneWeekBack)
        }
        weeks.append(selectedWeek)
        
        if let last = selectedWeek.last?.date {
            let oneWeekForward = last.createNextWeek()
            weeks.append(oneWeekForward)
            if let lastOfOneWeekForward = oneWeekForward.last?.date {
                let twoWeeksForward = lastOfOneWeekForward.createNextWeek()
                weeks.append(twoWeeksForward)
            }
        }
        weekSlider = weeks
        currentWeekIndex = 2
        currentDate = selectedWeekStart
    }
    
    var canNavigateBack: Bool {
        currentWeekIndex > 0
    }
    
    var canNavigateForward: Bool {
        currentWeekIndex < weekSlider.count - 1
    }
    
    func isSameDate(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    func filterHabits(for date: Date, habits: FetchedResults<HabitEntity>) -> [HabitEntity] {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        return habits.filter { habit in
            if let createdDate = habit.createdDate {
                let normalizedCreatedDate = Calendar.current.startOfDay(for: createdDate)
                
                return normalizedCreatedDate <= normalizedDate
            }
            return true
        }
    }
    
    func isHabitCompleted(_ habit: HabitEntity, on date: Date) -> Bool {
        guard let completedDates = habit.completedDates else { return false }
        let normalizedDate = Calendar.current.startOfDay(for: date)
        return completedDates.contains { Calendar.current.isDate($0, inSameDayAs: normalizedDate) }
    }
}
