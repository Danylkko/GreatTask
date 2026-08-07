//
//  SignInViewModel.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import SwiftUI

@Observable
final class SignInViewModel {
    
    enum InputField {
        case username
        case password
    }

    var username = "" {
        didSet {
            if username != oldValue { invalidFields.remove(.username) }
        }
    }
    
    var password = "" {
        didSet {
            if password != oldValue { invalidFields.remove(.password) }
        }
    }
    
    var rememberMe = false
    var isLoading = false
    private(set) var errorMessage: String?
    private(set) var invalidFields: Set<InputField> = []

    private let authService: AuthServiceProtocol
    private let onSignedIn: () -> Void

    init(
        authService: AuthServiceProtocol,
        rememberedCredentials: Credentials? = nil,
        initialErrorMessage: String? = nil,
        onSignedIn: @escaping () -> Void
    ) {
        self.authService = authService
        self.onSignedIn = onSignedIn
        self.errorMessage = initialErrorMessage

        if let rememberedCredentials {
            username = rememberedCredentials.username
            password = rememberedCredentials.password
            rememberMe = true
        }
    }
    
    func signIn() {
        errorMessage = nil
        isLoading = true
        invalidFields.removeAll()
        
        Task {
            do {
                _ = try await authService.signIn(
                    username: username,
                    password: password,
                    rememberMe: rememberMe
                )
                onSignedIn()
            } catch {
                invalidFields = [.username, .password]
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func isFieldInvalid(_ field: InputField) -> Bool {
        invalidFields.contains(field)
    }
}
