//
//  BaseLocalStorageRequest.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation

/// Base class for the local storage request type.
struct BaseLocalStorageRequest<ItemType: IModelManagedObject, RemoteType: IModelStructObject>: IRequest {

    // MARK: - Nested Types

    enum RequestType {
        case fetch(predicate: NSPredicate?, sortDescriptor: SortDescriptor<ItemType>?, limit: Int?)
        case update
        case add(items: [ItemType])
        case addFromRemoteItems(items: [RemoteType], ignorablePropertiesForOverwrite: [RemoteType.PropertiesRepresantable] = [])
        case delete(items: [ItemType])
        case deleteFromRemoteItems(items: [RemoteType], ignorablePropertiesForOverwrite: [RemoteType.PropertiesRepresantable] = [])
    }
    
    // MARK: - Private Properties
    
    let requestType: RequestType
    
    // MARK: - Initializers
    
    init(requestType: RequestType) {
        self.requestType = requestType
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        "BaseLocalStorageRequest with type: \(self.requestType)"
    }
}
