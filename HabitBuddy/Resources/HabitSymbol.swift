//
//  HabitSymbols.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-05-05.
//

import Foundation

/*
 Holds the different symbols and names for each
 */
struct HabitSymbol : Identifiable, Hashable {
    let id = UUID()
    let systemName: String
    let displayName: String
}

struct HabitSymbols {
    static let all: [HabitSymbol] = [
        HabitSymbol(systemName: "dumbbell.fill", displayName: "Träning"),
        HabitSymbol(systemName: "book.fill", displayName: "Läsning"),
        HabitSymbol(systemName: "figure.walk", displayName: "Promenad"),
        HabitSymbol(systemName: "music.note", displayName: "Musik"),
        HabitSymbol(systemName: "fork.knife.circle.fill", displayName: "Matlagning"),
        HabitSymbol(systemName: "washer.fill", displayName: "Tvätt"),
        HabitSymbol(systemName: "dishwasher.fill", displayName: "Disk"),
        HabitSymbol(systemName: "robotic.vacuum.fill", displayName: "Dammsugning"),
        HabitSymbol(systemName: "laptopcomputer", displayName: "Arbete"),
        HabitSymbol(systemName: "calendar.and.person", displayName: "Planering"),
        HabitSymbol(systemName: "powersleep", displayName: "Sömn"),
        HabitSymbol(systemName: "bag", displayName: "Shopping"),
        HabitSymbol(systemName: "cart.fill", displayName: "Handla mat"),
        HabitSymbol(systemName: "giftcard.fill", displayName: "Present"),
        HabitSymbol(systemName: "figure.2.and.child.holdinghands", displayName: "Familjetid"),
        HabitSymbol(systemName: "figure.and.child.holdinghands", displayName: "Tid med barn"),
    ]
}
