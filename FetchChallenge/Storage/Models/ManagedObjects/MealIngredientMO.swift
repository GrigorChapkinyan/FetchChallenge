//
//  MealIngredientMO.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation
import CoreData

final class MealIngredientMO: NSManagedObject {}

extension MealIngredientMO: IModelManagedObject {
    typealias PredicateKeys = MealIngredient.PredicateKeys
    
    // MARK: - IModelManagedObject

    func getStructObject() throws -> any IModelStructObject {
        guard let id = self.customId,
              let name = self.name,
              let measure = measure,
              let mealMetadataId = self.metadata?.mealId  else {
            throw IModelManagedObjectError.propertyIsNil
        }
        
        let mealCategory = MealIngredient(id: id, name: name, measure: measure, mealMetadataId: mealMetadataId)
        
        return mealCategory
    }
    
    static func getEntityName() -> String {
        return Constants.MealIngredientMO.Utils.entityName.rawValue
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

// MARK: - Constants + MealIngredientMO

fileprivate extension Constants {
    struct MealIngredientMO {
        enum Utils: String {
            case entityName = "MealIngredientMO"
        }
    }
}
