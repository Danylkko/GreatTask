//
//  GreatTaskApp.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import SwiftUI

@main
struct GreatTaskApp: App {
    
    @State var coordinator = AppCoordinator(
        authService: AuthServiceImpl(),
        dataService: DataServiceImpl()
    )
    
    var body: some Scene {
        WindowGroup {
            RootView(coordinator: coordinator)
        }
    }
}
