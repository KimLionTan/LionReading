//
//  BookAPIError.swift
//  LionReading
//
//  Created by TanJianing.
//

import Foundation

enum BookAPIError: Error {
    case networkError(String)
    case parsingError(String)
    case notFound
    case customError(String)
    case decodingError
    case invalidISBN
        
    var localizedDescription: String {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .parsingError(let message):
            return "Fail to parse: \(message)"
        case .notFound:
            return "Fail to find book information"
        case .customError(let message):
            return message
        case .decodingError:
            return "Failed to decode book data"
        case .invalidISBN:
            return "Invalid ISBN format"
        }
    }
}
