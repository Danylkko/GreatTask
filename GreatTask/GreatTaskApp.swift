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
        let tokenStorage = KeychainTokenStorage()
        let networkService = NetworkServiceImpl(
            baseURL: URL(string: "https://playground.nordsec.com/v1")!,
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
