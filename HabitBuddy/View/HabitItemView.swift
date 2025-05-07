//
//  HabitItemView.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-04-29.
//

import SwiftUI
import CoreData

struct HabitItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: HabitViewModel
    @State private var navigateToDetail = false
    let isCompleted: Bool
    let isPastDate: Bool
    let currentDate: Date
    
    init(habit: HabitEntity, isCompleted: Bool, isPastDate: Bool, currentDate: Date, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        _viewModel = StateObject(wrappedValue: HabitViewModel(habit: habit, context: context))
        self.isCompleted = isCompleted
        self.isPastDate = isPastDate
        self.currentDate = currentDate
    }
    
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
            
            Button(action: {
                viewModel.markAsCompleted(on: currentDate)
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
            .disabled(isCompleted || !isToday() || currentDate > Date())
            .padding(.trailing)
            .contentShape(Rectangle())
        }
        .padding(.vertical, 12)
        
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
    }
    
    private func isToday() -> Bool {
        Calendar.current.isDateInToday(currentDate)
    }
    
    private func determineButtonColor() -> Color {
        if isPastDate && !isCompleted {
            return .gray
        } else if !isToday() || currentDate > Date() {
            return .gray
        } else {
            return .red
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let habit = HabitEntity(context: context)
    habit.title = "Läsa bok"
    habit.streak = 10
    habit.symbolName = "book.fill"
    
    return NavigationStack {
        HabitItemView(habit: habit, isCompleted: true, isPastDate: false, currentDate: Date(), context: context)
            .environment(\.managedObjectContext, context)
    }
}
