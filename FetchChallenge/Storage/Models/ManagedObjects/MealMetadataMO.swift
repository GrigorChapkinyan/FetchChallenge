
//
//  MealMetadataMO.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation
import CoreData

final class MealMetadataMO: NSManagedObject {}

extension MealMetadataMO: IModelManagedObject {
    typealias PredicateKeys = MealMetadata.PredicateKeys
    
    // MARK: - IModelManagedObject

    func getStructObject() throws -> any IModelStructObject {
        guard let ingredientsSet = self.ingredients,
              let ingredientsMOArray = ingredientsSet.allObjects as? [MealIngredientMO],
              let mealId = self.mealId,
              let area = self.area,
              let instruction = self.instruction,
              let youtubeVideoUrlPath = self.youtubeVideoUrlPath,
              let sourceUrlPath = self.sourceUrlPath,
              let categoryId = self.meal?.category?.customId  else {
            throw IModelManagedObjectError.propertyIsNil
        }
        
        let mealIngredientsArray = try ingredientsMOArray.compactMap({ try $0.getStructObject() as? MealIngredient })
        let mealMetadata = MealMetadata(mealId: mealId, alternateDrinkName: self.alternateDrinkName, area: area, instruction: instruction, tag: self.tag, youtubeVideoUrlPath: youtubeVideoUrlPath, sourceUrlPath: sourceUrlPath, categoryId: categoryId, imageSourceUrlPath: self.imageSourceUrlPath, creativeCommonsConfirmed: self.creativeCommonsConfirmed, dateModified: self.dateModified, ingredients: mealIngredientsArray)
        
        return mealMetadata
    }
    
    static func getEntityName() -> String {
        return Constants.MealMetadataMO.Utils.entityName.rawValue
    }
    
    static func getNsPredicate(from predicateDict: [PredicateKeys : String]?) -> NSPredicate? {
        guard let predicateDict = predicateDict else {
            return nil
        }
        
        var nsPredicates = [NSPredicate]()
            
        for (key, val) in predicateDict {
            let nsPredicateToAppend = NSPredicate(format: "\(key.rawValue) = %@", val)
            nsPredicates.append(nsPredicateToAppend)
        }
             
        let combinedNsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: nsPredicates)
        return combinedNsPredicate
    }
}

// MARK: - Constants + MealMetadataMO

fileprivate extension Constants {
    struct MealMetadataMO {
        enum Utils: String {
            case entityName = "MealMetadataMO"
        }
    }
}
