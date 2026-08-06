//
//  SignInViewModel.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import SwiftUI

@Observable
final class SignInViewModel {

    var username = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?

    private let authService: AuthServiceProtocol
    private let onSignedIn: () -> Void

    init(
        authService: AuthServiceProtocol,
        onSignedIn: @escaping () -> Void
    ) {
        self.authService = authService
        self.onSignedIn = onSignedIn
    }
    
    func signIn() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await authService.signIn(username: username, password: password)
            onSignedIn()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
