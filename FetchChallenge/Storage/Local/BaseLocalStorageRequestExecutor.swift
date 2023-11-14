//
//  BaseLocalStorageRequestExecutor.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation
import CoreData

/// Base class for the local storage request executor type.
final class BaseLocalStorageRequestExecutor<ItemType: IModelManagedObject, RemoteType: IModelStructObject>: IRequestExecutor {
    // MARK: - Private Properties
    
    private let inMemory: Bool
    private let persistentContainer: PersistentContainer
    private var moc: NSManagedObjectContext {
        get async {
            await persistentContainer.moc
        }
    }
    
    // MARK: - Initializers
    
    init(inMemory: Bool = false) async {
        persistentContainer = await PersistentContainerProvider.shared.getItem(with: ItemType.getPersistentContainerName(), inMemory: inMemory)
        self.inMemory = inMemory
    }
    
    // MARK: - IRequestExecutor
    
    func execute(_ request: IRequest) async -> Result<Any, Error> {
        do {
            guard let localStorageRequest = request as? BaseLocalStorageRequest<ItemType, RemoteType> else {
                throw IRequestError.invalidRequestPassed
            }
            
            switch localStorageRequest.requestType {
                case .fetch(let predicate, let sortDescriptor, let limit):
                    let result = try await fetch(predicate: predicate, sortDescriptor: sortDescriptor, limit: limit)
                    return .success(result)
                
                case .update:
                    let result: Void = try await update()
                    return .success(result)
                
                case .delete(let items):
                    let result: Void = try await delete(items)
                    return .success(result)
                
                case .deleteFromRemoteItems(let remoteItems, let ignorablePropertiesForOverwrite):
                    let moc = await self.moc
                    let managedObjects = remoteItems.compactMap({ try? $0.getManagedObject(context: moc, ignorablePropertiesForOverwrite: ignorablePropertiesForOverwrite) as? ItemType })
                            let result: Void = try await delete(managedObjects)
                        return .success(result)
                
                case .add(let items):
                    let result: Void = try await add(items)
                    return .success(result)
                
                case .addFromRemoteItems(let remoteItems, let ignorablePropertiesForOverwrite):
                    let moc = await self.moc
                    let managedObjects = remoteItems.compactMap({ try? $0.getManagedObject(context: moc, ignorablePropertiesForOverwrite: ignorablePropertiesForOverwrite) as? ItemType })
                    let result: Void = try await add(managedObjects)
                    return .success(result)
            }
        }
        catch {
            return .failure(error)
        }
    }
    
    // MARK: - Private API

    /// Returns items from the storage filtered with the passed argumetns.
    /// - Parameters:
    ///   - predicate: The predicate to use when filtering items.
    ///   - sortDescriptor: The sort descriptor to sort the items.
    ///   - limit: The limit of items to be fecthed.
    /// - Returns: The result of the finished process.
    private func fetch(
        predicate: NSPredicate?,
        sortDescriptor: SortDescriptor<ItemType>?,
        limit: Int?
    ) async throws -> [ItemType] {
        let moc = await self.moc
        let fetchRequest = NSFetchRequest<ItemType>(entityName: ItemType.getEntityName())
        fetchRequest.predicate = predicate
        
        // Setting sortDescriptor if exist
        if let sortDescriptor = sortDescriptor {
            fetchRequest.sortDescriptors = [NSSortDescriptor(sortDescriptor)]
        }
        
        // Setting the limit of items
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        
        do {
            let fetchRequestResult = try moc.performAndWait {
                try moc.fetch(fetchRequest)
            }
            
            return fetchRequestResult
        }
        catch {
            throw BaseLocalStorageRequestExecutorError.fetchRequestFailed(error: error)
        }
    }
    
    /// Removes passed items from the storage
    /// - Parameter items: Items to be removed
    private func delete(_ items: [ItemType]) async throws {
        let moc = await self.moc
        
        for itemIter in items {
            moc.performAndWait {
                moc.delete(itemIter)
            }
        }
        try await update()
    }
    
    /// Adds passed items into the storage
    /// - Parameter items: Items to be added
    private func add(_ items: [ItemType]) async throws {
        try await update()
    }
    
    /// Updates the storage if its has changes
    private func update() async throws {
        let moc = await self.moc
        
        if moc.hasChanges {
            try moc.performAndWait {
                do {
                    try moc.save()
                }
                catch {
                    throw BaseLocalStorageRequestExecutorError.updateRequestFailed(error: error)
                }
            }
        }
    }
}

// MARK: - BaseLocalStorageRequestExecutorError

enum BaseLocalStorageRequestExecutorError: Swift.Error {
    case fetchRequestFailed(error: Error)
    case updateRequestFailed(error: Error)
}

extension BaseLocalStorageRequestExecutorError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .fetchRequestFailed(let error):
            return "\"BaseLocalStorageRequestExecutor\": Fetch request failed with: \(error.localizedDescription)"
        case .updateRequestFailed(let error):
            return "\"BaseLocalStorageRequestExecutor\": Update request failed with: \(error.localizedDescription)"
        }
    }
}
