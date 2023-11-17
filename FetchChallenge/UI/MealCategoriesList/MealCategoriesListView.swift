//
//  MealCategoriesListView.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/15/23.
//

import SwiftUI

struct MealCategoriesListView: View {
    // MARK: - ObservedObjects
    
    @ObservedObject var viewModel: MealCategoriesListViewModel

    // MARK: - Body

    var body: some View {
        NavigationView {
            if (viewModel.isFetchingFirstData) {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                if let mealCategoryRowViewModels = viewModel.mealCategoryRowViewModels {
                    List {
                        ForEach(mealCategoryRowViewModels, id: \.id) {
                            mealCategoryViewModel in
                            MealCategoryRowView(viewModel: mealCategoryViewModel)
                        }
                    }
                    .refreshable {
                        viewModel.refreshOnPull?()
                    }
                    .listStyle(.automatic)
                }
            }
        }
        .alert(viewModel.error?.localizedDescription ?? "", isPresented: $viewModel.presentAlert) {
            Button(Constants.HardCodedLabels.okay.localizedString(), role: .cancel) { }
        }
        .onAppear(perform: {
            viewModel.refreshOnAppear?()
        })
    }
}

#Preview {
    MealCategoriesListView(
        viewModel: MealCategoriesListViewModel(inMemoryLocalStorage: true)
    )
}
