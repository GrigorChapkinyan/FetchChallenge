//
//  Utils.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import Foundation

// MARK: - Helper Interfaces

/// Protocol to retrieve localized strings for enums with a raw type of "String".
protocol ILocalizableRawRepresentable: RawRepresentable where RawValue == String {
    func localizedString(tableName: String?,
                         bundle: Bundle,
                         value: String,
                         comment: String) -> String
}

/// Default implementation for 'ILocalizableRawRepresentable' protocol.
extension ILocalizableRawRepresentable {
    func localizedString(tableName: String? = nil,
                             bundle: Bundle = Bundle.main,
                             value: String = "",
                             comment: String = "") -> String {
        return NSLocalizedString(self.rawValue, tableName: tableName, bundle: bundle, value: value, comment: comment)
    }
}
