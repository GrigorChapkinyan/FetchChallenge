//
//  IRequest.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation

// MARK: - URLRequest

/// This is an abstract interface representing a generic request.
protocol IRequest: CustomStringConvertible {}

// MARK: - URLRequest + IRequest

extension URLRequest: IRequest {}

// MARK: - IURLRequestConvertable

/// This is an abstract interface representing a "IRequest" type which can be converted to "URLRequest".
protocol IURLRequestConvertable: IRequest {
    /// Tries to build and return URLRequest.
    /// - Returns: URLRequest if no error was thrown.
    func asURLRequest() throws -> URLRequest
}

// MARK: - IRequestError

/// This is an enum repsresenting possible error cases of "IRequest" interface.
enum IRequestError: Swift.Error {
    case invalidRequestPassed
}

/// This is an enum repsresenting possible error cases of "IRequest" interface.
extension IRequestError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .invalidRequestPassed:
                return "An invalid request was passed for execution."
        }
    }
}
