//
//  MealsListViewModel.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/16/23.
//

import Foundation
import Combine

final class MealsListViewModel: BaseStorageConnectedViewModel<MealMO, Meal> {
    // MARK: - Output

    @Published private(set) var mealRowViewModels: [MealRowViewModel]? = nil
    
    // MARK: - Private Properties
    
    private let mealCategoryName: String
    
    // MARK: - Initializers
    
    init(
        inMemoryLocalStorage: Bool = false,
        mealCategoryName: String
    ) {
        self.mealCategoryName = mealCategoryName
        super.init(inMemoryLocalStorage: inMemoryLocalStorage)
        self.sortDescriptor = SortDescriptor(\.id, order: .forward)
        self.predicateDict = [.categoryName: mealCategoryName]
        self.fetchResultBlock = { [weak self] items in
            self?.mealRowViewModels = items?.compactMap({ $0 }).map({ MealRowViewModel(with: $0) })
        }
    }
}
