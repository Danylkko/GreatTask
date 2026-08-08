//
//  ServersListView.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 07.08.2026.
//

import SwiftUI

struct ServersListView: View {
    
    private enum Constants {
        static let distanceColumnWidth: CGFloat = 100
    }
    
    @State private var viewModel: ServersListViewModel

    init(viewModel: ServersListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else {
                content
            }
        }
        .onAppear {
            viewModel.loadServers()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.regular)
            Text("LOADING LIST")
                .font(.caption)
                .foregroundStyle(Color(.primaryLightInactive))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var content: some View {
        VStack(spacing: 0) {
            header
            Divider()

            if let errorMessage = viewModel.errorMessage, viewModel.sortedServers.isEmpty {
                Spacer()
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else {
                if let errorMessage = viewModel.errorMessage {
                    staleBanner(errorMessage)
                    Divider()
                }

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.sortedServers, id: \.self) { server in
                            row(for: server)
                            Divider()
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 0) {
            sortButton(title: "SERVER", field: .name)
            sortButton(title: "DISTANCE", field: .distance)

            if viewModel.isRefreshing {
                ProgressView()
                    .controlSize(.small)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: viewModel.isRefreshing)
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(Color(.grayscaleLight))
    }
    
    private func staleBanner(_ message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.vertical, 6)
            .background(Color.red.opacity(0.08))
    }

    private func sortButton(title: String, field: ServersListViewModel.SortField) -> some View {
        Button {
            viewModel.toggleSort(field)
        } label: {
            HStack(spacing: 4) {
                Text(title)
                    .font(.body)

                Image(.filterIcon)
                    .renderingMode(.template)
                    .font(.caption2.bold())

                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(
            viewModel.sortField == field ? Color(.primaryLightActive) : Color(.primaryLightInactive)
        )
        .frame(
            maxWidth: field == .distance ? Constants.distanceColumnWidth : .infinity,
            alignment: .leading
        )
    }

    private func row(for server: ServerModel) -> some View {
        HStack(spacing: 0) {
            Text(server.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(server.distance) km")
                .frame(maxWidth: Constants.distanceColumnWidth, alignment: .leading)
        }
        .font(.body)
        .padding(.vertical, 10)
    }
}
