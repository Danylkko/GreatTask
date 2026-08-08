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
    private(set) var signOutTask: Task<Void, Never>?
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
            initialErrorMessage: restoreErrorMessage,
            coordinator: self
        )
    }
    
    func makeServersListViewModel() -> ServersListViewModel {
        ServersListViewModel(dataService: dataService)
    }

    func signOut() {
        authService.signOut()
        path = NavigationPath()
        restoreErrorMessage = nil
        authState = .signedOut
        
        signOutTask = Task {
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

extension AppCoordinator: SignInCoordinatorProtocol {
    func didSignIn() {
        authState = .signedIn
    }
}
