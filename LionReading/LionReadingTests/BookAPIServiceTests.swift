//
//  BookAPIServiceTests.swift
//  LionReadingTests
//
//  Created by TanJianing.
//

import XCTest
@testable import LionReading

class BookAPIServiceTests: XCTestCase {
    // test ISBN
    let validISBN = "9780306406157"
    let invalidISBN = "invalid-isbn"
    
    // Use method exchange to simulate API calls
    class MockAPIHandler {
        static var mockGoogleResult: Result<Book?, BookAPIError>?
        static var mockOpenLibraryResult: Result<Book?, BookAPIError>?
        
        // Replace GoogleBooksAPI fetchBookByISBN method
        static func mockGoogleBooksAPI(isbn: String, completion: @escaping (Result<Book?, BookAPIError>) -> Void) {
            if let result = mockGoogleResult {
                completion(result)
            }
        }
        
        // Replace OpenLibraryAPI.fetchBookByISBN method
        static func mockOpenLibraryAPI(isbn: String, completion: @escaping (Result<Book?, BookAPIError>) -> Void) {
            if let result = mockOpenLibraryResult {
                completion(result)
            }
        }
    }
    
    override func setUp() {
        super.setUp()
        // Reset simulation result
        MockAPIHandler.mockGoogleResult = nil
        MockAPIHandler.mockOpenLibraryResult = nil
    }
    
    // The test successfully retrieved the book information from the Google Books API
    func testGoogleBooksAPISuccess() {
        let expectation = self.expectation(description: "Google Books API Success")
        
        let mockBook = Book(
            UserId: 0,
            BookId: 1,
            ISBN: validISBN,
            bName: "Test Book",
            Author: "Test Author",
            publisher: "Test Publisher",
            pDate: "2023",
            pPlace: "Test Place",
            price: 29.99,
            picture: "https://example.com/image.jpg",
            description: "Test description"
        )
        
        // Set analog response
        MockAPIHandler.mockGoogleResult = .success(mockBook)
        
        // Replace the API Method with Method Swizzling
        let originalGoogleMethod = GoogleBooksAPI.fetchBookByISBN
        let originalOpenLibraryMethod = OpenLibraryAPI.fetchBookByISBN
        
        // replace the method
        GoogleBooksAPI.fetchBookByISBN = MockAPIHandler.mockGoogleBooksAPI
        OpenLibraryAPI.fetchBookByISBN = MockAPIHandler.mockOpenLibraryAPI
        
        // Testing
        BookAPIService.fetchBookByISBN(isbn: validISBN) { result in
            // Restore original method
            GoogleBooksAPI.fetchBookByISBN = originalGoogleMethod
            OpenLibraryAPI.fetchBookByISBN = originalOpenLibraryMethod
            
            // validation
            switch result {
            case .success(let book):
                XCTAssertEqual(book.ISBN, self.validISBN, "ISBN should match")
                XCTAssertEqual(book.bName, "Test Book", "Book title should match")
                XCTAssertEqual(book.Author, "Test Author", "Author should match")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Should not fail: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Test scenarios where the Google Books API fails but the Open Library API succeeds
    func testGoogleFailOpenLibrarySuccess() {
        let expectation = self.expectation(description: "Google Fail Open Library Success")
        
        // set that the Google API fails
        MockAPIHandler.mockGoogleResult = .failure(.networkError("Network error"))
        
        // set that the Open Library API success
        let mockBook = Book(
            UserId: 0,
            BookId: 1,
            ISBN: validISBN,
            bName: "Open Library Book",
            Author: "Open Library Author",
            publisher: "Open Library Publisher",
            pDate: "2023",
            pPlace: "Open Library Place",
            price: 19.99,
            picture: "https://example.com/ol-image.jpg",
            description: "Open Library description"
        )
        MockAPIHandler.mockOpenLibraryResult = .success(mockBook)
        
        let originalGoogleMethod = GoogleBooksAPI.fetchBookByISBN
        let originalOpenLibraryMethod = OpenLibraryAPI.fetchBookByISBN
        
        GoogleBooksAPI.fetchBookByISBN = MockAPIHandler.mockGoogleBooksAPI
        OpenLibraryAPI.fetchBookByISBN = MockAPIHandler.mockOpenLibraryAPI
        
        BookAPIService.fetchBookByISBN(isbn: validISBN) { result in
            GoogleBooksAPI.fetchBookByISBN = originalGoogleMethod
            OpenLibraryAPI.fetchBookByISBN = originalOpenLibraryMethod
            
            switch result {
            case .success(let book):
                XCTAssertEqual(book.ISBN, self.validISBN, "ISBN should match")
                XCTAssertEqual(book.bName, "Open Library Book", "Book title should match")
                XCTAssertEqual(book.Author, "Open Library Author", "Author should match")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Should not fail: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Test the scenario where Google returns nil but Open Library succeeds
    func testGoogleNilOpenLibrarySuccess() {
        let expectation = self.expectation(description: "Google Nil Open Library Success")
        
        MockAPIHandler.mockGoogleResult = .success(nil)
        
        let mockBook = Book(
            UserId: 0,
            BookId: 1,
            ISBN: validISBN,
            bName: "Open Library Book",
            Author: "Open Library Author",
            publisher: "Open Library Publisher",
            pDate: "2023",
            pPlace: "Open Library Place",
            price: 19.99,
            picture: "https://example.com/ol-image.jpg",
            description: "Open Library description"
        )
        MockAPIHandler.mockOpenLibraryResult = .success(mockBook)
        
        let originalGoogleMethod = GoogleBooksAPI.fetchBookByISBN
        let originalOpenLibraryMethod = OpenLibraryAPI.fetchBookByISBN
        
        GoogleBooksAPI.fetchBookByISBN = MockAPIHandler.mockGoogleBooksAPI
        OpenLibraryAPI.fetchBookByISBN = MockAPIHandler.mockOpenLibraryAPI
        
        BookAPIService.fetchBookByISBN(isbn: validISBN) { result in
            GoogleBooksAPI.fetchBookByISBN = originalGoogleMethod
            OpenLibraryAPI.fetchBookByISBN = originalOpenLibraryMethod
            
            switch result {
            case .success(let book):
                XCTAssertEqual(book.ISBN, self.validISBN, "ISBN should match")
                XCTAssertEqual(book.bName, "Open Library Book", "Book title should match")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Should not fail: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Test scenarios where both apis fail
    func testBothAPIsFailure() {
        let expectation = self.expectation(description: "Both APIs Fail")
        
        MockAPIHandler.mockGoogleResult = .failure(.networkError("Google API error"))
        MockAPIHandler.mockOpenLibraryResult = .failure(.networkError("Open Library API error"))
        
        let originalGoogleMethod = GoogleBooksAPI.fetchBookByISBN
        let originalOpenLibraryMethod = OpenLibraryAPI.fetchBookByISBN
        
        GoogleBooksAPI.fetchBookByISBN = MockAPIHandler.mockGoogleBooksAPI
        OpenLibraryAPI.fetchBookByISBN = MockAPIHandler.mockOpenLibraryAPI
        
        BookAPIService.fetchBookByISBN(isbn: validISBN) { result in
            GoogleBooksAPI.fetchBookByISBN = originalGoogleMethod
            OpenLibraryAPI.fetchBookByISBN = originalOpenLibraryMethod
            
            switch result {
            case .success(_):
                XCTFail("Should fail when both APIs fail")
            case .failure(let error):
                if case .networkError(let message) = error {
                    XCTAssertTrue(message.contains("Google API error"), "Error message should contain Google API error")
                } else {
                    XCTFail("Should return networkError")
                }
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Test scenarios where both apis return nil
    func testBothAPIsReturnNil() {
        let expectation = self.expectation(description: "Both APIs Return Nil")
        
        MockAPIHandler.mockGoogleResult = .success(nil)
        MockAPIHandler.mockOpenLibraryResult = .success(nil)
        
        let originalGoogleMethod = GoogleBooksAPI.fetchBookByISBN
        let originalOpenLibraryMethod = OpenLibraryAPI.fetchBookByISBN
        
        GoogleBooksAPI.fetchBookByISBN = MockAPIHandler.mockGoogleBooksAPI
        OpenLibraryAPI.fetchBookByISBN = MockAPIHandler.mockOpenLibraryAPI
        
        BookAPIService.fetchBookByISBN(isbn: validISBN) { result in
            GoogleBooksAPI.fetchBookByISBN = originalGoogleMethod
            OpenLibraryAPI.fetchBookByISBN = originalOpenLibraryMethod
            
            switch result {
            case .success(_):
                XCTFail("Should fail when both APIs return nil")
            case .failure(let error):
                if case .customError(let message) = error {
                    XCTAssertTrue(message.contains("No book information"), "Error message should mention no book information")
                } else {
                    XCTFail("Should return customError")
                }
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}

// Extend function types to support method substitution
extension GoogleBooksAPI {
    static var fetchBookByISBN: (String, @escaping (Result<Book?, BookAPIError>) -> Void) -> Void = _originalFetchBookByISBN
    
    private static func _originalFetchBookByISBN(isbn: String, completion: @escaping (Result<Book?, BookAPIError>) -> Void) {
        GoogleBooksAPI._internalFetchBookByISBN(isbn: isbn, completion: completion)
    }
    
    // Private methods, keeping the original implementation
    private static func _internalFetchBookByISBN(isbn: String, completion: @escaping (Result<Book?, BookAPIError>) -> Void) {
        // Keep the reference to the original method
        Self.fetchBookByISBN(isbn, completion)
    }
}

extension OpenLibraryAPI {
    static var fetchBookByISBN: (String, @escaping (Result<Book?, BookAPIError>) -> Void) -> Void = _originalFetchBookByISBN
    
    private static func _originalFetchBookByISBN(isbn: String, completion: @escaping (Result<Book?, BookAPIError>) -> Void) {
        OpenLibraryAPI._internalFetchBookByISBN(isbn: isbn, completion: completion)
    }
    
    private static func _internalFetchBookByISBN(isbn: String, completion: @escaping (Result<Book?, BookAPIError>) -> Void) {
        Self.fetchBookByISBN(isbn, completion)
    }
}
