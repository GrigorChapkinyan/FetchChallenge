//
//  MealCategoryRowViewModel.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/15/23.
//

import Foundation

final class MealCategoryRowViewModel: ObservableObject {
    // MARK: - Publishers
    
    @Published private(set) var id: String
    @Published private(set) var title: String
    @Published private(set) var thumbUrlPath: String
    @Published private(set) var description: String

    // MARK: - Private Properties
    
    private let mealCategory: MealCategory
    
    // MARK: - Initializers
    
    init(with mealCategory: MealCategory) {
        self.mealCategory = mealCategory
        self.title = mealCategory.name.trimmingCharacters(in: .whitespaces)
        self.thumbUrlPath = mealCategory.thumbUrlPath
        self.id = mealCategory.id
        self.description = mealCategory.descriptionStr.trimmingCharacters(in: .whitespaces)
    }
}
