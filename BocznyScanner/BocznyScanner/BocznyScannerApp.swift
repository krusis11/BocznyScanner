//
//  BocznyScannerApp.swift
//  BocznyScanner
//
//  Created by Marcus on 24/11/2024.
//

import SwiftUI

@main
struct BocznyScannerApp: App {
    let persistenceController = PersistenceController.shared
    

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        
    }
}
