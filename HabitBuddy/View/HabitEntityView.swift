//
//  HabitView.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-04-29.
//

import SwiftUI
import CoreData

/*
 MainView for list of habits, weekslider and header. Fetches habits from CoreData and filter them based on date.
 Empty view if no habits exists else habitItemView list for each habit. Weekview to navigate between days and a header to create new habits.
 */
struct HabitEntityView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: HabitEntityViewModel
    
    
    @FetchRequest(
        entity: HabitEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \HabitEntity.lastCompletedDate, ascending: true)],
        animation: .default)
    private var habits: FetchedResults<HabitEntity>
    
    //MARK: - initialization
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        _viewModel = StateObject(wrappedValue: HabitEntityViewModel(context: context))
    }
    
    //MARK: - body/main view
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HeaderView()
                
                //Filter habits based on date
                let filteredHabits = viewModel.filterHabits(for: viewModel.currentDate, habits: habits)
                
                //Empty view if no habits
                if habits.isEmpty {
                    Spacer()
                    VStack(alignment: .center, spacing: 16) {
                        Text("Inga habits än")
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
                    
                    //List of habits
                    List{
                        ForEach(filteredHabits) { habit in
                            HabitItemView(
                                        habit : habit,
                                          isCompleted: viewModel.isHabitCompleted(habit, on: viewModel.currentDate),
                                        isPastDate: {
                                            let createdDate = habit.createdDate ?? viewModel.calendar.startOfDay(for: Date())
                                            let currentDate = viewModel.calendar.startOfDay(for: viewModel.currentDate)
                                            let comparison = viewModel.calendar.compare(createdDate, to: currentDate, toGranularity: .day)
                                            let result = comparison == .orderedAscending
                                    
                                        return result}(),
                                        entityViewModel: viewModel
                            )
                                .listRowBackground(Color.BG)
                                .buttonStyle(.plain)
                        }
                        .onDelete { offsets in
                            viewModel.deleteHabit(offsets: offsets, habits: habits)
                        }
                    }
                    .listStyle(.plain)
                    .background(.BG)
                }
            }
            .sheet(isPresented: $viewModel.showingNewHabitSheet){
                NewHabitView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    //MARK: - headerview
    //Header with logo, actual month and year, button to create new habit
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 1) {
                Image(.logo)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(.circle)
                Text(viewModel.currentDate.format("MMMM", using: viewModel.calendar))
                    .foregroundStyle(.bluegreen)
                    .padding(.trailing, 5)
                
                Text(viewModel.currentDate.format("YYYY", using: viewModel.calendar))
                    .foregroundStyle(.gray)
                
                Button(action: {
                    viewModel.showingNewHabitSheet = true
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
            
            //weekslider
            if viewModel.weekSlider.indices.contains(viewModel.currentWeekIndex) {
                WeekView(viewModel.weekSlider[viewModel.currentWeekIndex])
            }
        }
    }
    
    //MARK: - weekview
    //Shows a row of days for specific week with option to navigate between weeks
    @ViewBuilder
    func WeekView(_ week: [Date.WeekDay]) -> some View {
        VStack{
            HStack {
                Button(action: {
                    withAnimation{
                        viewModel.navigateToPreviousWeek()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(viewModel.canNavigateBack ? .bluegreen : .gray)
                        .padding(.horizontal)
                }
                .disabled(!viewModel.canNavigateBack)
                
                Spacer()
                
                ForEach(week) { day in
                    VStack(spacing: 6) {
                        Text(day.date.format("E", using: viewModel.calendar))
                            .font(.caption)
                            .foregroundStyle(.gray)
                        
                        Text(day.date.format("dd", using: viewModel.calendar))
                            .font(.headline)
                            .foregroundStyle(viewModel.isSameDate(day.date, viewModel.currentDate) ? .white : .gray)
                            .frame(width: 35, height: 35)
                            .background(
                                Circle()
                                    .fill(viewModel.isSameDate(day.date, viewModel.currentDate) ? Color.bluegreen : Color.clear)
                            )
                            .overlay(
                                Circle()
                                    .fill(Color.cyan)
                                    .frame(width: 5, height: 5)
                                    .offset(y: 12)
                                    .opacity(day.date.isToday && !viewModel.isSameDate(day.date, viewModel.currentDate) ? 1 : 0)
                            )
                    }
                    .onTapGesture {
                        withAnimation {
                            viewModel.updateCurrentDate(to: day.date)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        viewModel.navigateToNextWeek()
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(viewModel.canNavigateForward ? .bluegreen : .gray)
                        .padding(.horizontal)
                }
                .disabled(!viewModel.canNavigateForward)
            }
            .padding(.vertical, 10)
            .hSpacing(.center)
        }
    }
}
    
#Preview {
    HabitEntityView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
