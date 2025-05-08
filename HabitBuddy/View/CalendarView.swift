//
//  CalendarView.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-05-07.
//

import SwiftUI

/*
 Shows a calendarview for given month marked with finished dates and notes. Takes in year, month, finished dates and HabitViewModel to fetch notes.
 Generates a grid of days and shows a noteView when finished day picks.
 */
struct CalendarView: View {
    let year: Int
    let month: Int
    let completedDates: [Date]
    @ObservedObject var viewModel: HabitViewModel
    @Environment(\.dismiss) var dismiss
    private let calendar = Calendar.current
    private let daysInWeek = 7
    private let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    @State private var selectedDate: Day?
    
    //MARK: - body / view
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
                                if day.day != 0 {
                                    Button(action: {
                                        if completedDates.contains(where: { calendar.isDate($0, inSameDayAs: day.date)}) {
                                            selectedDate = day
                                        }
                                    }) {
                                        Text("\(day.day)")
                                            .frame(width: 30, height: 30)
                                            .background(calendar.isDateInToday(day.date) ? Color.gray.opacity(0.2) : Color.clear)
                                            .clipShape(Circle())
                                            .foregroundColor(completedDates.contains(where: { calendar.isDate($0, inSameDayAs: day.date)}) ? .black : .gray)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    //Shows icon for note or marker for done days
                                    if viewModel.getNote(for: day.date) != nil {
                                        Image(systemName: "note.text")
                                            .foregroundColor(.turquoise)
                                            .font(.caption)
                                    } else if day.isCompleted {
                                        Circle()
                                            .frame(width: 6, height: 6)
                                            .foregroundColor(.green)
                                    }
                                }else {
                                    Text("")
                                        .frame(width: 30, height: 30)
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
        .onChange(of: viewModel.didUpdateNotes) {
        }
        .sheet(item: $selectedDate) { day in
            NoteView(date: day.date, viewModel: viewModel)
        }
    }
    
    //MARK: - methods
    //Fetches name of month and year
    private func monthName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        dateFormatter.timeZone = TimeZone.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        if let date = calendar.date(from: components) {
            return dateFormatter.string(from: date)
        }
        return ""
    }
    
    //Represent a day in calendar with day, date and done
    private struct Day: Identifiable {
        let id = UUID()
        let day: Int
        let date: Date
        let isCompleted: Bool
    }
    
    //Generate an array of days for actual month including empty spaces
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
        let weekdayOfFirstDay = (calendar.component(.weekday, from: firstDayOfMonth) + 5) % 7
        let offset = weekdayOfFirstDay
        
        var days: [Day] = []
        
        for _ in 0..<offset {
            days.append(Day(day: 0, date: Date(), isCompleted: false))
        }
        
        for day in 1...numberOfDays {
            components.day = day
            if let date = calendar.date(from: components) {
                let normalizedDate = calendar.startOfDay(for: date)
                print("Generated day \(day) with date: \(normalizedDate)")
                
                let isCompleted = completedDates.contains { completedDate in
                    calendar.isDate(completedDate, inSameDayAs: normalizedDate)
                }
                days.append(Day(day: day, date: normalizedDate, isCompleted: isCompleted))
            }
        }
        return days
    }
}

//Notes for specific day, allows editing and saving
struct NoteView: View {
    let date: Date
    @ObservedObject var viewModel: HabitViewModel
    @State private var noteText: String
    @State private var isEditing: Bool
    @Environment(\.dismiss) var dismiss
    
    private let calendar = Calendar.current
    
    //MARK: - initialization
    init(date: Date, viewModel: HabitViewModel) {
        self.date = date
        self.viewModel = viewModel
        let normalizedDate = calendar.startOfDay(for: date)
        self._noteText = State(initialValue: viewModel.getNote(for: normalizedDate) ?? "")
        self._isEditing = State(initialValue: false)
    }
    
    //MARK: - body / view
    var body: some View {
        NavigationView {
            VStack {
                Text("Anteckning för \(dateFormatted())")
                    .font(.headline)
                    .padding()
                
                if isEditing {
                    TextEditor(text: $noteText)
                        .frame(minHeight: 100)
                        .padding()
                        .border(.gray, width: 1)
                } else {
                    Text(noteText.isEmpty ? "Ingen anteckning än" : noteText)
                        .frame(minHeight: 100)
                        .padding()
                }
                
                Spacer()
                
                HStack{
                    if isEditing{
                        Button(action: {
                            let normalizedDate = calendar.startOfDay(for: date)
                            viewModel.addNote(for: normalizedDate, note: noteText)
                            print("Saving note for date: \(calendar.startOfDay(for: date)) with text: \(noteText)")
                            
                            isEditing = false
                            dismiss()
                        }) {
                            Text("Spara")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.bluegreen)
                                .cornerRadius(10)
                            
                        }
                        .padding()
                    } else {
                        Button(action: {
                            isEditing = true
                        }) {
                            Text("Redigera")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.bluegreen)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(isEditing ? "Lägg till anteckning" : "Anteckning")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") {
                        let normalizedDate = calendar.startOfDay(for: date)
                        if isEditing && viewModel.getNote(for: normalizedDate) == nil {
                            noteText = ""
                        }
                        isEditing = false
                        dismiss()
                    }
                }
                if !isEditing && !noteText.isEmpty {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Delete") {
                            let normalizedDate = calendar.startOfDay(for: date)
                            viewModel.addNote(for: normalizedDate, note: "")
                            noteText = ""
                            dismiss()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    //Formats date to readable string
    private func dateFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
}

//#Preview {
//    let context = PersistenceController.preview.container.viewContext
//    let habit = HabitEntity(context: context)
//    habit.title = "Matlagning"
//    habit.symbolName = "leaf.fill"
//    habit.completedDates = [ Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 5))!, Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 10))!, Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 15))! ]
//    let viewModel = HabitViewModel(habit: habit, context: context)
//    return CalendarView(year: 2025, month: 5, completedDates: viewModel.completedDatesInMonth(year: 2025, month: 5), viewModel: viewModel) }
