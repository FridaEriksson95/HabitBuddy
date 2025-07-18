//
//  HabitDetailView.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-05-05.
//

import SwiftUI

//View that holds the details of days, weeks and notes when navigation in to specific habit
struct HabitDetailView: View {
    @StateObject private var viewModel: HabitViewModel
    @State private var showingEditHabitView = false
    @State private var selectedSymbol: String
    @State private var editedTitle: String
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    private let calendar: Calendar
    
    //MARK: - initialization
    init(viewModel: HabitViewModel, calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone.current
        return cal
    }()) {
        self.calendar = calendar
        _viewModel = StateObject(wrappedValue: viewModel)
        _selectedSymbol = State(initialValue: viewModel.symbolName)
        _editedTitle = State(initialValue: viewModel.title)
        let today = calendar.dateComponents([.year, .month], from: Date())
        
        _selectedYear = State(initialValue: today.year ?? 2025)
        _selectedMonth = State(initialValue: today.month ?? 5)
    }
    
    //MARK: - body/view
    var body: some View {
        ZStack{
            ScrollView {
                VStack(spacing: 20) {
                    HStack{
                        Image(systemName: viewModel.symbolName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                            .foregroundColor(.turquoise)
                            .padding(.leading, 20)
                        
                        Text(viewModel.title)
                            .font(.title)
                            .bold()
                            .fontDesign(.monospaced)
                            .foregroundColor(.primary)
                            .padding(.leading, 15)
                        
                        Spacer()
                        
                        Button(action: {
                            showingEditHabitView = true
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.black)
                                .font(.largeTitle)
                        }
                        .padding(.trailing)
                        
                    }
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                    
                    VStack(alignment: .center, spacing: 1) {
                        Text(viewModel.daysThisWeek < 3
                             ? "Du har utfört \(viewModel.title) i \(viewModel.daysThisWeek)/7 dagar denna vecka. Det här fixar du!💪"
                             : "Du har utfört \(viewModel.title) i \(viewModel.daysThisWeek)/7 dagar denna vecka. Snyggt jobbat!🎉")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        
                        ProgressView(value: viewModel.progressValue)
                            .progressViewStyle(LinearProgressViewStyle(tint: .turquoise))
                            .padding(.horizontal)
                            .padding(.vertical, 20)
                        
                        Text(viewModel.fullWeeks == 0
                             ? "Ingen full vecka ännu, kämpa på!"
                             : viewModel.fullWeeks == 1
                             ? "Du har utfört denna habit i 1 full vecka!🎊"
                             : "Du har utfört denna habit i \(viewModel.fullWeeks) fulla veckor!🔥")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.turquoise)
                        .padding(.horizontal)
                        .padding(.top, 5)
                        .padding(.bottom, 10)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        
                        VStack{
                            Divider()
                            Spacer()
                            HStack {
                                Button(action: {
                                    if selectedMonth == 1 {
                                        selectedMonth = 12
                                        selectedYear -= 1
                                    } else {
                                        selectedMonth -= 1
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.bluegreen)
                                }
                                Spacer()
                                Spacer()
                                
                                Button(action: {
                                    if selectedMonth == 12 {
                                        selectedMonth = 1
                                        selectedYear += 1
                                    } else {
                                        selectedMonth += 1
                                    }
                                }) {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.bluegreen)
                                }
                            }
                            .padding(.horizontal)
                            
                            CalendarView(
                                year: selectedYear, month: selectedMonth, completedDates: viewModel.completedDatesInMonth(year: selectedYear, month: selectedMonth), viewModel: viewModel,
                                    calendar: calendar)
                        }
                        .padding(.vertical, 30)
                        
                        .vSpacing(.center)
                        Divider()
                        
                        HStack{
                            Spacer()
                            Text("Totalt: \(viewModel.streak) dagar")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 15)
                        }
                    }
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Streakdetaljer")
            .font(.callout)
            .padding(.bottom, 10)
            .sheet(isPresented: $showingEditHabitView) {
                EditHabitView(
                    selectedSymbol: $selectedSymbol,
                    editedTitle: $editedTitle,
                    onSave: {
                        viewModel.updateHabit(newTitle: editedTitle, newSymbol: selectedSymbol)
                    }
                )
            }
        }
    }
}
    
//Set the view to edit specific habit with title and symbol
struct EditHabitView: View {
        @Binding var selectedSymbol: String
        @Binding var editedTitle: String
        let onSave:() -> Void
        @Environment(\.dismiss) private var dismiss
            
            var body: some View {
                NavigationStack {
                    Form {
                        Section(header: Text("Namn på habit")) {
                            TextField("Ange namn", text: $editedTitle)
                                .textFieldStyle(.roundedBorder)
                                .padding(.vertical, 5)
                        }
                        Section(header: Text("Välj Symbol")){
                            List {
                                ForEach(HabitSymbols.all) { symbol in
                                    HStack{
                                        Image(systemName: symbol.systemName)
                                            .foregroundColor(.turquoise)
                                            .font(.title2)
                                            .frame(width: 40, alignment: .center)
                                        Text(symbol.displayName)
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Spacer()
                                        if symbol.systemName == selectedSymbol {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.bluegreen)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedSymbol = symbol.systemName
                                    }
                                    .accessibilityLabel(symbol.displayName)
                                }
                            }
                        }
                    }
                    .navigationTitle("Upddatera Habit")
                    .toolbar{
                        ToolbarItem(placement: .cancellationAction){
                            Button("Avbryt") {
                                dismiss()
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Spara"){
                                onSave()
                                dismiss()
                            }
                        }
                    }
                }
            }
        }


//#Preview {
//    let context = PersistenceController.preview.container.viewContext
//    let habit = HabitEntity(context: context)
//    habit.title = "Läsa bok"
//    habit.streak = 10
//    habit.symbolName = "book.fill"
//    let calendar = {
//          var cal = Calendar.current
//          cal.timeZone = TimeZone.current
//          return cal
//      }()
//    
//    habit.completedDates = [
//        calendar.date(from: DateComponents(year: 2025, month: 5, day: 5))!,
//        calendar.date(from: DateComponents(year: 2025, month: 5, day: 10))!,
//        calendar.date(from: DateComponents(year: 2025, month: 5, day: 15))! ]
//    
//    let viewModel = HabitViewModel(habit: habit, context: context, calendar: calendar)
//    
//    NavigationStack {
//        HabitDetailView(viewModel: viewModel, calendar: calendar)
//            .environment(\.managedObjectContext, context)
//    }
//}
