//
//  HabitDetailView.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-05-05.
//

import SwiftUI

struct HabitDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var habit: HabitEntity
    @State private var showingEditHabitView = false
    @State private var selectedSymbol: String = "star.fill"
    @State private var editedTitle: String = ""
    
    var body: some View {
        let habitTitle = habit.title ?? "din vana"
        let streak = Int(habit.streak)
        let daysThisWeek = streak % 7
        let fullWeeks = streak / 7
        
        ZStack{
            VStack(spacing: 20) {
                HStack{
                    Image(systemName: habit.symbolName ?? "star.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .foregroundColor(.turquoise)
                        .padding(.leading, 20)
                    
                    Text(habitTitle)
                        .font(.title)
                        .bold()
                        .fontDesign(.monospaced)
                        .foregroundColor(.primary)
                        .padding(.leading, 15)
                    
                    Spacer()
                    
                    Button(action: {
                        selectedSymbol = habit.symbolName ?? "star.fill"
                        editedTitle = habit.title ?? "din vana"
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
                
                VStack(alignment: .center, spacing: 10) {
                    Text(daysThisWeek < 3
                         ? "Du har utfört \(habitTitle) i \(daysThisWeek)/7 dagar denna vecka. Det här fixar du!💪"
                         : "Du har utfört \(habitTitle) i \(daysThisWeek)/7 dagar denna vecka. Snyggt jobbat!🎉")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    ProgressView(value: Double(daysThisWeek) / 7.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .turquoise))
                        .padding(.horizontal)
                        .padding(.vertical, 20)
                    
                    Text(fullWeeks == 0
                         ? "Ingen full vecka ännu, kämpa på!"
                         : fullWeeks == 1
                         ? "Du har utfört denna habit i 1 full vecka!🎊"
                         : "Du har utfört denna habit i \(fullWeeks) fulla veckor!🔥")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.turquoise)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                Spacer(minLength: 60)
            
                Spacer()
                    HStack{
                        Spacer()
                        Text("Totalt: \(streak) dagar")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
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
            .sheet(isPresented: $showingEditHabitView) {
                EditHabitView(
                    selectedSymbol: $selectedSymbol,
                    editedTitle: $editedTitle,
                    onSave: {
                        habit.symbolName = selectedSymbol
                        habit.title = editedTitle.isEmpty ? "din habit" : editedTitle
                        do {
                            try viewContext.save()
                        }catch {
                            print("Failed to save habit: \(error.localizedDescription)")
                        }
                    }
                )
            }
        }
    }

    
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


#Preview {
    let context = PersistenceController.preview.container.viewContext
    let habit = HabitEntity(context: context)
    habit.title = "Läsa bok"
    habit.streak = 10
    habit.symbolName = "book.fill"

    return NavigationStack {
        HabitDetailView(habit: habit)
            .environment(\.managedObjectContext, context)
    }
}
