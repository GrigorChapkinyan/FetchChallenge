//
//  IWrapperObject.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/14/23.
//

import Foundation

/// This is an abstract interface representing a type which is a decodable wrapper of some type of objects
protocol IWrapperObject: Decodable {
    associatedtype WrappedObject
    
    var items: [WrappedObject] { get }
}
