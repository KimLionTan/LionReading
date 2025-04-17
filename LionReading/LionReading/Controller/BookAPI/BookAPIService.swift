//
//  BookAPIService.swift
//  LionReading
//
//  Created by TanJianing.
//

import Foundation

class BookAPIService {
    // Use multiple apis to get book information
    static func fetchBookByISBN(isbn: String, completion: @escaping (Result<Book, BookAPIError>) -> Void) {
        
        GoogleBooksAPI.fetchBookByISBN(isbn: isbn) { result in
            switch result {
            case .success(let book):
                if let book = book {
                    completion(.success(book))
                } else {
                    OpenLibraryAPI.fetchBookByISBN(isbn: isbn) { openLibResult in
                        switch openLibResult {
                        case .success(let openLibBook):
                            if let openLibBook = openLibBook {
                                completion(.success(openLibBook))
                            } else {
                                completion(.failure(.customError("No book information was found for the ISBN")))
                            }
                        case .failure(let error):
                            // The Open Library API failed
                            completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                // The Google Books API failed
                OpenLibraryAPI.fetchBookByISBN(isbn: isbn) { openLibResult in
                    switch openLibResult {
                    case .success(let openLibBook):
                        if let openLibBook = openLibBook {
                            completion(.success(openLibBook))
                        } else {
                            completion(.failure(.customError("No book information was found for the ISBN")))
                        }
                    case .failure(_):
                        // All APIs are faulty, returning the original Google error
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
