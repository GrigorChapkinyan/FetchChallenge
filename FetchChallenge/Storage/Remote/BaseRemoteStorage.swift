//
//  BaseRemoteStorage.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation

/// Base class for the remote storage.
struct BaseRemoteStorage<ItemType: IModelStructObject>: IRemoteStorage {
    // MARK: - Private Properties
    
    private let requestExecutor: IRequestExecutor
    
    // MARK: - IRemoteStorage
    
    init(with requestExecutor: IRequestExecutor) {
        self.requestExecutor = requestExecutor
    }
    
    func getItems(queryItems: [URLQueryItem]?, sortDescriptor: SortDescriptor<ItemType>?, limit: Int?) async -> Result<[ItemType], Error> {
        let localStorageRequest = BaseRemoteStorageRequest<ItemType>(requestType: .fetch(queryItems: queryItems, sortDescriptor: sortDescriptor, limit: limit))

        return await requestExecutor.execute(localStorageRequest).map({ $0 as! [ItemType] })
    }
    
    func remove(_ items: [ItemType]) async -> Result<Void, Error> {
        let localStorageRequest = BaseRemoteStorageRequest<ItemType>(requestType: .delete(items: items))
        
        return await requestExecutor.execute(localStorageRequest).map({ _ in return () })
    }

    func add(_ items: [ItemType]) async -> Result<Void, Error> {
        let localStorageRequest = BaseRemoteStorageRequest<ItemType>(requestType: .add(items: items))

        return await requestExecutor.execute(localStorageRequest).map({ _ in return () })
    }
}
