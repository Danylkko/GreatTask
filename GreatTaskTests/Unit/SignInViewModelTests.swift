//
//  SignInViewModelTests.swift
//  GreatTaskTests
//

import Foundation
import Testing
@testable import GreatTask

@MainActor
@Suite("SignInViewModel")
struct SignInViewModelTests {

    private func makeSUT(
        remembered: Credentials? = nil,
        initialError: String? = nil
    ) -> (SignInViewModel, FakeAuthService, FakeSignInCoordinator) {
        let auth = FakeAuthService()
        auth.remembered = remembered
        let coordinator = FakeSignInCoordinator()
        let viewModel = SignInViewModel(
            authService: auth,
            initialErrorMessage: initialError,
            coordinator: coordinator
        )
        return (viewModel, auth, coordinator)
    }

    @Test("credentials remembered by the auth service prefill the form and tick the checkbox")
    func prefillsRememberedCredentials() {
        let (viewModel, _, _) = makeSUT(remembered: Credentials(username: "user", password: "secret"))

        #expect(viewModel.username == "user")
        #expect(viewModel.password == "secret")
        #expect(viewModel.rememberMe)
    }

    @Test("an empty form is left alone when nothing is remembered")
    func startsEmptyWithoutRememberedCredentials() {
        let (viewModel, _, _) = makeSUT(remembered: nil)

        #expect(viewModel.username.isEmpty)
        #expect(viewModel.password.isEmpty)
        #expect(viewModel.rememberMe == false)
    }

    @Test("a failed session restore is shown on the sign-in screen")
    func surfacesInitialErrorMessage() {
        let (viewModel, _, _) = makeSUT(initialError: "Session expired.")

        #expect(viewModel.errorMessage == "Session expired.")
    }

    @Test("successful sign in notifies the coordinator once and clears loading")
    func successNotifiesCoordinator() async {
        let (viewModel, auth, coordinator) = makeSUT()
        viewModel.username = "user"
        viewModel.password = "secret"
        viewModel.rememberMe = true

        viewModel.signIn()
        let task = viewModel.signInTask
        #expect(viewModel.isLoading)
        await task?.value

        #expect(coordinator.didSignInCount == 1)
        #expect(auth.lastRememberMe == true)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("a failed sign in marks both fields invalid and never advances")
    func failureMarksFieldsInvalid() async {
        let (viewModel, auth, coordinator) = makeSUT()
        auth.signInResult = .failure(AuthError.invalidCredentials)
        viewModel.username = "user"
        viewModel.password = "wrong"

        viewModel.signIn()
        await viewModel.signInTask?.value

        #expect(coordinator.didSignInCount == 0)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == AuthError.invalidCredentials.localizedDescription)
        #expect(viewModel.isFieldInvalid(.username))
        #expect(viewModel.isFieldInvalid(.password))
    }

    @Test("editing a field clears only that field's invalid state")
    func editingClearsInvalidStatePerField() async {
        let (viewModel, auth, _) = makeSUT()
        auth.signInResult = .failure(AuthError.invalidCredentials)
        viewModel.username = "user"
        viewModel.password = "wrong"

        viewModel.signIn()
        await viewModel.signInTask?.value

        viewModel.password = "corrected"

        #expect(viewModel.isFieldInvalid(.username))
        #expect(viewModel.isFieldInvalid(.password) == false)
        #expect(viewModel.errorMessage != nil)
    }
}
