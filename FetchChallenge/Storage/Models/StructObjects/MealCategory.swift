//
//  MealCategory.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation
import CoreData

struct MealCategory: IModelStructObject {
    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case id = "idCategory"
        case name = "strCategory"
        case thumbUrlPath = "strCategoryThumb"
        case descriptionStr = "strCategoryDescription"
    }
    
    // MARK: - Nested Types
    
    enum PredicateKeys: String, IPredicateKeys {
        case id
        case name
        case thumbUrlPath
        case descriptionStr
    }

    enum PropertiesRepresantable: IPropertiesRepresantable  {
        case id
        case name
        case thumbUrlPath
        case descriptionStr
        case meals
        case mealsProperties(keys: Meal.PropertiesRepresantable)
    }
    
    struct WrapperObject: IWrapperObject {
        var items: [MealCategory]
        
        enum CodingKeys: String, CodingKey, CaseIterable {
            case items = "categories"
        }
    }
    
    // MARK: - Public Properties
    
    var id: String
    var name: String
    var thumbUrlPath: String
    var descriptionStr: String
    var meals: [Meal]?
    
    // MARK: - Decodable
    
    init(
        id: String, 
        name: String,
        thumbUrlPath: String,
        categoryDescription: String,
        meals: [Meal]?) {
        self.id = id
        self.name = name
        self.thumbUrlPath = thumbUrlPath
        self.descriptionStr = categoryDescription
        self.meals = meals
    }
    
    // MARK: - IModelStructObject
    
    func getManagedObject(context: NSManagedObjectContext, ignorablePropertiesForOverwrite: [PropertiesRepresantable] = []) throws -> any IModelManagedObject {
        // First trying to fetch the object from the local storage,
        // maybe item with the same id alread exist
        let fetchRequest = MealCategoryMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "customId = %@", self.id)
        let alreadyStoredMealCategoryMO = try? context.fetch(fetchRequest).first
        
        // If object don't exist in local storgae,
        // we will create a new one
        let mealCategoryMO = alreadyStoredMealCategoryMO ?? MealCategoryMO(entity: MealCategoryMO.entity(), insertInto: context)
        let isNewMO = alreadyStoredMealCategoryMO == nil
        
        // Checking if the "meals" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.meals)) {
            // Checking which properties of "meal" need to be ignroed from overwritting
            let mealsIgnoredProperties = ignorablePropertiesForOverwrite.compactMap({ switch $0 {
                    case .mealsProperties(let properties):
                        return properties
                default:
                    return nil
                }
            })
            
            if let meals = meals {
                let mealManageObjects: [MealMO] = meals.compactMap({
                    let objectIter = try? $0.getManagedObject(context: context, ignorablePropertiesForOverwrite: mealsIgnoredProperties) as? MealMO
                    objectIter?.category = mealCategoryMO
                    return objectIter
                })
                (mealCategoryMO.meals as? NSMutableSet)?.addObjects(from: mealManageObjects)
            }
            else {
                (mealCategoryMO.meals as? NSMutableSet)?.removeAllObjects()
            }
        }
        
        // Checking if the "name" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.name)) {
            mealCategoryMO.name = self.name
        }
        
        // Checking if the "id" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.id)) {
            mealCategoryMO.customId = self.id
        }
        
        // Checking if the "thumbUrlPath" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.thumbUrlPath)) {
            mealCategoryMO.thumbUrlPath = self.thumbUrlPath
        }
        
        // Checking if the "descriptionStr" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.descriptionStr)) {
            mealCategoryMO.descriptionStr = self.descriptionStr
        }
        
        return mealCategoryMO
    }
    
    static func convertRemoteStorageRequestToHttpRequest(_ remoteStorageRequest: BaseRemoteStorageRequest<Self>) throws -> HTTPRequest {
        switch remoteStorageRequest.requestType {
            case .fetch(let queryItems, _, _):
                return try getHTTPRequest(for: queryItems)
            
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
    
    static func expectToBeDecodedWithWrapperObject(
        for baseRemoteStorageRequestType: BaseRemoteStorageRequest<ItemType>.RequestType
    ) -> Bool {
        var retVal: Bool
        
        // Just for showing
        switch baseRemoteStorageRequestType {
            case .fetch(let queryItems, _, _):
                retVal = expectToBeDecodedWithWrapperObject(for: queryItems)
            case .add:
                retVal = false
            case .delete:
                retVal = false
        }
        
        return retVal
    }
    
    // MARK: - Private API

    static private func getHTTPRequest(for queryItems: [URLQueryItem]?) throws -> HTTPRequest {
        var retVal: HTTPRequest?
        
        // Indicating the base url from the past queryItems
        if (queryItems == nil || (queryItems?.isEmpty == true)) {
            let httpRequest = HTTPRequest(url: Constants.MealCategory.Endpoints.getAllBaseUrlPath.rawValue, method: .get, headers: nil, params: nil, body: nil)
            retVal = httpRequest
        }
        
        if let retVal = retVal {
            return retVal
        }
        else {
            throw BaseRemoteStorageRequestExecutorError.noProvidedApiForCurrentAction
        }
    }
    
    static private func expectToBeDecodedWithWrapperObject(for queryItems: [URLQueryItem]?) -> Bool {
        var retVal: Bool
        
        // Indicating if we need to expect json data in wrapped object from passed query items
        if (queryItems == nil || (queryItems?.isEmpty == true)) {
            retVal = true
        }
        else {
            retVal = false
        }
        
        return retVal
    }
}

// MARK: - MealCategory + Constants

fileprivate extension Constants {
    struct MealCategory {
        enum Endpoints: String {
            case getAllBaseUrlPath = "https://themealdb.com/api/json/v1/1/lookup.php"
        }
    }
}
