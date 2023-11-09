//
//  FetchChallengeApp.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import SwiftUI

@main
struct FetchChallengeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
