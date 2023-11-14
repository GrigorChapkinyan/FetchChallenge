//
//  BaseRemoteStorageRequest.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation

/// Base class for the remote storage request type.
struct BaseRemoteStorageRequest<ItemType: IModelStructObject>: IRequest {
    // MARK: - Nested Types

    enum RequestType {
        case fetch(queryItems: [URLQueryItem]?, sortDescriptor: SortDescriptor<ItemType>?, limit: Int?)
        case add(items: [ItemType])
        case delete(items: [ItemType])
    }
    
    // MARK: - Private Properties
    
    let requestType: RequestType
    
    // MARK: - Initializers
    
    init(requestType: RequestType) {
        self.requestType = requestType
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        "BaseRemoteStorageRequest with type: \(self.requestType)"
    }
}
