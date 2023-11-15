//
//  BaseStorageManager.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation
import Combine

/// Base class for the storage manager type
final class BaseStorageManager<L: ILocalStorage, R: IRemoteStorage>: ObservableObject, IStorageManager where L.RemoteType == R.ItemType, L.RemoteType.PredicateKeys == L.ItemType.PredicateKeys {
    // MARK: - Typealias
    
    typealias LocalType = L.ItemType
    typealias RemoteType = L.RemoteType
    typealias PredicateKeys = L.RemoteType.PredicateKeys
    typealias PropertiesRepresantable = L.RemoteType.PropertiesRepresantable
    
    // MARK: - Public Properties
    
    @Published private(set) var isFetchingData: Bool = false
    @Published private(set) var firstDataWasFetched: Bool = false
    @Published private(set) var lastSuccessfulFetchResult: RemoteType? = nil
    @Published private(set) var lastError: Error? = nil
    
    // MARK: Private Properties
    
    private let localStorage: L
    private let remoteStorage: R
    private var localStorageBackgroundUpdatingTasks = [Task<Any, Never>?]()
    private var tasksInProgress: [Task<Any, Never>?] {
        return localStorageBackgroundUpdatingTasks
    }
    
    // MARK: - Initializers
    
    required init(
        localStorage: some ILocalStorage,
        remoteStorage: some IRemoteStorage
    ) {
        self.localStorage = localStorage as! L
        self.remoteStorage = remoteStorage as! R
    }
    
    // MARK: - DeInitializer
    
    deinit {
        tasksInProgress.forEach({ $0?.cancel() })
    }
    
    // MARK: - IStorageManager
    
    func remove(
        _ items: [RemoteType],
        ignorablePropertiesForOverwrite: [PropertiesRepresantable] = []
    ) async -> Result<(Void), Error> {
        do {
            // First must remove from local storage
            try await localStorage.removeFromRemote(items, ignorablePropertiesForOverwrite: ignorablePropertiesForOverwrite).get()
            // Now removing from remote storage
            try await remoteStorage.remove(items).get()
        }
        catch {
            lastError = error
            return .failure(error)
        }
        
        return .success(Void())
    }
    
    func add(
        _ items: [RemoteType],
        ignorablePropertiesForOverwrite: [PropertiesRepresantable] = []
    ) async -> Result<(Void), Error> {
        do {
            // First must add to local storage
            try await localStorage.addFromRemote(items, ignorablePropertiesForOverwrite: ignorablePropertiesForOverwrite).get()
            // Now adding to remote storage
            try await remoteStorage.add(items).get()
        }
        catch {
            lastError = error
            return .failure(error)
        }
        
        return .success(Void())
    }
    
    func getItems(
        predicateDict: Dictionary<PredicateKeys, String>?,
        sortDescriptor: SortDescriptor<RemoteType>?,
        limit: Int?,
        ignorablePropertiesForOverwrite: [PropertiesRepresantable] = [],
        saveFetchedItems: Bool = true,
        fetchFromLocalOnlyInCaseOfConnectionError: Bool = true
    ) async -> Result<[RemoteType], Error> {
        defer {
            isFetchingData = false
        }
        
        isFetchingData = true
        var itemsToReturn: [RemoteType]!
        
        do {
            // Fetching items from remote
            let remoteItems = try await remoteStorage.getItems(queryItems: RemoteType.getQueryItems(from: predicateDict), sortDescriptor: sortDescriptor, limit: limit).get()
            
            // Checking wether must save fetched items into local storage
            if saveFetchedItems {
                // Saving fetched items in background in another thread
                let task: Task<Any, Never> = Task.detached { [weak self] in
                    (try? await self?.localStorage.addFromRemote(remoteItems, ignorablePropertiesForOverwrite: ignorablePropertiesForOverwrite).get()) ?? Void()
                }
                // Saving reference to have opportunity to work with it in the future
                self.localStorageBackgroundUpdatingTasks.append(task)
            }
            
            // Returning items
            itemsToReturn = remoteItems
        }
        catch {
            lastError = error
            // If the "fetchFromLocalOnlyInCaseOfConnectionError" is false,
            // It already indicates that we need to fecth from the local storage
            var needToFecthFromLocal = !fetchFromLocalOnlyInCaseOfConnectionError
            // If the "needToFecthFromLocal" is still false, we need to check,
            // if the error type is connection error
            if !needToFecthFromLocal {
                // Handling no internet case,
                // To get from local
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet,
                            .networkConnectionLost,
                            .cannotConnectToHost:
                        needToFecthFromLocal = true
                        
                    default:
                        break
                    }
                }
            }
                 
            if needToFecthFromLocal {
                // First need to wait for local storage updating tasks,
                // To return synced, correct data
                for localStorageTaskIter in localStorageBackgroundUpdatingTasks {
                    let _ = await localStorageTaskIter?.value
                }

                // After that,
                // Trying to get appropriate items from the local storage
                itemsToReturn = try? await getRemoteConvertedItemsFromLocalStorage(
                    predicateDict: predicateDict,
                    sortDescriptor: sortDescriptor,
                    limit: limit
                )
            }
            
            // Returning if even coudn't fetch from local db in case of connection error
            if itemsToReturn == nil {
                return .failure(error)
            }
        }
        
        firstDataWasFetched = true
        lastSuccessfulFetchResult = itemsToReturn as? L.RemoteType
        return .success(itemsToReturn)
    }
    
    // MARK: - Private API
    
    /// Fetchs local items filtering with passed argumetns, and converts them into remote items, and returs.
    /// - Parameters:
    ///   - predicateDict: Predicate dictionary to filter local items.
    ///   - sortDescriptor: Sort descriptor to sort the remote items.
    ///   - limit: The limit of the local items to be fetched.
    /// - Returns: Converted remote items.
    private func getRemoteConvertedItemsFromLocalStorage(
        predicateDict: Dictionary<PredicateKeys, String>?,
        sortDescriptor: SortDescriptor<RemoteType>?,
        limit: Int?
    ) async throws -> [RemoteType] {
        let storedObjects = try await getItemsFromLocalStorage(predicateDict: predicateDict, limit: limit)
        var remoteObjectsFromStored = storedObjects
            .compactMap({
                try? $0.getStructObject() as? RemoteType
            })
        
        if let sortDescriptor = sortDescriptor {
            remoteObjectsFromStored.sort(using: sortDescriptor)
        }
        
        return remoteObjectsFromStored
    }
    
    /// Fetchs local items filtering with passed argumetns.
    /// - Parameters:
    ///   - predicateDict: Predicate dictionary to filter local items.
    ///   - limit: The limit of the local items to be fetched.
    /// - Returns: Local items.
    private func getItemsFromLocalStorage(
        predicateDict: Dictionary<PredicateKeys, String>?,
        limit: Int?
    ) async throws -> [LocalType] {
        let storedObjects = try await localStorage
            .getItems(
                predicate: LocalType.getNsPredicate(from: predicateDict),
                sortDescriptor: nil,
                limit: limit
            )
            .get()
        
        return storedObjects
    }
}
