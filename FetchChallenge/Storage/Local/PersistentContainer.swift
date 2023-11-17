//
//  PersistentContainer.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/12/23.
//

import Foundation
import CoreData

/// Actor representing a persistent container type for safely working with it
actor PersistentContainer: Equatable {
    // MARK: - Private Properties
    
    private let containerName: String
    private let inMemory: Bool
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: containerName)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: Constants.PersistentContainer.PersistentStoreDescriptionUrlPaths.null.rawValue)
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    var moc: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    var bgMoc: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    // MARK: - Initializers
    
    init(containerName: String, inMemory: Bool) {
        self.containerName = containerName
        self.inMemory = inMemory
    }
    
    // MARK: - Equatable
    
    static func == (lhs: PersistentContainer, rhs: PersistentContainer) -> Bool {
        return (lhs.containerName == rhs.containerName) && (lhs.inMemory == rhs.inMemory)
    }
}

// MARK: - Constants + PersistentContainer

fileprivate extension Constants {
    struct PersistentContainer {
        enum PersistentStoreDescriptionUrlPaths: String {
            case null = "/dev/null"
        }
    }
}
