//
//  SignInView.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import SwiftUI

struct SignInView: View {
    
    @State private var viewModel: SignInViewModel
    
    init(viewModel: SignInViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Image(.testioLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 51)
            
            TextField(text: $viewModel.username) {
                Text("username")
            }
            .disableAutocorrection(true)

            SecureField(text: $viewModel.password) {
                Text("password")
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button {
                Task { await viewModel.signIn() }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Sign in")
                }
            }
            .disabled(viewModel.isLoading)
        }
        .padding()
    }
}
