//
//  MealRowView.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/16/23.
//

import SwiftUI

struct MealRowView: View {
    // MARK: - StateObjects
    
    @StateObject var viewModel: MealRowViewModel
    
    // MARK: - Body
    
    var body: some View {
        NavigationLink(destination: MealDetailView(viewModel: MealDetailViewModel(mealId: viewModel.meal.id))) {
            VStack {
                HStack {
                    Text(viewModel.meal.name)
                        .font(.headline)
                        .fontDesign(.serif)
                        .fontWeight(.ultraLight)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if let thumbUrlPath = viewModel.meal.thumUrlPath {
                        CachedAsyncImage(url: URL(string: thumbUrlPath)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .clipShape(Circle())
                        .shadow(radius: 5)
                    }
                }
            }
        }
    }
}

#Preview {
    MealRowView(
        viewModel: MealRowViewModel(with: getTestMeal())
    )
}
