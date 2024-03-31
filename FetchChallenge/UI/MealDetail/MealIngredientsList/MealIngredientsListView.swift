//
//  MealIngredientsListView.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/17/23.
//

import SwiftUI

struct MealIngredientsListView: View {
    // MARK: - ObservedObjects
    
    @ObservedObject var viewModel: MealIngredientsListViewModel
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { (geometry) in
            VStack {
                List {
                    ForEach(viewModel.ingredients, id: \.id) {
                        ingredientIter in
                        HStack {
                            Text(ingredientIter.name)
                                .font(.headline)
                                .fontDesign(.serif)
                                .fontWeight(.ultraLight)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(ingredientIter.measure)
                                .font(.headline)
                                .fontDesign(.serif)
                                .fontWeight(.ultraLight)
                                .lineLimit(1)
                        }
                        .frame(maxHeight: geometry.size.width * 0.1)
                    }
                }
            }
        }
    }
}

#Preview {
    MealIngredientsListView(
        viewModel: MealIngredientsListViewModel(with: getTestMeal().metadata?.ingredients ?? [])
    )
}
