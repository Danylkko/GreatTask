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
    
    @State var viewModel: ServersListViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else {
                content
            }
        }
        .onAppear {
            viewModel.fetchServers()
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

            if let errorMessage = viewModel.errorMessage {
                Spacer()
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.sortedServers.enumerated()), id: \.offset) { _, server in
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
            sortButton(title: "SERVER", field: .name, alignment: .leading)
            sortButton(title: "DISTANCE", field: .distance, alignment: .leading)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(Color(.grayscaleLight))
    }

    private func sortButton(
        title: String,
        field: ServersListViewModel.SortField,
        alignment: Alignment
    ) -> some View {
        Button {
            viewModel.toggleSort(field)
        } label: {
            HStack(spacing: 4) {
                if alignment == .trailing {
                    Spacer(minLength: 0)
                }

                Text(title)
                    .font(.body)

                Image(.filterIcon)
                    .renderingMode(.template)
                    .font(.caption2.bold())

                if alignment == .leading {
                    Spacer(minLength: 0)
                }
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(
            viewModel.sortField == field ? Color(.primaryLightActive) : Color(.primaryLightInactive)
        )
        .frame(maxWidth: field == .distance ? Constants.distanceColumnWidth : .infinity, alignment: alignment)
    }

    private func row(for server: ServerModel) -> some View {
        HStack {
            Text(server.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(server.distance) km")
                .frame(maxWidth: Constants.distanceColumnWidth, alignment: .leading)
        }
        .font(.body)
        .padding(.vertical, 10)
    }
}
