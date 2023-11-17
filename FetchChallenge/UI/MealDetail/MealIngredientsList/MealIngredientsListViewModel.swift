//
//  MealIngredientsListViewModel.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/17/23.
//

import Foundation

final class MealIngredientsListViewModel: ObservableObject, Identifiable {
    // MARK: - Publishers

    @Published private(set) var ingredients: [MealIngredient]
    
    // MARK: - Initializers
    
    init(with ingredients: [MealIngredient]) {
        self.ingredients = ingredients
    }
}
