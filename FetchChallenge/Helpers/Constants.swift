//
//  Constants.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation

/// Struct for storing constants and hardcoded strings.
struct Constants {
    enum PersistentContainerNames: String {
        case fetchChallenge = "FetchChallenge"
    }
    
    enum HardCodedLabels: String, ILocalizableRawRepresentable {
        case okay = "OK"
    }
}
