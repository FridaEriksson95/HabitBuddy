//
//  NewHabitViewModel.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-05-06.
//

import Foundation
import SwiftUI
import CoreData

/*
 Handles the logic to create new habit and saves it in CoreData. Keeps track of title and icon and validates before saving.
 */
class NewHabitViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var selectedSymbol : String = "photo"
    
    private let context: NSManagedObjectContext
    private let calendar: Calendar
    
    //MARK: - initialization
    init(context: NSManagedObjectContext, calendar: Calendar) {
        self.context = context
        self.calendar = calendar
    }
    
    //Determents if save button is activated
    var isSaveButtenDisabled: Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    //MARK: - methods
    //Saves the new habit in CoreData
    func saveHabit() -> Bool {
        let newHabit = HabitEntity(context: context)
        newHabit.title = title
        newHabit.streak = 0
        newHabit.isCompletedToday = false
        newHabit.lastCompletedDate = nil
        newHabit.symbolName = selectedSymbol
        
        let now = Date()
        let normalizedDate = calendar.startOfDay(for: now)
        newHabit.createdDate = normalizedDate
        newHabit.completedDates = []
        
        do{
            try context.save()
            return true
        }catch {
            print("error saving habit: \(error.localizedDescription)")
            return false
        }
    }
    
    //Resets the formularfields to origin values
    func resetFields() {
        title = ""
        selectedSymbol = "photo"
    }
}
