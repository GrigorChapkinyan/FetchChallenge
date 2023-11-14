//
//  BaseRemoteStorageRequestExecutor.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation

/// Base class for the remote storage request executor type.
final class BaseRemoteStorageRequestExecutor<ItemType: IModelStructObject>: IRequestExecutor {
    // MARK: - Private Properties
    
    private let httpRequestExecutor: HTTPRequestExecutor
    
    // MARK: Initializers
    
    init(with httpRequestExecutor: HTTPRequestExecutor) {
        self.httpRequestExecutor = httpRequestExecutor
    }
    
    // MARK: - IRequestExecutor
    
    func execute(_ request: IRequest) async -> Result<Any, Error> {
        do {
            // Converting request to expected request type
            guard let remoteStorageRequest = request as? BaseRemoteStorageRequest<ItemType> else {
                throw IRequestError.invalidRequestPassed
            }
            
            // Trying to parse remoteRequest into HttpRequest
            let httpRequest = try ItemType.convertRemoteStorageRequestToHttpRequest(remoteStorageRequest)
            // Executing the httpRequest
            let httpRequestResult = await httpRequestExecutor
                .execute(httpRequest)
            var retVal: Result<Any, Error>
            
            // We have to modify return value(parse items) if the request type was "fetch"
            switch remoteStorageRequest.requestType {
                case .fetch(_, let sortDescriptor, _):
                    retVal = httpRequestResult
                        .flatMap({ (data) in
                            do {
                                let itemsToReturn = try self.getItemsFrom(
                                    httpResponseData: data,
                                    remoteStorageRequest: remoteStorageRequest,
                                    sortDescriptor: sortDescriptor)
                                
                                return .success(itemsToReturn)
                            }
                            catch {
                                return .failure(error)
                            }
                        })
                default:
                    retVal = httpRequestResult
            }
            
            return retVal
        }
        catch {
            return .failure(error)
        }
    }
    
    // MARK: - Private API

    /// Returns items parsed from the passed "httpResponseData" using "remoteStorageRequest" as information about the data.
    /// - Parameters:
    ///   - httpResponseData: HTTP  response data to be parsed.
    ///   - remoteStorageRequest: The remote storage request to use to get information about data type.
    ///   - sortDescriptor: The sort descriptor to sort the items.
    /// - Returns: The result of the finished process.
    private func getItemsFrom(
        httpResponseData: Any,
        remoteStorageRequest: BaseRemoteStorageRequest<ItemType>,
        sortDescriptor: SortDescriptor<ItemType>?
    ) throws -> [ItemType] {
        guard let data = httpResponseData as? Data else {
            throw BaseRemoteStorageRequestExecutorError.dataDowncastError
        }
        
        var parsedItems: [ItemType]
        
        
        if ItemType.expectArray(for: remoteStorageRequest.requestType) {
            parsedItems = try ItemType.getDecoder(for: remoteStorageRequest).decode([ItemType].self, from: data)
        }
        else {
            parsedItems = [try ItemType.getDecoder(for: remoteStorageRequest).decode(ItemType.self, from: data)]
        }
        
        if let sortDescriptor = sortDescriptor {
            parsedItems.sort(using: sortDescriptor)
        }
        
        return parsedItems
    }
}

// MARK: - BaseRemoteStorageRequestExecutorError

enum BaseRemoteStorageRequestExecutorError: Swift.Error {
    case httpError(httpError: HTTPError)
    case noProvidedApiForCurrentAction
    case dataDowncastError
}

extension BaseRemoteStorageRequestExecutorError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .httpError(let httpError):
            return httpError.errorDescription
        case .noProvidedApiForCurrentAction:
            return NSLocalizedString("No API is provided for current action.", comment: "")
        case .dataDowncastError:
            return NSLocalizedString("Fail to downcast the data.", comment: "")
        }
    }
}
