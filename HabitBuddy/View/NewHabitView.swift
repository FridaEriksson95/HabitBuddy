//
//  NewHabitView.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-04-30.
//

import SwiftUI
import CoreData

struct NewHabitView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: NewHabitViewModel
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        _viewModel = StateObject(wrappedValue: NewHabitViewModel(context: context))
    }
    
    var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Ny habit")) {
                        TextField("Lägg till ny habit", text: $viewModel.title)
                            .textInputAutocapitalization(.sentences)
                    }
                    Section(header: Text("Välj ikon")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(HabitSymbols.all) { symbol in
                                    HabitSymbolView(
                                        symbol: symbol,
                                        isSelected: viewModel.selectedSymbol == symbol.systemName
                                    ){
                                        viewModel.selectedSymbol = symbol.systemName
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal)
                        }
                    }
                    Button(action: {
                        if viewModel.saveHabit() {
                            dismiss()
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Spara")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isSaveButtenDisabled)
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
    NavigationView {
        NewHabitView(context: context)
            .environment(\.managedObjectContext, context)
    }
}
