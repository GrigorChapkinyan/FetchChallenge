//
//  HTTPRequest.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation

/// Representation of HTTPRequest type
struct HTTPRequest: IURLRequestConvertable {
    // MARK: Nested types
    
    enum HTTPMethod: String {
        /// `DELETE` method.
        case delete = "DELETE"
        /// `GET` method.
        case get = "GET"
        /// `POST` method.
        case post = "POST"
        /// `PUT` method.
        case put = "PUT"
    }
    
    // MARK: - Private Properties
    
    private let url: String
    private let method: HTTPMethod
    private let headers: [String: String]?
    private let params: [URLQueryItem]?
    private let body: Data?
    
    // MARK: - Initializers
    
    init(url: String, method: HTTPMethod = .get, headers: [String : String]? = nil, params: [URLQueryItem]? = nil, body: Data? = nil) {
        self.url = url
        self.method = method
        self.headers = headers
        self.params = params
        self.body = body
    }

    // MARK: - IRequest
    
    func asURLRequest() throws -> URLRequest {
        // Trying to create URL from the absolute string
        guard let apiURL = URL(string: url) else {
            throw HTTPError.invalidUrlPath
        }
        
        // Creating and setuping URLComponent
        var urlComponents = URLComponents(url: apiURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = params
        
        // Trying to get updated URL from the URLComponent
        guard let requestURL = urlComponents?.url else {
            throw HTTPError.invalidParams
        }
        
        // Creating and setting up the URLRequest
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.setValue(Constants.HTTPRequest.HeaderValues.applicationJson.rawValue, forHTTPHeaderField: Constants.HTTPRequest.HeaderKeys.headerContentType.rawValue)
        request.setValue(Constants.HTTPRequest.HeaderValues.applicationJson.rawValue, forHTTPHeaderField: Constants.HTTPRequest.HeaderKeys.headerAccept.rawValue)
        request.httpBody = body
        
        // Returning the request
        return request
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        "\(method) - \(url)"
    }
}

// MARK: - Constants + HTTPRequest

fileprivate extension Constants {
    /// Represents constants for "HTTPRequest" struct
    struct HTTPRequest {
        /// Represents constants for user-friendly/debug messages
        enum Messages: String, ILocalizableRawRepresentable {
            case invalidURL = "Invalid URL"
        }
        
        /// Represents constants for HTTP header keys
        enum HeaderKeys: String {
            case headerContentType = "Content-Type"
            case headerAccept = "Accept"
        }
        
        /// Represents constants for HTTP header values
        enum HeaderValues: String {
            case applicationJson = "application/json"
        }
    }
}

// MARK: - HTTPError

/// Represents HTTP error types
enum HTTPError: Swift.Error {
    case clientSide
    case serverSide
    case undefined
    case invalidUrlPath
    case invalidParams
    case noHttpResponse
    case invalidResponseBody
}

extension HTTPError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .clientSide:
                return NSLocalizedString("Client side HTTP error.", comment: "")
            case .serverSide:
                return NSLocalizedString("Server side HTTP error.", comment: "")
            case .undefined:
                return NSLocalizedString("Undefined HTTP error.", comment: "")
            case .invalidUrlPath:
                return NSLocalizedString("The passed URL path for the HTTP request is invalid.", comment: "")
            case .invalidParams:
                return NSLocalizedString("The passed URL params for the HTTP request is invalid.", comment: "")
            case .noHttpResponse:
                return NSLocalizedString("The HTTP response is empty.", comment: "")
            case .invalidResponseBody:
                return NSLocalizedString("The HTTP response body is invalid.", comment: "")
        }
    }
}
