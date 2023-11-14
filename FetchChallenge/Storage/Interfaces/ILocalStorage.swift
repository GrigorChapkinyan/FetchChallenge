//
//  ILocalStorage.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation

/// This is an abstract interface representing a local storage type
protocol ILocalStorage: IStorage where ItemType: IModelManagedObject, RemoteType: IModelStructObject {
    associatedtype RemoteType
    
    /// Returns items from the storage filtered with the passed argumetns.
    /// - Parameters:
    ///   - predicate: The predicate to use when filtering items.
    ///   - sortDescriptor: The sort descriptor to sort the items.
    ///   - limit: The limit of items to be fecthed.
    /// - Returns: The result of the finished process.
    func getItems(
        predicate: NSPredicate?,
        sortDescriptor: SortDescriptor<ItemType>?,
        limit: Int?
    ) async -> Result<[ItemType], Error>
    
    /// Converts passed remote items into local items, and removes them from the storage.
    /// - Parameters:
    ///   - items: Remote items to be converted into local items, and to be removed.
    ///   - ignorablePropertiesForOverwrite: Properties to be ignored during a overwritting when covnerting remote items into local.
    /// - Returns: The result of the finished process.
    @discardableResult
    func removeFromRemote(
        _ items: [RemoteType],
        ignorablePropertiesForOverwrite: [RemoteType.PropertiesRepresantable]
    ) async -> Result<Void, Error>
    
    /// Converts passed remote items into local items, and adds them from the storage.
    /// - Parameters:
    ///   - items: Remote items to be converted into local items, and to be added.
    ///   - ignorablePropertiesForOverwrite: Properties to be ignored during a overwritting when covnerting remote items into local.
    /// - Returns: The result of the finished process.
    @discardableResult
    func addFromRemote(
        _ items: [RemoteType],
        ignorablePropertiesForOverwrite: [RemoteType.PropertiesRepresantable]
    ) async -> Result<Void, Error>
}
