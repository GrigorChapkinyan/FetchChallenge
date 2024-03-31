//
//  MealCategoryRowView.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/15/23.
//

import SwiftUI

struct MealCategoryRowView: View {
    // MARK: - ObservedObjects
    
    @ObservedObject var viewModel: MealCategoryRowViewModel
    
    // MARK: - Body
    
    var body: some View {
        NavigationLink(destination: MealsListView(viewModel: MealsListViewModel(mealCategoryName: viewModel.title))) {
            VStack {
                GeometryReader { (geometry) in
                    HStack {
                        Text(viewModel.title)
                            .font(.largeTitle)
                            .fontDesign(.serif)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        CachedAsyncImage(url: URL(string: viewModel.thumbUrlPath)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .clipShape(Circle())
                        .shadow(radius: 5)
                    }
                    .frame(maxHeight: geometry.size.width * 0.3)
                }
                
                Spacer(minLength: 35)
                
                Text(viewModel.description)
                    .lineLimit(nil)
                    .font(.footnote)
                    .fontWeight(.ultraLight)
                    .fontDesign(.serif)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    MealCategoryRowView(viewModel: MealCategoryRowViewModel(with: getTestMealCategory()))
}

func getTestMealCategory() -> MealCategory {
    return MealCategory(id: UUID().uuidString, name: "Dessert", thumbUrlPath: "https://www.themealdb.com/images/category/dessert.png", categoryDescription: "Dessert is a course that concludes a meal. The course usually consists of sweet foods, such as confections dishes or fruit, and possibly a beverage such as dessert wine or liqueur, however in the United States it may include coffee, cheeses, nuts, or other savory items regarded as a separate course elsewhere. In some parts of the world, such as much of central and western Africa, and most parts of China, there is no tradition of a dessert course to conclude a meal.\r\n\r\nThe term dessert can apply to many confections, such as biscuits, cakes, cookies, custards, gelatins, ice creams, pastries, pies, puddings, and sweet soups, and tarts. Fruit is also commonly found in dessert courses because of its naturally occurring sweetness. Some cultures sweeten foods that are more commonly savory to create desserts.", meals:
                            Array<Meal>(repeating: getTestMeal(), count: 7)
    )
}

func getTestMeal() -> Meal {
    return Meal(id: UUID().uuidString, metadata: MealMetadata(mealId: "52897", alternateDrinkName: "DrinkName", area: "British", instruction: "For the carrot cake, preheat the oven to 160C/325F/Gas 3. Grease and line a 26cm/10in springform cake tin.\r\nMix all of the ingredients for the carrot cake, except the carrots and walnuts, together in a bowl until well combined. Stir in the carrots and walnuts.\r\nSpoon the mixture into the cake tin and bake for 1 hour 15 minutes, or until a skewer inserted into the middle comes out clean. Remove the cake from the oven and set aside to cool for 10 minutes, then carefully remove the cake from the tin and set aside to cool completely on a cooling rack.\r\nMeanwhile, for the icing, beat the cream cheese, caster sugar and butter together in a bowl until fluffy. Spread the icing over the top of the cake with a palette knife.", tag: "Cake,Treat,Sweet", youtubeVideoUrlPath: "https://www.youtube.com/watch?v=asjZ7iTrGKA", sourceUrlPath: "https://www.bbc.co.uk/food/recipes/classic_carrot_cake_08513", categoryId: "3", imageSourceUrlPath: nil, creativeCommonsConfirmed: nil, dateModified: nil, ingredients: [MealIngredient(id: "528971", name: "Vegetable Oil", measure: "450ml", mealMetadataId: "52897")]), name: "Carrot Cake", thumUrlPath: "https://www.themealdb.com/images/media/meals/vrspxv1511722107.jpg", categoryName: "Dessert")
}
