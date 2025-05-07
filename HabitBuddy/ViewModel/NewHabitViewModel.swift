//
//  NewHabitViewModel.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-05-06.
//

import Foundation
import SwiftUI
import CoreData

class NewHabitViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var selectedSymbol : String = "photo"
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    var isSaveButtenDisabled: Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func saveHabit() -> Bool {
        let newHabit = HabitEntity(context: context)
        newHabit.title = title
        newHabit.streak = 0
        newHabit.isCompletedToday = false
        newHabit.lastCompletedDate = nil
        newHabit.symbolName = selectedSymbol
        newHabit.createdDate = Calendar.current.startOfDay(for: Date())
        newHabit.completedDates = []
        
        do{
            try context.save()
            return true
        }catch {
            print("Fel vid sparning av habit: \(error.localizedDescription)")
            return false
        }
    }
    
    func resetFields() {
        title = ""
        selectedSymbol = "photo"
    }
}

