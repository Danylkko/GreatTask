//
//  CachedServer.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 07.08.2026.
//

import SwiftData

@Model
final class CachedServer {
    var name: String
    var distance: Int

    init(name: String, distance: Int) {
        self.name = name
        self.distance = distance
    }
}

extension CachedServer {

    convenience init(_ server: ServerModel) {
        self.init(name: server.name, distance: server.distance)
    }

    var server: ServerModel {
        ServerModel(name: name, distance: distance)
    }
}
