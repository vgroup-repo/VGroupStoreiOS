//
//  JustToysWorldAppApp.swift
//  JustToysWorldApp
//
//  Created by Satyam on 20/11/25.
//

import SwiftUI
import CoreData

@main
struct JustToysWorldAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        
    }
}
