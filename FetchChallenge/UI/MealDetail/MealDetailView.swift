//
//  MealDetailView.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/16/23.
//

import SwiftUI

struct MealDetailView: View {
    // MARK: - ObservedObjects
    
    @ObservedObject var viewModel: MealDetailViewModel
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { (geometry) in
            ScrollView {
                VStack {
                    if (viewModel.isFetchingFirstData) {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    else {
                        VStack {
                            VStack(alignment: .center) {
                                if let thumUrlPath = viewModel.thumbUrlPath {
                                    HStack(alignment: .center) {
                                        CachedAsyncImage(url: URL(string: thumUrlPath)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .clipShape(Circle())
                                        .shadow(radius: 10)
                                        .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                
                                if let name = viewModel.name {
                                    Spacer(minLength: geometry.size.width * 0.05)
                                    
                                    Text(name)
                                        .font(.largeTitle)
                                        .fontDesign(.serif)
                                        .fontWeight(.semibold)
                                        .lineLimit(nil)
                                        .multilineTextAlignment(.center)
                                }
                                
                                if let youtubeVideoId = viewModel.youtubeVideoId {
                                    let widthToSet = geometry.size.width * 0.8
                                    let heighToSet = widthToSet * (9 / 16)
                                    YoutubeView(videoID: youtubeVideoId)
                                        .frame(width: widthToSet, height:heighToSet)
                                }
                            }
                            
                            if let instructions = viewModel.instructions {
                                VStack(alignment: .leading) {
                                    Spacer(minLength: geometry.size.width * 0.05)
                                    
                                    Text(Constants.MealDetailView.HardCodedLabels.instructions.localizedString())
                                        .font(.headline)
                                        .fontDesign(.serif)
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                    
                                    Spacer(minLength: geometry.size.width * 0.05)
                                    
                                    Text(instructions)
                                        .font(.headline)
                                        .fontDesign(.serif)
                                        .fontWeight(.light)
                                        .lineLimit(nil)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                            
                            if let ingreditensListViewModel = viewModel.ingredientsListViewModel {
                                VStack(alignment: .center) {
                                    Spacer(minLength: geometry.size.width * 0.05)
                                    
                                    Text(Constants.MealDetailView.HardCodedLabels.ingredients.localizedString())
                                        .font(.headline)
                                        .fontDesign(.serif)
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                    
                                    Spacer(minLength: geometry.size.width * 0.05)
                                    
                                    let widthToSet = geometry.size.width * 0.8
                                    let heighToSet = widthToSet * 0.7
                                    
                                    MealIngredientsListView(viewModel: ingreditensListViewModel)
                                        .frame(width: widthToSet, height:heighToSet, alignment: .center)
                                }
                            }
                            
                            if let area = viewModel.area {
                                Spacer(minLength: geometry.size.width * 0.07)
                                
                                HStack {
                                    Text("\(Constants.MealDetailView.HardCodedLabels.area.localizedString()) \(area)")
                                        .font(.headline)
                                        .fontDesign(.serif)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            if let tag = viewModel.tag {
                                Spacer(minLength: geometry.size.width * 0.07)

                                HStack {
                                    Text("\(Constants.MealDetailView.HardCodedLabels.tags.localizedString()) \(tag)")
                                        .font(.headline)
                                        .fontDesign(.serif)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            if let alternateDrinkName = viewModel.alternateDrinkName {
                                Spacer(minLength: geometry.size.width * 0.07)

                                HStack {
                                    Text("\(Constants.MealDetailView.HardCodedLabels.alternateDrinkName.localizedString()) \(alternateDrinkName)")
                                        .font(.headline)
                                        .fontDesign(.serif)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            if let sourceUrlPath = viewModel.sourceUrlPath,
                               let _ = URL(string: sourceUrlPath) {
                                Spacer(minLength: geometry.size.width * 0.07)

                                HStack {
                                    let hyperlink = "[\(Constants.MealDetailView.HardCodedLabels.source.localizedString())](\(sourceUrlPath))"
                                    
                                    Text(.init(hyperlink))
                                        .font(.headline)
                                        .fontDesign(.serif)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            if let imageSourceUrlPath = viewModel.imageSourceUrlPath,
                               let _ = URL(string: imageSourceUrlPath) {
                                Spacer(minLength: geometry.size.width * 0.07)

                                HStack {
                                    let hyperlink = "[\(Constants.MealDetailView.HardCodedLabels.imageSource.localizedString())](\(imageSourceUrlPath))"
                                    
                                    Text(.init(hyperlink))
                                        .font(.headline)
                                        .fontDesign(.serif)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            if let dateModified = viewModel.dateModified {
                                Spacer(minLength: geometry.size.width * 0.07)

                                HStack {
                                    Text("\(Constants.MealDetailView.HardCodedLabels.dateModified.localizedString()) \(dateModified.description)")
                                        .font(.headline)
                                        .fontDesign(.serif)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
            }
            .refreshable {
                viewModel.refreshOnPull?()
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
    MealDetailView(viewModel: MealDetailViewModel(inMemoryLocalStorage: true, mealId: getTestMeal().id))
}

// MARK: - Constants + MealDetailView

fileprivate extension Constants {
    struct MealDetailView {
        enum HardCodedLabels: String, ILocalizableRawRepresentable {
            case instructions = "Instruction:"
            case area = "Area:"
            case tags = "Tags:"
            case alternateDrinkName = "Alternate Drink Name:"
            case dateModified = "Date Modified:"
            case imageSource = "Image Source"
            case source = "Source"
            case ingredients = "Ingredients:"
        }
    }
}
