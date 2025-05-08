//
//  Habit+CoreDataProperties.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-04-29.
//
//

import Foundation
import CoreData


extension HabitEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitEntity> {
        return NSFetchRequest<HabitEntity>(entityName: "HabitEntity")
    }
    
    //MARK: - properties for attributes
    @NSManaged public var lastCompletedDate: Date?
    @NSManaged public var isCompletedToday: Bool
    @NSManaged public var title: String?
    @NSManaged public var streak: Int16
    @NSManaged public var symbolName: String?
    @NSManaged public var createdDate: Date?
    @NSManaged public var completedDates: [Date]?
    @NSManaged public var notes: Data?
}

extension HabitEntity : Identifiable {
}
