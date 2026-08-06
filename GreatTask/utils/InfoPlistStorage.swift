//
//  InfoPlistStorage.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import Foundation

final class InfoPlistStorage {
    
    static let shared = InfoPlistStorage()
    
    @InfoPlistValues(key: .apiScheme)
    var apiScheme: String?
    
    @InfoPlistValues(key: .apiHost)
    var apiHost: String?
    
    @InfoPlistValues(key: .apiVersion)
    var apiVersion: String?
    
    var apiBaseURL: URL? {
        guard let apiScheme, let apiHost else { return nil }
        var components = URLComponents()
        components.scheme = apiScheme
        components.host = apiHost
        components.path = apiVersion.map { "/\($0)" } ?? ""
        return components.url
    }
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
    case apiScheme = "API_SCHEME"
    case apiHost = "API_HOST"
    case apiVersion = "API_VERSION"
}
