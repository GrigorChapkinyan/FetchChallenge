//
//  IModelStructObject.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation
import CoreData

/// This is an abstract interface representing a type which is representation of managed objects with struct data type.
protocol IModelStructObject: Codable where PredicateKeys: IPredicateKeys, PropertiesRepresantable: IPropertiesRepresantable, WrapperObject: IWrapperObject, WrapperObject.WrappedObject == ItemType  {
    typealias ItemType = Self
    associatedtype PredicateKeys
    associatedtype PropertiesRepresantable
    associatedtype WrapperObject

    /// Returns appropriate managed object.
    /// - Parameters:
    ///   - context: The view context of the persistent store.
    ///   - ignorablePropertiesForOverwrite: The properties which overwritting must be ignored.
    /// - Returns: Appropriate managed object.
    func getManagedObject(
        context: NSManagedObjectContext,
        ignorablePropertiesForOverwrite: [PropertiesRepresantable]
    ) throws -> any IModelManagedObject
    
    /// Converts remote storage request into HTTP request
    /// - Parameter remoteStorageRequest: Remote storage request to be converted.
    /// - Returns: Converted HTTP request.
    static func convertRemoteStorageRequestToHttpRequest(
        _ remoteStorageRequest: BaseRemoteStorageRequest<ItemType>
    ) throws -> HTTPRequest
    
    /// Creates and returns appropriate jsonDecoder for passed remote storage request.
    /// - Parameter remoteStorageRequest: Remote storage request for which processing the decoder will be created.
    /// - Returns: Configured json decoder.
    static func getDecoder(
        for remoteStorageRequest: BaseRemoteStorageRequest<ItemType>
    ) -> JSONDecoder
    
    /// Indicates whether must expect an array type or single object based on passed "baseRemoteStorageRequestType".
    /// - Parameter baseRemoteStorageRequestType: The remote storage request type which will indicate the expected data type.
    /// - Returns: True if must expect an array, false if must expect a single object
    static func expectArray(
        for baseRemoteStorageRequestType: BaseRemoteStorageRequest<ItemType>.RequestType
    ) -> Bool
    
    /// Indicates whether must expect an wrapper type or not based on passed "baseRemoteStorageRequestType".
    /// - Parameter baseRemoteStorageRequestType: The remote storage request type which will indicate the expected data type.
    /// - Returns: True if must expect a wrapper object, false otherwise
    static func expectToBeDecodedWithWrapperObject(
        for baseRemoteStorageRequestType: BaseRemoteStorageRequest<ItemType>.RequestType
    ) -> Bool
        
    /// Converts and returns appropriate "URLQueryItem"s array from the passed "predicateDict"
    /// - Parameter predicateDict: The predicates dictionary to be converted
    /// - Returns: Converted "URLQueryItem"s array
    static func getQueryItems(
        from predicateDict: [PredicateKeys : String]?
    ) -> [URLQueryItem]?
}
