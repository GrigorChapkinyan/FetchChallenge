//
//  MealCategoryMO.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation
import CoreData

final class MealCategoryMO: NSManagedObject {}

extension MealCategoryMO: IModelManagedObject {
    typealias PredicateKeys = MealCategory.PredicateKeys
    
    // MARK: - IModelManagedObject
    
    func getStructObject() throws -> any IModelStructObject {
        guard let mealsSet = meals,
              let mealMOArray = mealsSet.allObjects as? [MealMO],
              let id = self.customId,
              let name = self.name else {
            throw IModelManagedObjectError.propertyIsNil
        }
        
        let mealsArray = try mealMOArray.compactMap({ try $0.getStructObject() as? Meal })
        let mealCategory = MealCategory(id: id, name: name, meals: mealsArray)
        
        return mealCategory
    }
    
    static func getEntityName() -> String {
        return Constants.MealCategoryMO.Utils.entityName.rawValue
    }
    
    static func getNsPredicate(from predicateDict: [PredicateKeys : String]?) -> NSPredicate? {
        guard let predicateDict = predicateDict else {
            return nil
        }
        
        var nsPredicates = [NSPredicate]()
            
        for (key, val) in predicateDict {
            switch key {
                case .name:
                    let nsPredicateToAppend = NSPredicate(format: "\(key.rawValue) = %@", val)
                    nsPredicates.append(nsPredicateToAppend)
                
                case .id:
                    let nsPredicateToAppend = NSPredicate(format: "customId = %@", val)
                    nsPredicates.append(nsPredicateToAppend)
            }
        }
             
        let combinedNsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: nsPredicates)
        return combinedNsPredicate
    }
}

// MARK: - Constants + MealCategoryMO

fileprivate extension Constants {
    struct MealCategoryMO {
        enum Utils: String {
            case entityName = "MealCategoryMO"
        }
    }
}
