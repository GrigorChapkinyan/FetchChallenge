//
//  MealIngredient.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation
import CoreData

struct MealIngredient: IModelStructObject {
    // MARK: - Public Properties
    
    let id: String
    let name: String
    let measure: String
    let mealMetadataId: String

    // MARK: - Nested Types
    
    enum PredicateKeys: String, IPredicateKeys {
        case id = "id"
        case name = "name"
        case measure = "measure"
        case mealMetadataId = "mealMetadataId"
    }
    
    enum PropertiesRepresantable: IPropertiesRepresantable  {
        case id
        case name
        case measure
        case mealMetadataId
    }
    
    // MARK: - Decodable
    
    init(id: String, name: String, measure: String, mealMetadataId: String) {
        self.id = id
        self.name = name
        self.measure = measure
        self.mealMetadataId = mealMetadataId
    }
    
    // MARK: - IModelStructObject
    
    func getManagedObject(context: NSManagedObjectContext, ignorablePropertiesForOverwrite: [PropertiesRepresantable] = []) throws -> any IModelManagedObject {
        // First trying to fetch the object from the local storage,
        // maybe item with the same id alread exist
        let fetchRequest = MealIngredientMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "customId = %@", self.id)
        let alreadyStoredMealIngredientMO = try? context.fetch(fetchRequest).first
        
        // If object don't exist in local storgae,
        // we will create a new one
        let mealIngredientMO = alreadyStoredMealIngredientMO ?? MealIngredientMO(entity: MealIngredientMO.entity(), insertInto: context)
        let isNewMO = alreadyStoredMealIngredientMO == nil
        
        // Checking if the "name" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.name)) {
            mealIngredientMO.name = self.name
        }
        
        // Checking if the "measure" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.measure)) {
            mealIngredientMO.measure = self.measure
        }
        
        // Checking if the "id" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.id)) {
            mealIngredientMO.customId = self.id
        }

        return mealIngredientMO
    }
    
    static func convertRemoteStorageRequestToHttpRequest(_ remoteStorageRequest: BaseRemoteStorageRequest<Self>) throws -> HTTPRequest {
        switch remoteStorageRequest.requestType {
            case .fetch(_, _, _):
                throw BaseRemoteStorageRequestExecutorError.noProvidedApiForCurrentAction
            
            case .add(_):
                throw BaseRemoteStorageRequestExecutorError.noProvidedApiForCurrentAction
            
            case .delete(_):
                throw BaseRemoteStorageRequestExecutorError.noProvidedApiForCurrentAction
        }
    }
    
    static func getDecoder(for remoteStorageRequest: BaseRemoteStorageRequest<Self>) -> JSONDecoder {
        let jsonDecoder = JSONDecoder()
        return jsonDecoder
    }
    
    static func expectArray(for baseRemoteStorageRequestType: BaseRemoteStorageRequest<Self>.RequestType) -> Bool {
        var retVal: Bool
        
        // Just for showing
        switch baseRemoteStorageRequestType {
            case .fetch:
                retVal = false
            case .add:
                retVal = false
            case .delete:
                retVal = false
        }
        
        return retVal
    }
    
    static func getQueryItems(from predicateDict: [PredicateKeys : String]?) -> [URLQueryItem]? {
        return nil
    }
}
