//
//  IRemoteStorage.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation

/// This is an abstract interface representing a remote storage type
protocol IRemoteStorage: IStorage where ItemType: IModelStructObject {
    /// Returns items from the storage filtered with the passed argumetns.
    /// - Parameters:
    ///   - queryItems: The query items array to be send to remote storage.
    ///   - sortDescriptor: The sort descriptor to sort the items.
    ///   - limit: The limit of items to be fecthed.
    /// - Returns: The result of the finished process.
    func getItems(
        queryItems: [URLQueryItem]?,
        sortDescriptor: SortDescriptor<ItemType>?,
        limit: Int?
    ) async -> Result<[ItemType], Error>
}
