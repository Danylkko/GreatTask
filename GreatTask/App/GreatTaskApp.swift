//
//  GreatTaskApp.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import SwiftUI

@main
struct GreatTaskApp: App {
    
    @State var coordinator: AppCoordinator = {
        guard let baseURL = InfoPlistStorage.shared.apiBaseURL else {
            fatalError("Missing API_SCHEME/API_HOST in Info.plist")
        }
        
        let tokenStorage = KeychainTokenStorage()
        let networkService = NetworkServiceImpl(
            baseURL: baseURL,
            tokenStorage: tokenStorage
        )

        let authService = AuthServiceImpl(
            networkService: networkService,
            tokenStorage: tokenStorage
        )
        let dataService = DataServiceImpl(networkService: networkService)

        return AppCoordinator(
            authService: authService,
            dataService: dataService
        )
    }()
    
    var body: some Scene {
        WindowGroup {
            RootView(coordinator: coordinator)
        }
    }
}
