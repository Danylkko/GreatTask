//
//  SignInView.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import SwiftUI

struct SignInView: View {

    private enum Constants {
        static let stackWidth: CGFloat = 200
        static let horizontalPadding: CGFloat = 24

        static let paneMinWidth: CGFloat = stackWidth + horizontalPadding * 2
        static let logoSize = CGSize(width: 200, height: 51)
        static let logoBottomSpacing: CGFloat = 40
        static let fieldsSpacing: CGFloat = 8
        static let buttonTopSpacing: CGFloat = 16
        
        static let wallpaperPaneSize = CGSize(width: 379, height: 437)
        static let wallpaperPhotoSize = CGSize(width: 724, height: 481)
        static let wallpaperPhotoOffset = CGPoint(x: -117, y: 0)
    }

    @State private var viewModel: SignInViewModel
    
    init(viewModel: SignInViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack(spacing: 0) {
            loginStack
                .frame(width: Constants.stackWidth)
                .frame(minWidth: Constants.paneMinWidth, maxWidth: .infinity, maxHeight: .infinity)

            wallpaper
        }
        // Keeps the window minimum in place should either pane ever become flexible.
        .frame(minWidth: Constants.paneMinWidth * 2)
    }

    private var loginStack: some View {
        VStack(spacing: 0) {
            Image(.testioLogo)
                .resizable()
                .scaledToFit()
                .frame(width: Constants.logoSize.width, height: Constants.logoSize.height)

            TextField(text: $viewModel.username) {
                Text("username")
            }
            .disableAutocorrection(true)
            .padding(.top, Constants.logoBottomSpacing)

            SecureField(text: $viewModel.password) {
                Text("password")
            }
            .padding(.top, Constants.fieldsSpacing)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, Constants.fieldsSpacing)
            }

            Button {
                Task { await viewModel.signIn() }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("Sign in")
                }
            }
            .disabled(viewModel.isLoading)
            .frame(maxWidth: .infinity)
            .padding(.top, Constants.buttonTopSpacing)
        }
    }

    private var wallpaper: some View {
        GeometryReader { proxy in
            let scale = max(
                proxy.size.width / Constants.wallpaperPaneSize.width,
                proxy.size.height / Constants.wallpaperPaneSize.height
            )

            Image(.loginWallpaper)
                .resizable()
                .frame(
                    width: Constants.wallpaperPhotoSize.width * scale,
                    height: Constants.wallpaperPhotoSize.height * scale
                )
                .offset(
                    x: Constants.wallpaperPhotoOffset.x * scale,
                    y: Constants.wallpaperPhotoOffset.y * scale
                )
        }
        .frame(minWidth: Constants.paneMinWidth, maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
}
