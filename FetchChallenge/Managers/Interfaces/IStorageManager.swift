//
//  IStorageManager.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/10/23.
//

import Foundation
import Combine

/// This is an abstract interface representing a generic storage manager type.
protocol IStorageManager where PredicateKeys: IPredicateKeys {
    associatedtype LocalType
    associatedtype RemoteType
    associatedtype PredicateKeys
    associatedtype PropertiesRepresantable
    
    // MARK: - Properties
    
    /// Indicates wether is fetching a data at current time
    var isFetchingData: Bool { get }
    
    /// Indicates wether the first data was fetched
    var firstDataWasFetched: Bool { get }
    
    /// The result of the last successful fetch process
    var lastSuccessfulFetchResult: RemoteType? { get }
    
    /// The error of the last failed process
    var lastError: Error? { get }
    
    // MARK: - Initializers

    /// Initializes with passed local and remote storages.
    /// - Parameters:
    ///   - localStorage: The local storage to be stored and used in the future.
    ///   - remoteStorage: The remote storage to be stored and used in the future.
    init(
        localStorage: some ILocalStorage,
        remoteStorage: some IRemoteStorage
    )
    
    // MARK: - Methods

    /// Manages removing the passed items from both remote and local storages.
    /// - Parameters:
    ///   - items: Items to be removed.
    ///   - ignorablePropertiesForOverwrite: Properties to be ignored during a overwritting when covnerting remote items into local.
    /// - Returns: The result of the finished process.
    @discardableResult
    func remove(
        _ items: [RemoteType],
        ignorablePropertiesForOverwrite: [PropertiesRepresantable]
    ) async -> Result<Void, Error>
    
    /// Manages adding the passed items to both remote and local storages.
    /// - Parameters:
    ///   - items: Items to be added.
    ///   - ignorablePropertiesForOverwrite: Properties to be ignored during a overwritting when covnerting remote items into local.
    /// - Returns: The result of the finished process.
    @discardableResult
    func add(
        _ items: [RemoteType],
        ignorablePropertiesForOverwrite: [PropertiesRepresantable]
    ) async -> Result<Void, Error>
    
    /// Manages getting items from the remote or the local storage, depending of the current situation, and manages also saving the fetched remote items into the local storage.
    /// - Parameters:
    ///   - predicateDict: The predicate dictionary to filter items.
    ///   - sortDescriptor: The sort descriptor to sort items.
    ///   - limit: The limit of items to be fecthed.
    ///   - ignorablePropertiesForOverwrite: Properties to be ignored during a overwritting when covnerting remote items into local.
    ///   - saveFetchedItems: Indicate wether to save fetched items into the local storage.
    ///   - fetchFromLocalOnlyInCaseOfConnectionError: Indicate wether to try fetch from local storage only in case of connection error, or anytime when getting error when fetching from the remote storage
    /// - Returns: The result of the finished process.
    @discardableResult
    func getItems(
        predicateDict: Dictionary<PredicateKeys, String>?,
        sortDescriptor: SortDescriptor<RemoteType>?,
        limit: Int?,
        ignorablePropertiesForOverwrite: [PropertiesRepresantable],
        saveFetchedItems: Bool,
        fetchFromLocalOnlyInCaseOfConnectionError: Bool
    ) async -> Result<[RemoteType], Error>
}
