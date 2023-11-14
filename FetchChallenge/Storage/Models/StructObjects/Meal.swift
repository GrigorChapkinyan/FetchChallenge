//
//  Meal.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation
import CoreData

struct Meal: IModelStructObject {
    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey, CaseIterable {
        case name = "strMeal"
        case id = "idMeal"
        case thumUrlPath = "strMealThumb"
    }
    
    // MARK: - Nested Types
    
    enum PredicateKeys: String, IPredicateKeys {
        case id = "id"
        case name = "name"
        case thumUrlPath = "meals"
    }
    
    enum PropertiesRepresantable: IPropertiesRepresantable  {
        case id
        case name
        case thumUrlPath
        case metadata
        case metadataProperties(keys: MealMetadata.PropertiesRepresantable)
    }
    
    // MARK: - Public Properties
    
    let metadata: MealMetadata?
    let id: String
    let name: String
    let thumUrlPath: String?
    
    // MARK: - Decodable
    
    init(id: String, metadata: MealMetadata?, name: String, thumUrlPath: String?) {
        self.id = id
        self.metadata = metadata
        self.name = name
        self.thumUrlPath = thumUrlPath
    }
    
    init(from decoder: Decoder) throws {
        // Fixing backend wrong structure
        // Checking if the data is wrapped inside "meals" key as Array
        let mealCategoryContainer = try? decoder.container(keyedBy: MealCategory.CodingKeys.self)
        // Trying to get data using parent entity CodingKeys
        if let mealCategoryContainer = mealCategoryContainer,
           // Recursion point
           let meals = try? mealCategoryContainer.decode([Meal].self, forKey: MealCategory.CodingKeys.meals) {
            // Checking the data to have correct structure
            guard meals.count == 1 else {
                throw MealError.wrongDataStructure
            }
            
            let mealToCopy = meals.first!
            
            // Assinging properties to self
            self.metadata = mealToCopy.metadata
            self.id = mealToCopy.id
            self.name = mealToCopy.name
            self.thumUrlPath = mealToCopy.thumUrlPath
        }
        // Otherwise parsing as a regular, single object
        else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
            self.name = try container.decode(String.self, forKey: .name)
            self.thumUrlPath = try container.decodeIfPresent(String.self, forKey: .thumUrlPath)
            
            // This will indicate that we are parsing current meal with metadata
            let mealMetadataContainer = try? decoder.container(keyedBy: MealMetadata.CodingKeys.self)
            if let mealMetadataContainer = mealMetadataContainer,
               mealMetadataContainer.allKeys.count > 0 {
                self.metadata = try? MealMetadata(mealId: self.id, container: mealMetadataContainer, decoder: decoder)
            }
            else {
                self.metadata = nil
            }
        }
    }
    
    // MARK: - IModelStructObject
    
    func getManagedObject(context: NSManagedObjectContext, ignorablePropertiesForOverwrite: [PropertiesRepresantable] = []) throws -> any IModelManagedObject {
        // First trying to fetch the object from the local storage,
        // maybe item with the same id alread exist
        let fetchRequest = MealMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "customId = %@", self.id)
        let alreadyStoredMealMO = try? context.fetch(fetchRequest).first
        
        // If object don't exist in local storgae,
        // we will create a new one
        let mealMO = alreadyStoredMealMO ?? MealMO(entity: MealMO.entity(), insertInto: context)
        let isNewMO = alreadyStoredMealMO == nil
        
        // Checking if the "metadata" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.metadata)) {
            // Checking which properties of "mealmetadata" need to be ignroed from overwritting
            let mealsIgnoredProperties = ignorablePropertiesForOverwrite.compactMap({ switch $0 {
                    case .metadataProperties(let properties):
                        return properties
                default:
                    return nil
                }
            })
            
            let mealMetadataManagedObject: MealMetadataMO? = try self.metadata?.getManagedObject(context: context, ignorablePropertiesForOverwrite: mealsIgnoredProperties) as? MealMetadataMO
            mealMO.metadata = mealMetadataManagedObject
        }
        
        // Checking if the "name" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.name)) {
            mealMO.name = self.name
        }
        
        // Checking if the "thumUrlPath" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.thumUrlPath)) {
            mealMO.thumUrlPath = self.thumUrlPath
        }

        // Checking if the "id" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.id)) {
            mealMO.customId = self.id
        }
        
        return mealMO
    }
    
    static func convertRemoteStorageRequestToHttpRequest(_ remoteStorageRequest: BaseRemoteStorageRequest<Self>) throws -> HTTPRequest {
        switch remoteStorageRequest.requestType {
            case .fetch(let queryItems, _, _):
                let httpRequest = HTTPRequest(url: Constants.Meal.Endpoints.getApiBaseUrlPath.rawValue, method: .get, headers: nil, params: queryItems, body: nil)
                return httpRequest
            
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
        guard let predicateDict = predicateDict else {
            return nil
        }
        
        var queryItems = [URLQueryItem]()
            
        for (key, val) in predicateDict {
            switch key {
               case .id:
                    // Will present the name of category
                    let queryItemToAppend = URLQueryItem(name: "i", value: val)
                    queryItems.append(queryItemToAppend)
                default:
                    break
            }
        }
                
        return queryItems
    }
}

// MARK: - Meal + Constants

fileprivate extension Constants {
    struct Meal {
        enum Endpoints: String {
            case getApiBaseUrlPath = "https://themealdb.com/api/json/v1/1/lookup.php"
        }
    }
}

// MARK: - MealError

enum MealError: Swift.Error {
    case wrongDataStructure
}

extension MealError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .wrongDataStructure:
                return "\"MealError\": parsing failed. Wrong data structure."
        }
    }
}
