//
//  HabitItemView.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-04-29.
//

import SwiftUI
import CoreData

/*View that shows one habit in list with titel, icon, progressindicator and "Finished"-button.
  Handles interactions like setting habit as done and navigate to detailView.
 Uses HabitViewModel to handle the habits data and entityViewModel to catch actual date and calendar.*/
struct HabitItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: HabitViewModel
    @ObservedObject var entityViewModel: HabitEntityViewModel
    @State private var navigateToDetail = false
    @State private var isCompleted: Bool
    let isPastDate: Bool
    private let habit: HabitEntity
    
    //MARK: - initialization
    //For specific habit
    init(habit: HabitEntity, isCompleted: Bool, isPastDate: Bool, entityViewModel: HabitEntityViewModel, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        _viewModel = StateObject(wrappedValue: HabitViewModel(habit: habit, context: context, calendar: entityViewModel.calendar))
        self.entityViewModel = entityViewModel
        self.habit = habit
        self._isCompleted = State(initialValue: entityViewModel.isHabitCompleted(habit, on: entityViewModel.currentDate))
        self.isPastDate = isPastDate
    }
    
    //MARK: - body/view
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                HStack{
                
                    Image(systemName: viewModel.symbolName)
                        .resizable()
                        .frame(width: 60, height: 55)
                        .foregroundColor(.turquoise)
                        .padding(.leading)
                    
                    Text(viewModel.title)
                        .font(.title)
                        .bold()
                        .fontDesign(.monospaced)
                        .foregroundColor(.primary)
                        .padding(.leading, 5)
            }
                .contentShape(Rectangle())
                .onTapGesture {
                navigateToDetail = true
            }
            
            Spacer()
            
                //Finished button to mark if habit is done or not, sets to red on currentdate, green if done, gray back and forward
            Button(action: {
                viewModel.markAsCompleted(on: entityViewModel.currentDate)
                isCompleted = viewModel.isHabitCompleted(on: entityViewModel.currentDate)
            }) {
                Label("Klar", systemImage: "checkmark.circle")
                    .foregroundColor(isCompleted ? .bluegreen : determineButtonColor())
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(isCompleted ? .bluegreen : determineButtonColor(), lineWidth: 2))
            }
            .buttonStyle(.plain)
            .disabled(isCompleted || !isToday() || isFutureDate())
            .padding(.trailing)
            .contentShape(Rectangle())
        }
        .padding(.vertical, 12)
        
            //Streak with progressview for how many days habit is done
        Text("🎖️: Avklarat i \(viewModel.streak)/7 dagar")
            .font(.subheadline)
            .foregroundColor(.turquoise)
            .padding(.leading)
            .hSpacing(.leading)
        
        ProgressView(value: viewModel.progressValue)
            .progressViewStyle(LinearProgressViewStyle(tint: .turquoise))
            .padding([.leading, .trailing, .bottom])
    }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .navigationDestination(isPresented: $navigateToDetail) {
            HabitDetailView(viewModel: viewModel)
        }
        
        //Updates isCompleted if actual date changes
        .onChange(of: entityViewModel.currentDate) {
            isCompleted = entityViewModel.isHabitCompleted(habit, on: entityViewModel.currentDate)
        }
        //Updates isCompleted if habit status changes for the currentdate
                .onChange(of: viewModel.isCompletedToday) {
                    if entityViewModel.isSameDate(entityViewModel.currentDate, Date()) {
                        isCompleted = viewModel.isCompletedToday
                    }
                }
    }
    
    //MARK: - methods
    //Checks if actual date is today
    private func isToday() -> Bool {
        let calendar = entityViewModel.calendar
        let normalizedDate = calendar.startOfDay(for: entityViewModel.currentDate)
        let normalizedToday = calendar.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        formatter.timeZone = calendar.timeZone
        let result = calendar.isDate(normalizedDate, inSameDayAs: normalizedToday)
        
        return result
    }
    
    //Checks if date is in future
    private func isFutureDate() -> Bool {
        let calendar = entityViewModel.calendar
        let normalizedDate = calendar.startOfDay(for: entityViewModel.currentDate)
        let normalizedToday = calendar.startOfDay(for: Date())
        
        return normalizedDate > normalizedToday
    }
    
    //Sets the color based on state and date
    private func determineButtonColor() -> Color {
       let color =  if isPastDate && !isCompleted {
           Color.gray
        } else if isFutureDate() || !isToday() {
             Color.gray
        } else {
             Color.red
        }
        return color
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let habit = HabitEntity(context: context)
    habit.title = "Läsa bok"
    habit.streak = 10
    habit.symbolName = "book.fill"
    let entityViewModel = HabitEntityViewModel(context: context)
    
    return NavigationStack {
        HabitItemView(habit: habit, isCompleted: true, isPastDate: false, entityViewModel: entityViewModel, context: context)
            .environment(\.managedObjectContext, context)
    }
}
