//
//  BaseLocalStorage.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation

/// Base class for the local storage type.
struct BaseLocalStorage<ItemType: IModelManagedObject, RemoteType: IModelStructObject>: ILocalStorage {
    // MARK: - Private Properties
    
    private let requestExecutor: IRequestExecutor
    
    // MARK: - IRemoteStorage
    
    init(with requestExecutor: IRequestExecutor) {
        self.requestExecutor = requestExecutor
    }
    
    func getItems(predicate: NSPredicate?, sortDescriptor: SortDescriptor<ItemType>?, limit: Int?) async -> Result<[ItemType], Error> {
        let localStorageRequest = BaseLocalStorageRequest<ItemType, RemoteType>(requestType: .fetch(predicate: predicate, sortDescriptor: sortDescriptor, limit: limit))

        return await requestExecutor.execute(localStorageRequest).map({ $0 as! [ItemType] })
    }
    
    func remove(_ items: [ItemType]) async -> Result<Void, Error> {
        let localStorageRequest = BaseLocalStorageRequest<ItemType, RemoteType>(requestType: .delete(items: items))
        
        return await requestExecutor.execute(localStorageRequest).map({ _ in return () })
    }

    func add(_ items: [ItemType]) async -> Result<Void, Error> {
        let localStorageRequest = BaseLocalStorageRequest<ItemType, RemoteType>(requestType: .add(items: items))

        return await requestExecutor.execute(localStorageRequest).map({ _ in return () })
    }
    
    func removeFromRemote(_ items: [RemoteType], ignorablePropertiesForOverwrite: [RemoteType.PropertiesRepresantable] = []) async -> Result<Void, Error> {
        let localStorageRequest = BaseLocalStorageRequest<ItemType, RemoteType>(requestType: .deleteFromRemoteItems(items: items, ignorablePropertiesForOverwrite: ignorablePropertiesForOverwrite))

        return await requestExecutor.execute(localStorageRequest).map({ _ in return () })
    }

    func addFromRemote(_ items: [RemoteType], ignorablePropertiesForOverwrite: [RemoteType.PropertiesRepresantable] = []) async -> Result<Void, Error> {
        let localStorageRequest = BaseLocalStorageRequest<ItemType, RemoteType>(requestType: .addFromRemoteItems(items: items, ignorablePropertiesForOverwrite: ignorablePropertiesForOverwrite))

        return await requestExecutor.execute(localStorageRequest).map({ _ in return () })
    }
}
