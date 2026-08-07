//
//  NetworkError.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import Foundation

enum NetworkError: LocalizedError {
    case missingCredentials
    case invalidURL

    case invalidResponse
    case unexpectedStatus(code: Int, body: Data?)
    case unauthorized(body: Data?)
    case forbidden(body: Data?)
    case notFound(body: Data?)
    case clientError(code: Int, body: Data?)
    case serverError(code: Int, body: Data?)

    case decoding(Error)
    case transport(URLError)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "You need to be signed in to do that."
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .unexpectedStatus(let code, _):
            return "The server returned an unexpected status code (\(code))."
        case .unauthorized:
            return "Your session has expired. Please sign in again."
        case .forbidden:
            return "You don't have permission to do that."
        case .notFound:
            return "The requested resource could not be found."
        case .clientError(let code, _):
            return "Request failed with status code \(code)."
        case .serverError(let code, _):
            return "The server encountered an error (\(code)). Please try again later."
        case .decoding:
            return "Failed to decode the server response."
        case .transport(let error):
            return error.localizedDescription
        case .unknown(let error):
            return error.localizedDescription
        }
    }
    
}
