//
//  IRequestExecutor.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation

/// This is an abstract interface representing an API for executing requests of "IRequest" type.
protocol IRequestExecutor {
    func execute(_ request: IRequest) async -> Result<Any, Error>
}
