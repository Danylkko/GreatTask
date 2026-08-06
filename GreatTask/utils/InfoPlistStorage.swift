//
//  InfoPlistStorage.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import Foundation

final class InfoPlistStorage {
    
    static let shared = InfoPlistStorage()
    
    @InfoPlistValues(key: .apiKey)
    var apiKey: String?
    
}

@propertyWrapper
struct InfoPlistValues<T> {
    
    var getter: () -> T?
    
    var wrappedValue: T? {
        getter()
    }
    
    init(key: InfoPlistKeys) {
        getter = { Bundle.main.object(forInfoDictionaryKey: key.rawValue) as? T }
    }
    
}

enum InfoPlistKeys: String {
    case apiKey = "API_KEY"
}
