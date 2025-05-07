//
//  HabitView.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-04-29.
//

import SwiftUI

struct HabitEntityView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var currentDate: Date = .init()
    @State private var weekSlider: [[Date.WeekDay]] = HabitEntityView.generateInitialWeeks()
    @State private var currentWeekIndex: Int = 1
    @State private var showingNewHabitSheet = false
    
    
    @FetchRequest(
        entity: HabitEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \HabitEntity.lastCompletedDate, ascending: true)],
        animation: .default)
    private var habits: FetchedResults<HabitEntity>

    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HeaderView()
                
                if habits.isEmpty {
                        Spacer()
                    VStack(alignment: .center, spacing: 16) {
                        Text("Inga vanor än")
                            .font(.headline)
                            .foregroundColor(.gray)
                            
                        Image(.logo)
                            .resizable()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                        Spacer()
                    } else {
                        List{
                            ForEach(habits) { habit in
                                HabitItemView(habit : habit)
                                    .listRowBackground(Color.BG)
                                    .buttonStyle(.plain)
                            }
                            .onDelete(perform: deleteHabit)
                        }
                        .listStyle(.plain)
                        .background(.BG)
                    }
                }
                .sheet(isPresented: $showingNewHabitSheet){
                    NewHabitView()
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    
 
    private func deleteHabit(offsets: IndexSet) {
        withAnimation {
            offsets.map { habits[$0] }.forEach(viewContext.delete)
            
            try? viewContext.save()
        }
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 1) {
                Image(.logo)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(.circle)
                Text(currentDate.format("MMMM"))
                    .foregroundStyle(.bluegreen)
                    .padding(.trailing, 5)
                
                Text(currentDate.format("YYYY"))
                    .foregroundStyle(.gray)
                
                Button(action: {
                    showingNewHabitSheet = true
                }) {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                        .padding(10)
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.bluegreen))
                }
                .hSpacing(.trailing)
                .padding(.horizontal, 20)
               
            }
            .font(.title.bold())
            .padding(.leading, 35)
            
            if weekSlider.indices.contains(currentWeekIndex) {
                WeekView(weekSlider[currentWeekIndex])
            }
        }
    }
  

    
    @ViewBuilder
    func WeekView(_ week: [Date.WeekDay]) -> some View {
        HStack(spacing: 10) {
            ForEach(week) { day in
                VStack(spacing: 6) {
                    Text(day.date.format("E"))
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    Text(day.date.format("dd"))
                        .font(.headline)
                        .foregroundStyle(isSameDate(day.date, currentDate) ? .white : .gray)
                        .frame(width: 35, height: 35)
                        .background(
                                Circle()
                                    .fill(isSameDate(day.date, currentDate) ? Color.bluegreen : Color.clear)
                           )
                        .overlay(
                                Circle()
                                    .fill(Color.cyan)
                                    .frame(width: 5, height: 5)
                                    .offset(y: 12)
                                    .opacity(day.date.isToday && !isSameDate(day.date, currentDate) ? 1 : 0)
                            )
                        }
                .onTapGesture {
                    currentDate = day.date
                }
            }
        }
        .padding(.vertical, 10)
        .hSpacing(.top)
    }
    


    static func generateInitialWeeks() -> [[Date.WeekDay]] {
        var weeks : [[Date.WeekDay]] = []
        let currentWeek = Date().fetchWeek()
        
        if let first = currentWeek.first?.date {
            weeks.append(first.createPreviousWeek())
        }
        weeks.append(currentWeek)
        
        if let last = currentWeek.last?.date {
            weeks.append(last.createNextWeek())
        }
        return weeks
    }
    
    func isSameDate(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}
    

#Preview {
    HabitEntityView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
