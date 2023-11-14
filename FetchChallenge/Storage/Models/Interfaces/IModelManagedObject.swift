//
//  IModelManagedObject.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation
import CoreData

/// This is an abstract interface representing a type which is representation of managed objects.
protocol IModelManagedObject: NSManagedObject where PredicateKeys: IPredicateKeys {
    associatedtype PredicateKeys
    
    /// Returns the struct represntation of the given object
    /// - Returns: The converted struct representation object
    func getStructObject() throws -> any IModelStructObject
    
    /// Returns the entity name of the current managed object
    /// - Returns: Entity name
    static func getEntityName() -> String
    
    /// Returns the persistent container's name
    /// - Returns: The persistent contianer's name
    static func getPersistentContainerName() -> String
    
    /// Converts passed "predicateDict" into nsDictionary appropriate to this object and returns
    /// - Parameter predicateDict: The predicates key/value dictionary or nil
    /// - Returns: Appropriate nsPredicate if everything is ok, nil otherwise
    static func getNsPredicate(from predicateDict: [PredicateKeys : String]?) -> NSPredicate?
}

extension IModelManagedObject {
    static func getPersistentContainerName() -> String {
        // Giving default implementation,
        // because actually we have only one persistent container
        return Constants.PersistentContainerNames.fetchChallenge.rawValue
    }
}

// MARK: - IModelManagedObjectError

enum IModelManagedObjectError: Swift.Error {
    case propertyIsNil
}

extension IModelManagedObjectError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .propertyIsNil:
                return "Fail to parse property, because it is nil."
        }
    }
}
