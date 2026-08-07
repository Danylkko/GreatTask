//
//  RootView.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import SwiftUI

struct RootView: View {
    @Bindable var coordinator: AppCoordinator
    
    var body: some View {
        Group {
            switch coordinator.authState {
            case .checking:
                ProgressView()
            case .signedOut:
                NavigationStack(path: $coordinator.path) {
                    SignInView(viewModel: coordinator.makeSignInViewModel())
                        .navigationDestination(for: Route.self) { route in
                            coordinator.view(for: route)
                        }
                }
            case .signedIn:
                NavigationStack(path: $coordinator.path) {
                    coordinator.view(for: .list)
                        .navigationDestination(for: Route.self) { route in
                            coordinator.view(for: route)
                        }
                }
            }
        }
        .task {
            await coordinator.restoreSession()
        }
    }
}

#Preview {
//    RootView()
}
