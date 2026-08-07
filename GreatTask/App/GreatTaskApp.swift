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
        let credentialsStorage = KeychainCredentialsStorage()
        let networkService = NetworkServiceImpl(
            baseURL: baseURL,
            tokenStorage: tokenStorage
        )

        let authService = AuthServiceImpl(
            networkService: networkService,
            tokenStorage: tokenStorage,
            credentialsStorage: credentialsStorage
        )
        let serversCache = ServersCacheImpl(modelContainer: .serversCache())
        let dataService = DataServiceImpl(
            networkService: networkService,
            cache: serversCache
        )

        return AppCoordinator(
            authService: authService,
            dataService: dataService
        )
    }()
    
    var body: some Scene {
        WindowGroup {
            RootView(coordinator: coordinator)
                .preferredColorScheme(.light)
                .navigationTitle("testio.")
                .toolbar(removing: .title)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("testio.")
                            .font(.body.bold())
                    }
                    .sharedBackgroundVisibility(.hidden)

                    if coordinator.authState == .signedIn {
                        ToolbarSpacer(.flexible)

                        ToolbarItem {
                            Button {
                                coordinator.signOut()
                            } label: {
                                Image(.signoutIcon)
                            }
                            .labelStyle(.iconOnly)
                            .help("Log out")
                        }
                        .sharedBackgroundVisibility(.hidden)
                    }
                }
        }
    }
}
