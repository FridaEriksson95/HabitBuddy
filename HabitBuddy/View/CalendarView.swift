//
//  CalendarView.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-05-07.
//

import SwiftUI

struct CalendarView: View {
    let year: Int
    let month: Int
    let completedDates: [Date]
    private let calendar = Calendar.current
    private let daysInWeek = 7
    private let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        VStack {
        Text(monthName())
                .font(.headline)
                .fontDesign(.monospaced)
                .padding(.bottom, 15)
            
            HStack {
                ForEach(dayNames, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            let days = generateDays()
            let weeks = (days.count + daysInWeek - 1) / daysInWeek
            
            ForEach(0..<weeks, id: \.self) { week in
                HStack {
                    ForEach(0..<daysInWeek, id: \.self) { dayIndex in
                    let index = week * daysInWeek + dayIndex
                        if index < days.count {
                            let day = days[index]
                            VStack{
                                Text(day.day != 0 ? "\(day.day)" : "")
                                    .frame(width: 30, height: 30)
                                    .background(day.day != 0 && calendar.isDateInToday(day.date) ? Color.gray.opacity(0.2) : Color.clear)
                                    .clipShape(Circle())
                                
                                if day.isCompleted {
                                    Circle()
                                        .frame(width: 6, height: 6)
                                        .foregroundColor(.green)
                                } else {
                                    Circle()
                                        .frame(width: 6, height: 6)
                                        .foregroundColor(.clear)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Spacer()
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                
            }
        }
        .padding()
    }
    
    private func monthName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        if let date = calendar.date(from: components) {
            return dateFormatter.string(from: date)
        }
        return ""
    }
    
    private struct Day: Identifiable {
        let id = UUID()
        let day: Int
        let date: Date
        let isCompleted: Bool
    }
    
    private func generateDays() -> [Day] {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let firstDayOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return []
        }
        
        let numberOfDays = range.count
        let weekdayOfFirstDay = calendar.component(.weekday, from: firstDayOfMonth) - 2
        let offset = (weekdayOfFirstDay + 7) % 7
        
        var days: [Day] = []
        
        for _ in 0..<offset {
            days.append(Day(day: 0, date: Date(), isCompleted: false))
        }
        
        for day in 1...numberOfDays {
            components.day = day
            if let date = calendar.date(from: components) {
                let isCompleted = completedDates.contains { completedDate in
                    calendar.isDate(completedDate, inSameDayAs: date)
                }
                days.append(Day(day: day, date: date, isCompleted: isCompleted))
            }
        }
        return days
    }
}

#Preview { CalendarView(year: 2025, month: 5, completedDates: [ Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 5))!, Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 10))!, Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 15))! ]) }
