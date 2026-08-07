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
    var authState: AuthState = .checking
    private var servers: [ServerModel] = []
    private var restoreErrorMessage: String?
    
    private let authService: AuthServiceProtocol
    private let dataService: DataServiceProtocol

    init(
        authService: AuthServiceProtocol,
        dataService: DataServiceProtocol
    ) {
        self.authService = authService
        self.dataService = dataService
    }
    
    func restoreSession() async {
        guard authService.rememberedCredentials() != nil else {
            authService.signOut()
            authState = .signedOut
            return
        }
        
        do {
            _ = try await authService.restoreSession()
            authState = .signedIn
        } catch {
            restoreErrorMessage = error.localizedDescription
            authState = .signedOut
        }
    }
    
    func makeSignInViewModel() -> SignInViewModel {
        SignInViewModel(
            authService: authService,
            rememberedCredentials: authService.rememberedCredentials(),
            initialErrorMessage: restoreErrorMessage
        ) { [weak self] in
            self?.authState = .signedIn
        }
    }
    
    func makeServersListViewModel() -> ServersListViewModel {
        ServersListViewModel(dataService: dataService)
    }

    func signOut() {
        authService.signOut()
        path = NavigationPath()
        restoreErrorMessage = nil
        authState = .signedOut
        
        Task {
            await dataService.clearCachedServers()
        }
    }

    @ViewBuilder
    func view(for route: Route) -> some View {
        switch route {
        case .list:
            ServersListView(viewModel: makeServersListViewModel())
        }
    }
}
