//
//  NewHabitView.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-04-30.
//

import SwiftUI

struct NewHabitView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var selectedSymbol : String = "photo"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ny habit")) {
                    TextField("Lägg till ny habit", text: $title)
                        .textInputAutocapitalization(.sentences)
                }
                Section(header: Text("Välj ikon")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(HabitSymbols.all) { symbol in
                                HabitSymbolView(
                                    symbol: symbol,
                                    isSelected: selectedSymbol == symbol.systemName
                                ){
                                    selectedSymbol = symbol.systemName
                                }
                            }
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                
                    }
                }
                
                Button(action: {
                    let newHabit = HabitEntity(context: viewContext)
                    newHabit.title = title
                    newHabit.streak = 0
                    newHabit.isCompletedToday = false
                    newHabit.lastCompletedDate = nil
                    newHabit.symbolName = selectedSymbol
                    
                    do{
                        try viewContext.save()
                        dismiss()
                    }catch {
                        print("Fel vid sparning av habit: \(error.localizedDescription)")
                    }
                    
                }) {
                    HStack {
                        Spacer()
                        Text("Spara")
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                
            }
            .navigationTitle("Lägg till")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct HabitSymbolView: View {
    let symbol: HabitSymbol
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.turquoise.opacity(0.3) : Color.gray.opacity(0.1))
                .frame(width: 60, height: 60)
            
            VStack{
                Image(systemName: symbol.systemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.primary)
                Text(symbol.displayName)
                    .font(.caption2)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .padding(.top, 2)
            }
    }
            .onTapGesture {
                onTap()
            }
            .accessibilityLabel(symbol.displayName)
    }
}
  

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return NavigationView {
        NewHabitView()
            .environment(\.managedObjectContext, context)
    }
}
