//
//  PersistentContainerProvider.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/12/23.
//

import Foundation

/// Actor container singelton object for working with "PersistentContainer" types safely
actor PersistentContainerProvider {
    // MARK: - Shared Instance
    
    static var shared = PersistentContainerProvider()
    
    // MARK: - Nested Types
    
    /// This is wrapper for holding weak reference to an object when pushing it into dictioanry
    private class WeakObjectWrapper<T: AnyObject> {
        weak var object: T?
        
        init(object: T? = nil) {
            self.object = object
        }
    }
    
    // MARK: - Private Properties
    
    private var inMemoryContainersDict: [String: WeakObjectWrapper<PersistentContainer>] = [:]
    private var persistentContainersDict: [String: WeakObjectWrapper<PersistentContainer>] = [:]
    
    // MARK: - Initializers
    
    private init(){}
    
    // MARK: - Public API
    
    func getItem(with name: String, inMemory: Bool) -> PersistentContainer {
        // Looking in dictionary
        // Getting the correct dictionary type
        let containersDict = inMemory ? inMemoryContainersDict : persistentContainersDict
        let itemOptional = containersDict[name]?.object
        if let itemOptional = itemOptional {
            return itemOptional
        }
        else {
            let newItem = PersistentContainer(containerName: name, inMemory: inMemory)
            // Pushing into correct dictionary
            if (inMemory) {
                inMemoryContainersDict[name] = WeakObjectWrapper(object: newItem)
            }
            else {
                persistentContainersDict[name] = WeakObjectWrapper(object: newItem)
            }
            // Returning new item
            return newItem
        }
    }
}
