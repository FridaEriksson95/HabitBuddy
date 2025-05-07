//
//  ContentView.swift
//  HabitBuddy
//
//  Created by Frida Eriksson on 2025-04-29.
//

import SwiftUI
import CoreData

struct ContentView: View {
    let context = PersistenceController.shared.container.viewContext

    var body: some View {
        HabitEntityView()
            .environment(\.managedObjectContext, context)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.BG)
            .preferredColorScheme(.light)
                }
            }

//#Preview {
//ContentView()
//    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
