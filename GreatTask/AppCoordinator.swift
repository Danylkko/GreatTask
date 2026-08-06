//
//  AppCoordinator.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import SwiftUI

enum Route: Hashable {
    case loading
    case list
}

@MainActor
@Observable
final class AppCoordinator {
    var path = NavigationPath()
    private var servers: [ServerModel] = []
    
    private let authService: AuthServiceProtocol
    private let dataService: DataServiceProtocol

    init(
        authService: AuthServiceProtocol,
        dataService: DataServiceProtocol
    ) {
        self.authService = authService
        self.dataService = dataService
    }

    @ViewBuilder
    func view(for route: Route) -> some View {
        
    }
}
