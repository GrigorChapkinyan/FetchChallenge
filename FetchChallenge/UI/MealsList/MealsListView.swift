//
//  MealsListView.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/16/23.
//

import SwiftUI

struct MealsListView: View {
    // MARK: - StateObjects

    @StateObject var viewModel: MealsListViewModel
   
    // MARK: - Body

    var body: some View {
        GeometryReader { (geometry) in
            VStack {
                if (viewModel.isFetchingFirstData) {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else {
                    if let mealRowViewModels = viewModel.mealRowViewModels {
                        List {
                            ForEach(mealRowViewModels, id: \.id) {
                                mealRowViewModel in
                                MealRowView(viewModel: mealRowViewModel)
                                    .frame(maxHeight: geometry.size.width * 0.1)
                                    .padding(.vertical, geometry.size.width * 0.05)
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
}


#Preview {
    MealsListView(viewModel: MealsListViewModel(inMemoryLocalStorage: true, mealCategoryName: "Dessert"))
}
