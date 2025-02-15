//
//  messagesApp.swift
//  messages
//
//  Created by Andrew Morrison on 2/15/25.
//

import SwiftUI

@main
struct messagesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
