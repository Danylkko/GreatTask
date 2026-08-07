//
//  ServersListViewModel.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 07.08.2026.
//

import SwiftUI

@Observable
final class ServersListViewModel {

    enum SortField {
        case name
        case distance
    }

    enum SortOrder {
        case ascending
        case descending
    }

    var servers: [ServerModel] = []
    var isLoading = true
    var errorMessage: String?
    var sortField: SortField = .name
    var sortOrder: SortOrder = .ascending

    var sortedServers: [ServerModel] {
        let ascending = sortOrder == .ascending
        switch sortField {
        case .name:
            return servers.sorted {
                ascending
                    ? $0.name.localizedStandardCompare($1.name) == .orderedAscending
                    : $0.name.localizedStandardCompare($1.name) == .orderedDescending
            }
        case .distance:
            return servers.sorted {
                ascending ? $0.distance < $1.distance : $0.distance > $1.distance
            }
        }
    }

    private var dataService: DataServiceProtocol
    
    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }

    func fetchServers() {
        errorMessage = nil
        isLoading = true

        Task {
            do {
                try await Task.sleep(nanoseconds: 2_000_000_000) // TODO: remove
                servers = try await dataService.fetchServers()
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }

    func toggleSort(_ field: SortField) {
        if sortField == field {
            sortOrder = sortOrder == .ascending ? .descending : .ascending
        } else {
            sortField = field
            sortOrder = .ascending
        }
    }
}
