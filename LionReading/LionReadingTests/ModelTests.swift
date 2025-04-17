//
//  ModelTests.swift
//  LionReadingTests
//
//  Created by TanJianing.
//

import XCTest
@testable import LionReading

class ModelTests: XCTestCase {
    
    // Test User Model
    func testUserModel() {
        let user = User(
            id: 1,
            account: "test@example.com",
            password: "Password123!",
            userName: "TestUser",
            headPort: ""
        )
        
        // Verify basic attributes
        XCTAssertEqual(user.id, 1, "User ID should be 1")
        XCTAssertEqual(user.account, "test@example.com", "Account should match")
        XCTAssertEqual(user.password, "Password123!", "Password should match")
        XCTAssertEqual(user.userName, "TestUser", "Username should match")
        XCTAssertEqual(user.headPort, "", "path should match")
        
        // Test the withUpdatedUserName method
        let updatedNameUser = user.withUpdatedUserName("NewName")
        XCTAssertEqual(updatedNameUser.userName, "NewName", "Username should be updated")
        XCTAssertEqual(updatedNameUser.id, user.id, "ID should remain unchanged")
        XCTAssertEqual(updatedNameUser.account, user.account, "Account should remain unchanged")
        XCTAssertEqual(updatedNameUser.password, user.password, "Password should remain unchanged")
        XCTAssertEqual(updatedNameUser.headPort, user.headPort, "Headport should remain unchanged")
        
    }
    
    // Test Book Model
    func testBookModel() {
        let book = Book(
            UserId: 1,
            BookId: 100,
            ISBN: "9780306406157",
            bName: "Test Book",
            Author: "Test Author",
            publisher: "Test Publisher",
            pDate: "2023",
            pPlace: "Test Place",
            price: 29.99,
            picture: "cover.jpg",
            description: "This is a test book."
        )
        
        // Verify basic attributes
        XCTAssertEqual(book.UserId, 1, "User ID should be 1")
        XCTAssertEqual(book.BookId, 100, "Book ID should be 100")
        XCTAssertEqual(book.ISBN, "9780306406157", "ISBN should match")
        XCTAssertEqual(book.bName, "Test Book", "Book name should match")
        XCTAssertEqual(book.Author, "Test Author", "Author should match")
        XCTAssertEqual(book.publisher, "Test Publisher", "Publisher should match")
        XCTAssertEqual(book.pDate, "2023", "Publication date should match")
        XCTAssertEqual(book.pPlace, "Test Place", "Publication place should match")
        XCTAssertEqual(book.price, 29.99, "Price should match")
        XCTAssertEqual(book.picture, "cover.jpg", "Cover image path should match")
        XCTAssertEqual(book.description, "This is a test book.", "Description should match")
        
        // Test the Hashable implementation
        let book2 = Book(
            UserId: 1,
            BookId: 100,
            ISBN: "9780306406157",
            bName: "Test Book",
            Author: "Test Author",
            publisher: "Test Publisher",
            pDate: "2023",
            pPlace: "Test Place",
            price: 29.99,
            picture: "cover.jpg",
            description: "This is a test book."
        )
        
        XCTAssertEqual(book, book2, "Equal books should be equal")
        
        // Test how different books compare
        let differentBook = Book(
            UserId: 1,
            BookId: 101,
            ISBN: "9780306406157",
            bName: "Test Book",
            Author: "Test Author",
            publisher: "Test Publisher",
            pDate: "2023",
            pPlace: "Test Place",
            price: 29.99,
            picture: "cover.jpg",
            description: "This is a test book."
        )
        
        XCTAssertNotEqual(book, differentBook, "Different books should not be equal")
    }
    
    // Test Label Model
    func testLabelModel() {
        // Create a system tag
        let systemLabel = Label(
            id: 1,
            labelName: "Novel",
            personalized: false
        )
        
        // Verify basic attributes
        XCTAssertEqual(systemLabel.id, 1, "Label ID should be 1")
        XCTAssertEqual(systemLabel.labelName, "Novel", "Label name should match")
        XCTAssertFalse(systemLabel.personalized, "System label should not be personalized")
        
        // Create a user-defined label
        let customLabel = Label(
            id: 2,
            labelName: "My Favorites",
            personalized: true
        )
        
        // Verify basic attributes
        XCTAssertEqual(customLabel.id, 2, "Label ID should be 2")
        XCTAssertEqual(customLabel.labelName, "My Favorites", "Label name should match")
        XCTAssertTrue(customLabel.personalized, "Custom label should be personalized")
        
        // Test the Hashable and Equatable implementations
        let systemLabelCopy = Label(id: 1, labelName: "Novel", personalized: false)
        XCTAssertEqual(systemLabel, systemLabelCopy, "Equal labels should be equal")
        
        let differentLabel = Label(id: 3, labelName: "Novel", personalized: false)
        XCTAssertNotEqual(systemLabel, differentLabel, "Labels with different IDs should not be equal")
    }
    
    // Test the ReadingStatus enumeration
    func testReadingStatus() {
        // Test raw value
        XCTAssertEqual(ReadingStatus.hopeToRead.rawValue, 0, "hopeToRead should have raw value 0")
        XCTAssertEqual(ReadingStatus.alreadyRead.rawValue, 1, "alreadyRead should have raw value 1")
        
        // Test description property
        XCTAssertEqual(ReadingStatus.hopeToRead.description, "Hope to Read", "Description should match")
        XCTAssertEqual(ReadingStatus.alreadyRead.description, "Already Read", "Description should match")
        
        // Test fromString function
        XCTAssertEqual(ReadingStatus.fromString("Hope to Read"), .hopeToRead, "Should convert string to status")
        XCTAssertEqual(ReadingStatus.fromString("Already Read"), .alreadyRead, "Should convert string to status")
        XCTAssertNil(ReadingStatus.fromString("Invalid Status"), "Should return nil for invalid status string")
    }
    
    // Test model encoding and Decoding (Codable)
    func testModelCodable() {
        // Test User encoding and decoding
        let user = User(id: 1, account: "test@example.com", password: "Password123!", userName: "TestUser", headPort: "")
        
        do {
            let encoder = JSONEncoder()
            let userData = try encoder.encode(user)
            
            let decoder = JSONDecoder()
            let decodedUser = try decoder.decode(User.self, from: userData)
            
            XCTAssertEqual(user, decodedUser, "User should be the same after encoding and decoding")
        } catch {
            XCTFail("Failed to encode or decode User: \(error)")
        }
        
        // Test Book encoding and decoding
        let book = Book(
            UserId: 1,
            BookId: 100,
            ISBN: "9780306406157",
            bName: "Test Book",
            Author: "Test Author",
            publisher: "Test Publisher",
            pDate: "2023",
            pPlace: "Test Place",
            price: 29.99,
            picture: "cover.jpg",
            description: "This is a test book."
        )
        
        do {
            let encoder = JSONEncoder()
            let bookData = try encoder.encode(book)
            
            let decoder = JSONDecoder()
            let decodedBook = try decoder.decode(Book.self, from: bookData)
            
            XCTAssertEqual(book, decodedBook, "Book should be the same after encoding and decoding")
        } catch {
            XCTFail("Failed to encode or decode Book: \(error)")
        }
        
        // Test Label encoding and decoding
        let label = Label(id: 1, labelName: "Novel", personalized: false)
        
        do {
            let encoder = JSONEncoder()
            let labelData = try encoder.encode(label)
            
            let decoder = JSONDecoder()
            let decodedLabel = try decoder.decode(Label.self, from: labelData)
            
            XCTAssertEqual(label, decodedLabel, "Label should be the same after encoding and decoding")
        } catch {
            XCTFail("Failed to encode or decode Label: \(error)")
        }
    }
}
