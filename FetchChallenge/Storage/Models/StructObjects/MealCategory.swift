//
//  MealCategory.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation
import CoreData



struct MealCategory: IModelStructObject {
    // MARK: - Private Static Properties
    
    private static let extraCodingKeyName = CodingUserInfoKey(rawValue: Constants.MealCategory.RequestQueryKeys.name.rawValue)!
    
    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case meals = "meals"
    }
    
    // MARK: - Nested Types
    
    enum PredicateKeys: String, IPredicateKeys {
        case id = "id"
        case name = "name"
    }

    enum PropertiesRepresantable: IPropertiesRepresantable  {
        case id
        case name
        case meals
        case mealsProperties(keys: Meal.PropertiesRepresantable)
    }
    
    // MARK: - Public Properties
    
    var id: String
    var name: String
    var meals: [Meal]
    
    // MARK: - Decodable
    
    init(id: String, name: String, meals: [Meal]) {
        self.id = id
        self.name = name
        self.meals = meals
    }
    
    init(from decoder: Decoder) throws {
        guard   let name = decoder.userInfo[CodingUserInfoKey(rawValue: Constants.MealCategory.RequestQueryKeys.name.rawValue)!] as? String else {
            throw MealCategoryError.parseErrorNameAndIdRequired
        }
        
        self.name = name
        self.id = self.name
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.meals = try container.decode([Meal].self, forKey: .meals)
    }
    
    // MARK: - IModelStructObject
    
    func getManagedObject(context: NSManagedObjectContext, ignorablePropertiesForOverwrite: [PropertiesRepresantable] = []) -> any IModelManagedObject {
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
            
            let mealManageObjects: [MealMO] = meals.compactMap({
                let objectIter = try? $0.getManagedObject(context: context, ignorablePropertiesForOverwrite: mealsIgnoredProperties) as? MealMO
                objectIter?.category = mealCategoryMO
                return objectIter
            })
            (mealCategoryMO.meals as? NSMutableSet)?.addObjects(from: mealManageObjects)
        }
        
        // Checking if the "name" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.name)) {
            mealCategoryMO.name = self.name
        }
        
        // Checking if the "id" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.id)) {
            mealCategoryMO.customId = self.id
        }

        return mealCategoryMO
    }
    
    static func convertRemoteStorageRequestToHttpRequest(_ remoteStorageRequest: BaseRemoteStorageRequest<Self>) throws -> HTTPRequest {
        switch remoteStorageRequest.requestType {
            case .fetch(let queryItems, _, _):
                let httpRequest = HTTPRequest(url: Constants.MealCategory.Endpoints.getApiBaseUrlPath.rawValue, method: .get, headers: nil, params: queryItems, body: nil)
                return httpRequest
            
            case .add(_):
                throw BaseRemoteStorageRequestExecutorError.noProvidedApiForCurrentAction
            
            case .delete(_):
                throw BaseRemoteStorageRequestExecutorError.noProvidedApiForCurrentAction
        }
    }
    
    static func getDecoder(for remoteStorageRequest: BaseRemoteStorageRequest<Self>) -> JSONDecoder {
        let jsonDecoder = JSONDecoder()
        var name: String?
        
        switch remoteStorageRequest.requestType {
            case .fetch(let queryItems, _, _):
                name = queryItems?.filter({ $0.name ==              Constants.MealCategory.RequestQueryKeys.name.rawValue }).compactMap({ $0.value }).first
            default:
                break
        }
        
        if let name = name {
            jsonDecoder.userInfo = [extraCodingKeyName : name]
        }
        
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
        guard let predicateDict = predicateDict else {
            return nil
        }
        
        var queryItems = [URLQueryItem]()
            
        for (key, val) in predicateDict {
            switch key {
               case .name:
                    // Will present the name of category
                    let queryItemToAppend = URLQueryItem(name: "c", value: val)
                    queryItems.append(queryItemToAppend)
                default:
                    break
            }
        }
                
        return queryItems
    }
}

// MARK: - MealCategoryError

enum MealCategoryError: Swift.Error {
    case parseErrorNameAndIdRequired
}

extension MealCategoryError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .parseErrorNameAndIdRequired:
                return "\"MealCategoryError\": parsing failed. Set name and id first."
        }
    }
}

// MARK: - MealCategory + Constants

fileprivate extension Constants {
    struct MealCategory {
        enum RequestQueryKeys: String {
            case name = "c"
        }
    }
}

fileprivate extension Constants.MealCategory {
    enum Endpoints: String {
        case getApiBaseUrlPath = "https://themealdb.com/api/json/v1/1/filter.php"
    }
}
