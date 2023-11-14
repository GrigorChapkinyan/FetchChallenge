//
//  IStorage.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation

/// This is an abstract interface representing a storage type
protocol IStorage {
    associatedtype ItemType
    
    /// Initializes with passed "requestExecutor".
    /// - Parameter requestExecutor: The request executor which will be is used for future calls.
    init(with requestExecutor: IRequestExecutor)
    
    /// Removes passed items from the storage.
    /// - Parameter items: Items to be removed.
    /// - Returns: The result of the finished process.
    @discardableResult
    func remove(_ items: [ItemType]) async -> Result<Void, Error>

    /// Adds passed items into the storage.
    /// - Parameter items: Items to be added.
    /// - Returns: The result of the finished process.
    @discardableResult
    func add(_ items: [ItemType]) async -> Result<Void, Error>
}
