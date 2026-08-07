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

        static let wallpaperPaneSize = CGSize(width: 379, height: 437)
        static let wallpaperPhotoSize = CGSize(width: 724, height: 481)
        static let wallpaperPhotoOffset = CGPoint(x: -117, y: 0)
    }

    @State private var viewModel: SignInViewModel
    @ScaledMetric(relativeTo: .footnote) private var errorSlotHeight: CGFloat = 26

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
        .frame(minWidth: Constants.paneMinWidth * 2)
    }

    private var loginStack: some View {
        VStack(spacing: 0) {
            Image(.testioLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 51)

            TextField(text: $viewModel.username) {
                Text("Username")
            }
            .disableAutocorrection(true)
            .borderedField(isInvalid: viewModel.isFieldInvalid(.username))
            .padding(.top, 40)

            SecureField(text: $viewModel.password) {
                Text("Password")
            }
            .borderedField(isInvalid: viewModel.isFieldInvalid(.password))
            .padding(.top, 8)

            Button {
                viewModel.signIn()
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
            .padding(.top, 16)
            
            Text(viewModel.errorMessage ?? "")
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .font(.footnote)
                .frame(height: errorSlotHeight, alignment: .bottom)
                .padding(.top, 8)
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
