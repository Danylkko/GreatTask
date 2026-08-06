//
//  AppCoordinator.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import SwiftUI

enum Route: Hashable {
    case list
}

enum AuthState {
    case checking
    case signedOut
    case signedIn
}

@MainActor
@Observable
final class AppCoordinator {
    var path = NavigationPath()
    var authState: AuthState = .signedOut
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
    
    func makeSignInViewModel() -> SignInViewModel {
        SignInViewModel(authService: authService) { [weak self] in
            self?.authState = .signedIn
        }
    }
    
    func makeServersListViewModel() -> ServersListViewModel {
        ServersListViewModel(dataService: dataService)
    }

    func signOut() {
        authService.signOut()
        path = NavigationPath()
        authState = .signedOut
    }

    @ViewBuilder
    func view(for route: Route) -> some View {
        switch route {
        case .list:
            ServersListView(viewModel: makeServersListViewModel())
        }
    }
}
