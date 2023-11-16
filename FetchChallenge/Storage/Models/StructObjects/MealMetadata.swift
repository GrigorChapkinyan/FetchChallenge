//
//  MealMetadata.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation
import CoreData

struct MealMetadata: IModelStructObject {
    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case alternateDrinkName = "strDrinkAlternate"
        case area = "strArea"
        case instruction = "strInstructions"
        case tag = "strTags"
        case youtubeVideoUrlPath = "strYoutube"
        case sourceUrlPath = "strSource"
        case imageSourceUrlPath = "strImageSource"
        case creativeCommonsConfirmed = "strCreativeCommonsConfirmed"
        case dateModified = "dateModified"
        case ingredients = "ingredients"
        case categoryId = "strCategory"
        case mealId = "mealId"
    }
    
    // MARK: - Nested Types
    
    enum PredicateKeys: String, IPredicateKeys {
        case mealId
        case area
        case instruction
        case youtubeVideoUrlPath
        case sourceUrlPath
        case categoryId
        case tag
        case alternateDrinkName
        case imageSourceUrlPath
        case creativeCommonsConfirmed
        case dateModified
    }
    
    enum PropertiesRepresantable: IPropertiesRepresantable  {
        case mealId
        case area
        case instruction
        case youtubeVideoUrlPath
        case sourceUrlPath
        case categoryId
        case tag
        case alternateDrinkName
        case imageSourceUrlPath
        case creativeCommonsConfirmed
        case dateModified
        case ingredients
        case ingredientsProperties(keys: MealIngredient.PropertiesRepresantable)
    }
    
    struct WrapperObject: IWrapperObject {
        var items: [MealMetadata]
        
        enum CodingKeys: String, CodingKey, CaseIterable {
            case items
        }
    }
    
    // MARK: - Public Properties
    
    var ingredients = [MealIngredient]()
    var mealId: String
    let area: String
    let instruction: String
    let youtubeVideoUrlPath: String
    let sourceUrlPath: String
    let categoryId: String
    let tag: String?
    let alternateDrinkName: String?
    let imageSourceUrlPath: String?
    let creativeCommonsConfirmed: Bool?
    let dateModified: Date?

    // MARK: - Decodable
    
    init(mealId: String, alternateDrinkName: String?, area: String, instruction: String, tag: String?, youtubeVideoUrlPath: String, sourceUrlPath: String, categoryId: String, imageSourceUrlPath: String?, creativeCommonsConfirmed: Bool?, dateModified: Date?, ingredients: [MealIngredient]) {
        self.mealId = mealId
        self.alternateDrinkName = alternateDrinkName
        self.area = area
        self.instruction = instruction
        self.tag = tag
        self.youtubeVideoUrlPath = youtubeVideoUrlPath
        self.sourceUrlPath = sourceUrlPath
        self.categoryId = categoryId
        self.imageSourceUrlPath = imageSourceUrlPath
        self.creativeCommonsConfirmed = creativeCommonsConfirmed
        self.dateModified = dateModified
        self.ingredients = ingredients
    }
    
    init(mealId: String, container: KeyedDecodingContainer<MealMetadata.CodingKeys>, decoder: Decoder) throws {
        self.mealId = mealId
        self.alternateDrinkName = try container.decodeIfPresent(String.self, forKey: .alternateDrinkName)
        self.area = try container.decode(String.self, forKey: .area)
        self.instruction = try container.decode(String.self, forKey: .instruction)
        self.tag = try container.decodeIfPresent(String.self, forKey: .tag)
        self.youtubeVideoUrlPath = try container.decode(String.self, forKey: .youtubeVideoUrlPath)
        self.sourceUrlPath = try container.decode(String.self, forKey: .sourceUrlPath)
        self.categoryId = try container.decode(String.self, forKey: .categoryId)
        self.imageSourceUrlPath = try container.decodeIfPresent(String.self, forKey: .imageSourceUrlPath)
        self.creativeCommonsConfirmed = try container.decodeIfPresent(Bool.self, forKey: .creativeCommonsConfirmed)
        self.dateModified = try container.decodeIfPresent(Date.self, forKey: .dateModified)
        
        let ingridients = try self.lookForIngredients(in: decoder)
        self.ingredients = ingridients
    }
    
    // MARK: - IModelStructObject
    
    func getManagedObject(context: NSManagedObjectContext, ignorablePropertiesForOverwrite: [PropertiesRepresantable] = []) throws -> any IModelManagedObject {
        // First trying to fetch the object from the local storage,
        // maybe item with the same id alread exist
        let fetchRequest = MealMetadataMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "mealId = %@", self.mealId)
        let alreadyStoredMealMetadataMO = try? context.fetch(fetchRequest).first
        
        // If object don't exist in local storgae,
        // we will create a new one
        let mealMetadataMO = alreadyStoredMealMetadataMO ?? MealMetadataMO(entity: MealMetadataMO.entity(), insertInto: context)
        let isNewMO = alreadyStoredMealMetadataMO == nil
        
        // Checking if the "ingredients" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.ingredients)) {
            // Checking which properties of "ingridents" need to be ignroed from overwritting
            let ingredientsIgnoredProperties = ignorablePropertiesForOverwrite.compactMap({ switch $0 {
                    case .ingredientsProperties(let properties):
                        return properties
                default:
                    return nil
                }
            })
            
            let mealIngredientObjects: [MealIngredientMO] = ingredients.compactMap({
                let objectIter = try? $0.getManagedObject(context: context, ignorablePropertiesForOverwrite: ingredientsIgnoredProperties) as? MealIngredientMO
                objectIter?.metadata = mealMetadataMO
                return objectIter
            })
            
            (mealMetadataMO.ingredients as? NSMutableSet)?.addObjects(from: mealIngredientObjects)
        }
        
        // Checking if the "area" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.area)) {
            mealMetadataMO.area = self.area
        }
        
        // Checking if the "instruction" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.instruction)) {
            mealMetadataMO.instruction = self.instruction
        }
        
        // Checking if the "instruction" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.instruction)) {
            mealMetadataMO.instruction = self.instruction
        }
        
        // Checking if the "tag" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.tag)) {
            mealMetadataMO.tag = self.tag
        }
        
        // Checking if the "youtubeVideoUrlPath" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.youtubeVideoUrlPath)) {
            mealMetadataMO.youtubeVideoUrlPath = self.youtubeVideoUrlPath
        }
        
        // Checking if the "sourceUrlPath" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.sourceUrlPath)) {
            mealMetadataMO.sourceUrlPath = self.sourceUrlPath
        }
        
        // Checking if the "alternateDrinkName" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.alternateDrinkName)) {
            mealMetadataMO.alternateDrinkName = self.alternateDrinkName
        }
        
        // Checking if the "imageSourceUrlPath" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.imageSourceUrlPath)) {
            mealMetadataMO.imageSourceUrlPath = self.imageSourceUrlPath
        }
        
        // Checking if the "creativeCommonsConfirmed" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.creativeCommonsConfirmed)) {
            mealMetadataMO.creativeCommonsConfirmed = self.creativeCommonsConfirmed ?? false
        }
        
        // Checking if the "dateModified" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.dateModified)) {
            mealMetadataMO.dateModified = self.dateModified
        }
        
        // Checking if the "mealId" property needs to be overwritten
        if (isNewMO || !ignorablePropertiesForOverwrite.contains(.mealId)) {
            mealMetadataMO.mealId = self.mealId
        }

        return mealMetadataMO
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
    
    static func expectToBeDecodedWithWrapperObject(for baseRemoteStorageRequestType: BaseRemoteStorageRequest<ItemType>.RequestType) -> Bool {
        return false
    }
}

// MARK: - MealMetadata + MealIngredient

fileprivate extension MealMetadata {
    // MARK: - CodingKeys

    enum MealIngridientMixedCodingKeys: String, CodingKey {
        case strIngredient1
        case strIngredient2
        case strIngredient3
        case strIngredient4
        case strIngredient5
        case strIngredient6
        case strIngredient7
        case strIngredient8
        case strIngredient9
        case strIngredient10
        case strIngredient11
        case strIngredient12
        case strIngredient13
        case strIngredient14
        case strIngredient15
        case strIngredient16
        case strIngredient17
        case strIngredient18
        case strIngredient19
        case strIngredient20
        case strMeasure1
        case strMeasure2
        case strMeasure3
        case strMeasure4
        case strMeasure5
        case strMeasure6
        case strMeasure7
        case strMeasure8
        case strMeasure9
        case strMeasure10
        case strMeasure11
        case strMeasure12
        case strMeasure13
        case strMeasure14
        case strMeasure15
        case strMeasure16
        case strMeasure17
        case strMeasure18
        case strMeasure19
        case strMeasure20
    }
    
    // MARK: - Private API
    
    private func lookForIngredients(in decoder: Decoder) throws -> [MealIngredient] {
        // Creating iterator to iterate trough MixedKeysPairs(it was the best solution)
        var iterator = MealIngridientMixedCodingKeysIterator()
        let container = try decoder.container(keyedBy: MealIngridientMixedCodingKeys.self)
        var retVal = [MealIngredient]()
        
        // Iterating till the end
        var mealIngridientKeysTupleIterOptional = iterator.next()
        while let mealIngridientKeysTupleIter = mealIngridientKeysTupleIterOptional {
            defer {
                mealIngridientKeysTupleIterOptional = iterator.next()
            }
            
            // Trying to parse ingredient's name and measure from the container
            let ingredientName = try container.decodeIfPresent(String.self, forKey: mealIngridientKeysTupleIter.key)
            let ingrdientMeasure = try container.decodeIfPresent(String.self, forKey: mealIngridientKeysTupleIter.value)
            
            // Making sure that theye aren't nil, and aren't empty,
            if let ingredientName = ingredientName,
               let ingrdientMeasure = ingrdientMeasure,
               ingredientName.isEmpty == false,
               ingrdientMeasure.isEmpty == false     {
                // Unique ID we can crate with "MealID" + "Ingridient Number"(which is equal iterator index + 1)
                let ingridentUniqueId = self.mealId + String(iterator.currentIndex + 1)
                let valToAppend = MealIngredient(id: ingridentUniqueId, name: ingredientName, measure: ingrdientMeasure, mealMetadataId: mealId)
                retVal.append(valToAppend)
            }
        }
        
        return retVal
    }
    
    struct MealIngridientMixedCodingKeysIterator: IteratorProtocol {
        typealias Element = (key: MealIngridientMixedCodingKeys, value: MealIngridientMixedCodingKeys)
        
        // MARK: - Private Static Properties
        
        private static var allvalues: [Element] = [
            (.strIngredient1, .strMeasure1),
            (.strIngredient2, .strMeasure2),
            (.strIngredient3, .strMeasure3),
            (.strIngredient4, .strMeasure4),
            (.strIngredient5, .strMeasure5),
            (.strIngredient6, .strMeasure6),
            (.strIngredient7, .strMeasure7),
            (.strIngredient8, .strMeasure8),
            (.strIngredient9, .strMeasure9),
            (.strIngredient10, .strMeasure10),
            (.strIngredient11, .strMeasure11),
            (.strIngredient12, .strMeasure12),
            (.strIngredient13, .strMeasure13),
            (.strIngredient14, .strMeasure14),
            (.strIngredient15, .strMeasure15),
            (.strIngredient16, .strMeasure16),
            (.strIngredient17, .strMeasure17),
            (.strIngredient18, .strMeasure18),
            (.strIngredient19, .strMeasure19),
            (.strIngredient20, .strMeasure20)
        ]
        
        // MARK: - Public Properties
        
        private(set) var currentIndex: Int = 0
        
        // MARK: - IteratorProtocol
        
        mutating func next() -> (key: MealMetadata.MealIngridientMixedCodingKeys, value: MealMetadata.MealIngridientMixedCodingKeys)? {
            guard currentIndex < (Self.allvalues.count - 1) else {
                return nil
            }
            
            let retVal = Self.allvalues[currentIndex]
            currentIndex += 1
            
            return retVal
        }
    }
}

