//
//  ServersListViewModel.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 07.08.2026.
//

import SwiftUI

@Observable
final class ServersListViewModel {
    
    private var dataService: DataServiceProtocol
    
    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
    
}
