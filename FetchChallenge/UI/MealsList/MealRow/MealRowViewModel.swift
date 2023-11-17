//
//  MealRowViewModel.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/16/23.
//

import Foundation

final class MealRowViewModel: ObservableObject, Identifiable {
    // MARK: - Publishers

    @Published private(set) var meal: Meal
    
    // MARK: - Initializers
    
    init(with meal: Meal) {
        self.meal = meal
    }
}
