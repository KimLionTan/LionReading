//
//  OpenLibraryAPI.swift
//  LionReading
//
//  Created by TanJianing.
//

import Foundation

class OpenLibraryAPI {
    static func fetchBookByISBN(isbn: String, completion: @escaping (Result<Book?, BookAPIError>) -> Void) {
        let urlString = "https://openlibrary.org/api/books?bibkeys=ISBN:\(isbn)&format=json&jscmd=data"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.customError("Invalid URL")))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.customError("Data not received")))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                guard let json = json,
                      let bookData = json["ISBN:\(isbn)"] as? [String: Any] else {
                    completion(.success(nil))
                    return
                }

                let title = bookData["title"] as? String ?? "Unknown Title"

                var author = "Unknown"
                if let authors = bookData["authors"] as? [[String: Any]], !authors.isEmpty {
                    let authorNames = authors.compactMap { $0["name"] as? String }
                    if !authorNames.isEmpty {
                        author = authorNames.joined(separator: ", ")
                    }
                }

                var publisher = "Unknown Publisher"
                if let publishers = bookData["publishers"] as? [[String: Any]], !publishers.isEmpty {
                    if let publisherName = publishers.first?["name"] as? String {
                        publisher = publisherName
                    }
                }
                
                let publishedDate = bookData["publish_date"] as? String ?? "Unknown Date"
                
                let publishPlace = bookData["publish_places"] as? [[String: Any]] ?? []
                var place = ""
                if !publishPlace.isEmpty, let placeName = publishPlace.first?["name"] as? String {
                    place = placeName
                }
                
                var description = ""
                if let desc = bookData["description"] as? [String: Any], let value = desc["value"] as? String {
                    description = value
                } else if let desc = bookData["description"] as? String {
                    description = desc
                }
                
                var imageUrl = ""
                if let cover = bookData["cover"] as? [String: String], let medium = cover["medium"] {
                    imageUrl = medium
                }

                let price: Double = 0.0 //Normally, The Open Library does not have a price setting
                
                let book = Book(
                    UserId: 0,
                    BookId: Int.random(in: 1..<10000),
                    ISBN: isbn,
                    bName: title,
                    Author: author,
                    publisher: publisher,
                    pDate: publishedDate,
                    pPlace: place,
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
