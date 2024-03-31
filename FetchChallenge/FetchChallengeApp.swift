//
//  FetchChallengeApp.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import SwiftUI

@main
struct FetchChallengeApp: App {
    @StateObject private var mealCategoriesListViewModel = MealCategoriesListViewModel()

    var body: some Scene {
        WindowGroup {
            // Unit tests
            if NSClassFromString(Constants.FetchChallengeApp.Utils.xcTestCase.rawValue) != nil {
                
            }
            // Application
            else {
                MealCategoriesListView(viewModel: mealCategoriesListViewModel)
            }
        }
    }
}

// MARK: - Constants + FetchChallengeApp

fileprivate extension Constants {
    struct FetchChallengeApp {
        enum Utils: String {
            case xcTestCase = "XCTestCase"
        }
    }
}
