//
//  NetworkError.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import Foundation

enum NetworkError: LocalizedError {
    case unauthorized
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "You need to be signed in to do that."
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .httpStatus(let code):
            return "Request failed with status code \(code)."
        case .decoding:
            return "Failed to decode the server response."
        case .transport(let error):
            return error.localizedDescription
        }
    }
}
