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
        
        let authService = AuthServiceImpl(tokenStorage: tokenStorage)
        let dataService = DataServiceImpl()
        
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
