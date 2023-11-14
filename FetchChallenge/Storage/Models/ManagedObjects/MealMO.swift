//
//  MealMO.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation
import CoreData

final class MealMO: NSManagedObject {}

extension MealMO: IModelManagedObject {
    typealias PredicateKeys = Meal.PredicateKeys
    
    // MARK: - MealMO
    
    func getStructObject() throws -> any IModelStructObject {
        guard let id = self.customId,
              let name = self.name else {
            throw IModelManagedObjectError.propertyIsNil
        }
        
        let metadata = try self.metadata?.getStructObject() as? MealMetadata
        let meal = Meal(id: id, metadata: metadata, name: name, thumUrlPath: thumUrlPath)
        
        return meal
    }
    
    static func getEntityName() -> String {
        return Constants.MealMO.Utils.entityName.rawValue
    }
    
    static func getNsPredicate(from predicateDict: [PredicateKeys : String]?) -> NSPredicate? {
        guard let predicateDict = predicateDict else {
            return nil
        }
        
        var nsPredicates = [NSPredicate]()
            
        for (key, val) in predicateDict {
            switch key {
                case .id:
                    let nsPredicateToAppend = NSPredicate(format: "customId = %@", val)
                    nsPredicates.append(nsPredicateToAppend)
                
                default:
                    let nsPredicateToAppend = NSPredicate(format: "\(key.rawValue) = %@", val)
                    nsPredicates.append(nsPredicateToAppend)
            }
        }
             
        let combinedNsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: nsPredicates)
        return combinedNsPredicate
    }
}

// MARK: - Constants + MealMO

fileprivate extension Constants {
    struct MealMO {
        enum Utils: String {
            case entityName = "MealMO"
        }
    }
}
