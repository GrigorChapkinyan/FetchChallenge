//
//  Meal.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation
import CoreData

struct Meal: IModelStructObject {
    private static let extraCodingKeyCategoryName = CodingUserInfoKey(rawValue: Constants.Meal.RequestQueryKeys.categoryName.rawValue)!
    
    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey, CaseIterable {
        case name = "strMeal"
        case id = "idMeal"
        case thumUrlPath = "strMealThumb"
    }
    
    // MARK: - Nested Types
    
    enum PredicateKeys: String, IPredicateKeys {
        case id
        case name
        case thumUrlPath
        case categoryName
    }
    
    enum PropertiesRepresantable: IPropertiesRepresantable  {
        case id
        case name
        case thumUrlPath
        case metadata
        case metadataProperties(keys: MealMetadata.PropertiesRepresantable)
    }
    
    struct WrapperObject: IWrapperObject {
        var items: [Meal]
        
        enum CodingKeys: String, CodingKey, CaseIterable {
            case items = "meals"
        }
    }
    
    // MARK: - Public Properties
    
    let metadata: MealMetadata?
    let id: String
    let name: String
    let thumUrlPath: String?
    let categoryName: String?
    
    // MARK: - Decodable
    
    init(id: String, metadata: MealMetadata?, name: String, thumUrlPath: String?, categoryName: String?) {
        self.id = id
        self.metadata = metadata
        self.name = name
        self.thumUrlPath = thumUrlPath
        self.categoryName = categoryName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.thumUrlPath = try container.decodeIfPresent(String.self, forKey: .thumUrlPath)
        self.categoryName = decoder.userInfo[Meal.extraCodingKeyCategoryName] as? String
        
        // This will indicate wether we are
        // parsing current meal with metadata or without
        let mealMetadataContainer = try? decoder.container(keyedBy: MealMetadata.CodingKeys.self)
        if let mealMetadataContainer = mealMetadataContainer,
           mealMetadataContainer.allKeys.count > 0 {
            self.metadata = try? MealMetadata(mealId: self.id, container: mealMetadataContainer, decoder: decoder)
        }
        else {
            self.metadata = nil
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
        
        // Trying to set parent "category" entity and this child connection,
        // if it wasn't set yet and if we have the "categoryName"
        if mealMO.category == nil,
            let categoryName = categoryName {
            let fetchRequest = MealCategoryMO.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "\(MealCategoryMO.PredicateKeys.name.rawValue) = %@", categoryName)
            let alreadyStoredMealCategoryMO = try? context.fetch(fetchRequest).first
            // Setting the meal connection
            (alreadyStoredMealCategoryMO?.meals as? NSMutableSet)?.add(mealMO)
            // Setting the category connection
            mealMO.category = alreadyStoredMealCategoryMO
        }
        
        return mealMO
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
        
        // Checking if the request is fetch type and
        // contains the key of the category name,
        // so we can put it inside the decoder's userInfo dict
        // and use it in the future during the decoding process
        switch remoteStorageRequest.requestType {
            case .fetch(let queryItems, _, _):
            let categoryNameOptional = queryItems?.filter({ $0.name == Constants.Meal.RequestQueryKeys.categoryName.rawValue }).first?.value
            
            if let categoryName = categoryNameOptional {
                jsonDecoder.userInfo = [extraCodingKeyCategoryName : categoryName]
            }
            
            default:
                break
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
               case .id:
                    let queryItemToAppend = URLQueryItem(name: Constants.Meal.RequestQueryKeys.id.rawValue, value: val)
                    queryItems.append(queryItemToAppend)
                case .categoryName:
                     let queryItemToAppend = URLQueryItem(name: Constants.Meal.RequestQueryKeys.categoryName.rawValue, value: val)
                     queryItems.append(queryItemToAppend)
                
                default:
                    break
            }
        }
                
        return queryItems
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
        if (queryItems?.contains(where: { $0.name == Constants.Meal.RequestQueryKeys.id.rawValue }) == true) {
            let httpRequest = HTTPRequest(url: Constants.Meal.Endpoints.getByIdBaseUrlPath.rawValue, method: .get, headers: nil, params: queryItems, body: nil)
            retVal = httpRequest
        }
        else if (queryItems?.contains(where: { $0.name == Constants.Meal.RequestQueryKeys.categoryName.rawValue }) == true) {
            let httpRequest = HTTPRequest(url: Constants.Meal.Endpoints.getByIdCategoryNameUrlPath.rawValue, method: .get, headers: nil, params: queryItems, body: nil)
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
        if (queryItems?.contains(where: { $0.name == Constants.Meal.RequestQueryKeys.id.rawValue }) == true) {
            retVal = true
        }
        else if (queryItems?.contains(where: { $0.name == Constants.Meal.RequestQueryKeys.categoryName.rawValue }) == true) {
            retVal = true
        }
        else {
            retVal = false
        }
        
        return retVal
    }
}

// MARK: - Meal + Constants

fileprivate extension Constants {
    struct Meal {
        enum Endpoints: String {
            case getByIdBaseUrlPath = "https://themealdb.com/api/json/v1/1/lookup.php"
            case getByIdCategoryNameUrlPath = "https://themealdb.com/api/json/v1/1/filter.php"
        }
        
        enum RequestQueryKeys: String {
            case id = "i"
            case categoryName = "c"
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
