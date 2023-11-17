//
//  MealCategoriesListViewModel.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/16/23.
//

import Foundation
import Combine

final class MealCategoriesListViewModel: BaseStorageConnectedViewModel<MealCategoryMO, MealCategory> {
    // MARK: - Output

    @Published private(set) var mealCategoryRowViewModels: [MealCategoryRowViewModel]? = nil    
    
    // MARK: - Initializers
    
    override init(
        inMemoryLocalStorage: Bool = false
    ) {
        super.init(inMemoryLocalStorage: inMemoryLocalStorage)
        self.sortDescriptor = SortDescriptor(\.id, order: .forward)
        self.fetchResultBlock = { [weak self] items in
            self?.mealCategoryRowViewModels = items?.compactMap({ $0 }).map({ MealCategoryRowViewModel(with: $0) })
        }
    }
}
