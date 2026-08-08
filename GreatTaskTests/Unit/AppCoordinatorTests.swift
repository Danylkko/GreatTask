//
//  AppCoordinatorTests.swift
//  GreatTaskTests
//

import Foundation
import SwiftUI
import Testing
@testable import GreatTask

@MainActor
@Suite("AppCoordinator")
struct AppCoordinatorTests {

    private func makeSUT() -> (AppCoordinator, FakeAuthService, FakeDataService) {
        let auth = FakeAuthService()
        let data = FakeDataService()
        return (AppCoordinator(authService: auth, dataService: data), auth, data)
    }

    @Test("launching without remembered credentials signs out without a network call")
    func restoreWithoutCredentials() async {
        let (coordinator, auth, _) = makeSUT()
        auth.remembered = nil

        await coordinator.restoreSession()

        #expect(coordinator.authState == .signedOut)
        #expect(auth.restoreCount == 0)
        #expect(auth.signOutCount == 1)
    }

    @Test("a successful restore lands on the signed-in state")
    func restoreSucceeds() async {
        let (coordinator, auth, _) = makeSUT()
        auth.remembered = Credentials(username: "user", password: "secret")

        await coordinator.restoreSession()

        #expect(coordinator.authState == .signedIn)
        #expect(auth.restoreCount == 1)
    }

    @Test("a failed restore hands its message to the sign-in screen")
    func restoreFailurePropagatesMessage() async {
        let (coordinator, auth, _) = makeSUT()
        auth.remembered = Credentials(username: "user", password: "stale")
        auth.restoreResult = .failure(AuthError.invalidCredentials)

        await coordinator.restoreSession()

        #expect(coordinator.authState == .signedOut)
        #expect(
            coordinator.makeSignInViewModel().errorMessage
                == AuthError.invalidCredentials.localizedDescription
        )
    }

    @Test("signing out resets navigation, the stale message and the cache")
    func signOutResetsEverything() async {
        let (coordinator, auth, data) = makeSUT()
        auth.remembered = Credentials(username: "user", password: "stale")
        auth.restoreResult = .failure(AuthError.invalidCredentials)
        await coordinator.restoreSession()

        coordinator.didSignIn()
        coordinator.path.append(Route.list)

        coordinator.signOut()
        await coordinator.signOutTask?.value

        #expect(coordinator.authState == .signedOut)
        #expect(coordinator.path.isEmpty)
        #expect(auth.signOutCount == 1)
        #expect(data.clearCount == 1)
        #expect(coordinator.makeSignInViewModel().errorMessage == nil)
    }
}
