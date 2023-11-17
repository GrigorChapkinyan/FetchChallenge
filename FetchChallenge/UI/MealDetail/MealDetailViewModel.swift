//
//  MealDetailViewModel.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/16/23.
//

import Foundation
import Combine

final class MealDetailViewModel: BaseStorageConnectedViewModel<MealMO, Meal> {
    // MARK: - Output

    @Published private(set) var name: String?
    @Published private(set) var instructions: String?
    @Published private(set) var area: String?
    @Published private(set) var thumbUrlPath: String?
    @Published private(set) var tag: String?
    @Published private(set) var alternateDrinkName: String?
    @Published private(set) var sourceUrlPath: String?
    @Published private(set) var imageSourceUrlPath: String?
    @Published private(set) var dateModified: Date?
    @Published private(set) var ingredientsListViewModel: MealIngredientsListViewModel?
    @Published private(set) var youtubeVideoId: String?

    // MARK: - Private Properties
    
    private let mealId: String
    
    // MARK: - Initializers
    
    init(
        inMemoryLocalStorage: Bool = false,
        mealId: String
    ) {
        self.mealId = mealId
        super.init(inMemoryLocalStorage: inMemoryLocalStorage)
        self.predicateDict = [.id : mealId]
        self.fetchResultBlock = { [weak self] items in
            if let meal = items?.compactMap({ $0 }).first {
                self?.name = meal.name
                self?.instructions = meal.metadata?.instruction
                self?.area = meal.metadata?.area
                self?.thumbUrlPath = meal.thumUrlPath
                self?.tag = meal.metadata?.tag
                self?.alternateDrinkName = meal.metadata?.alternateDrinkName
                self?.sourceUrlPath = meal.metadata?.sourceUrlPath
                self?.imageSourceUrlPath = meal.metadata?.imageSourceUrlPath
                self?.dateModified = meal.metadata?.dateModified

                // Setting Ingredients
                if let ingredients = meal.metadata?.ingredients {
                    self?.ingredientsListViewModel = MealIngredientsListViewModel(with: ingredients)
                }
                
                // Setting youtube video id
                if let youtubeVideoUrlPath = meal.metadata?.youtubeVideoUrlPath {
                    let youtubeVideoId = getYoutubeId(youtubeUrl: youtubeVideoUrlPath)
                    self?.youtubeVideoId = youtubeVideoId
                }
                else {
                    self?.youtubeVideoId = nil
                }
            }
        }
    }
}

fileprivate func getYoutubeId(youtubeUrl: String) -> String? {
    return URLComponents(string: youtubeUrl)?.queryItems?.first(where: { $0.name == "v" })?.value
}
