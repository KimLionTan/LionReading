//
//  GoogleBooksAPI.swift
//  LionReading
//
//  Created by TanJianing.
//

import Foundation

class GoogleBooksAPI {
    static func fetchBookByISBN(isbn: String, completion: @escaping (Result<Book?, BookAPIError>) -> Void) {
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidISBN))
            return
        }
        
        // Create a network request
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Handling network errors
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            // Ensure that data is returned
            guard let data = data else {
                completion(.failure(.customError("Data not received")))
                return
            }
            
            // Parsing JSON response
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                guard let json = json,
                      let totalItems = json["totalItems"] as? Int,
                      totalItems > 0,
                      let items = json["items"] as? [[String: Any]],
                      let volumeInfo = items.first?["volumeInfo"] as? [String: Any] else {
                    // No book found, but this is not an error, return nil
                    completion(.success(nil))
                    return
                }
                
                // Parsing book information
                let title = volumeInfo["title"] as? String ?? "Unknown Title"
                
                var author = "Unknown"
                if let authors = volumeInfo["authors"] as? [String], !authors.isEmpty {
                    author = authors.joined(separator: ", ")
                }
                
                let publisher = volumeInfo["publisher"] as? String ?? "Unknown Publisher"
                
                let publishedDate = volumeInfo["publishedDate"] as? String ?? "Unknown Date"
                
                let description = volumeInfo["description"] as? String ?? ""
                
                var imageUrl = ""
                if let imageLinks = volumeInfo["imageLinks"] as? [String: String],
                   let thumbnail = imageLinks["thumbnail"] {
                    imageUrl = thumbnail.replacingOccurrences(of: "http://", with: "https://")
                }
               
                var price: Double = 0.0
                if let saleInfo = items.first?["saleInfo"] as? [String: Any],
                   let listPrice = saleInfo["listPrice"] as? [String: Any],
                   let amount = listPrice["amount"] as? Double {
                    price = amount
                }
                
                // Create a Book object
                let book = Book(
                    UserId: 0,
                    BookId: Int.random(in: 1..<10000),
                    ISBN: isbn,
                    bName: title,
                    Author: author,
                    publisher: publisher,
                    pDate: publishedDate,
                    pPlace: "", 
                    price: price,
                    picture: imageUrl,
                    description: description
                )
                
                completion(.success(book))
                
            } catch {
                completion(.failure(.parsingError(error.localizedDescription)))
            }
        }.resume()
    }
}
