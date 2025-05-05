//
//  HabitItemView.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-04-29.
//

import SwiftUI

struct HabitItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var habit: HabitEntity
    @State private var navigateToDetail = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                HStack{
                    Image(systemName: habit.symbolName ?? "questionmark.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.turquoise)
                        .padding(.leading)
                    
                    Text(habit.title ?? "Ingen Titel")
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
                if !habit.isCompletedToday{
                    habit.isCompletedToday = true
                    habit.lastCompletedDate = Date()
                    habit.streak += 1
                    
                    try? viewContext.save()
                }
            }) {
                Label("Klar", systemImage: "checkmark.circle")
                    .foregroundColor(habit.isCompletedToday ? .bluegreen : .red)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(habit.isCompletedToday ? .bluegreen : .red, lineWidth: 2))
            }
            .buttonStyle(.plain)
            .disabled(habit.isCompletedToday)
            .padding(.trailing)
            .contentShape(Rectangle())
        }
        .padding(.vertical, 12)
        
        Text("🎖️: Avklarat i \(habit.streak)/7 dagar")
            .font(.subheadline)
            .foregroundColor(.turquoise)
            .padding(.leading)
        
        ProgressView(value: Double(habit.streak % 7) / 7.0)
            .progressViewStyle(LinearProgressViewStyle(tint: .turquoise))
            .padding([.leading, .trailing, .bottom])
    }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .navigationDestination(isPresented: $navigateToDetail) {
            HabitDetailView(habit: habit)
        }
        .onAppear {
            if let lastDate = habit.lastCompletedDate {
                if !Calendar.current.isDateInToday(lastDate) {
                    habit.isCompletedToday = false
                    try? viewContext.save()
                }
            }
        }
    }
}

//#Preview {
//    HabitEntityView()
//}
