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
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var invalidFields: Set<InputField> = []

    private(set) var signInTask: Task<Void, Never>?

    private let authService: AuthServiceProtocol
    private weak var coordinator: SignInCoordinatorProtocol?

    init(
        authService: AuthServiceProtocol,
        initialErrorMessage: String? = nil,
        coordinator: SignInCoordinatorProtocol
    ) {
        self.authService = authService
        self.coordinator = coordinator
        self.errorMessage = initialErrorMessage
        
        if let rememberedCredentials = authService.rememberedCredentials() {
            username = rememberedCredentials.username
            password = rememberedCredentials.password
            rememberMe = true
        }
    }
    
    func signIn() {
        errorMessage = nil
        isLoading = true
        invalidFields.removeAll()
        
        signInTask = Task {
            do {
                _ = try await authService.signIn(
                    username: username,
                    password: password,
                    rememberMe: rememberMe
                )
                coordinator?.didSignIn()
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
