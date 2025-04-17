//
//  BookControllerTests.swift
//  LionReadingTests
//
//  Created by TanJianing.
//

import XCTest
@testable import LionReading

class BookControllerTests: XCTestCase {
    var bookController: BookController!
    var testUserId: Int = -1
    var testBookId: Int = -1
    var testLabelId: Int = -1
    
    override func setUp() {
        super.setUp()
        bookController = BookController.shared
        
        let testUser = User(id: 0, account: "testuser@example.com", password: "Password123!", userName: "TestUser", headPort: "")
        testUserId = Int(DatabaseHelper.shared.addUser(user: testUser))
       
        XCTAssertGreaterThan(testUserId, 0, "Failed to create test user")
        
        let testBook = Book(
            UserId: testUserId,
            BookId: 0,
            ISBN: "9781234567897",
            bName: "Test Book",
            Author: "Test Author",
            publisher: "Test Publisher",
            pDate: "2023",
            pPlace: "Test Place",
            price: 29.99,
            picture: "",
            description: "Test description"
        )
        
        let bookIdInt64 = DatabaseHelper.shared.insertBook(book: testBook)
        testBookId = Int(bookIdInt64)
        
        XCTAssertGreaterThan(testBookId, 0, "Failed to create test book")
        
        let testLabel = Label(id: 0, labelName: "TestLabel", personalized: true)
        let labelIdInt64 = DatabaseHelper.shared.insertLabel(label: testLabel, userId: testUserId)
        testLabelId = Int(labelIdInt64)
        
        XCTAssertGreaterThan(testLabelId, 0, "Failed to create test label")
    }
    
    override func tearDown() {
        if testUserId > 0 {
            _ = DatabaseHelper.shared.deleteUserAndRelatedData(userId: testUserId)
        }
        
        bookController.clearLastScannedBook()
        bookController = nil
        super.tearDown()
    }
    
    func testLoadBooks() {
        // Load the user's books
        let books = bookController.loadBooks(userId: testUserId)
        
        // The list of verified books is not empty and contains the test books we created
        XCTAssertFalse(books.isEmpty, "Books list should not be empty")
        
        let foundTestBook = books.first { $0.BookId == testBookId }
        XCTAssertNotNil(foundTestBook, "Test book should be found in user's books")
        
        if let book = foundTestBook {
            XCTAssertEqual(book.ISBN, "9781234567897", "ISBN should match")
            XCTAssertEqual(book.bName, "Test Book", "Book name should match")
        }
    }
    
    func testGetBook() {
        // Get specific books
        if let book = bookController.getBook(bookId: testBookId) {
            XCTAssertEqual(book.BookId, testBookId, "Book ID should match")
            XCTAssertEqual(book.ISBN, "9781234567897", "ISBN should match")
            XCTAssertEqual(book.bName, "Test Book", "Book name should match")
        } else {
            XCTFail("Should be able to get the test book")
        }
    }
    
    func testAddAndRemoveBook() {
        // create new book
        let newBook = Book(
            UserId: testUserId,
            BookId: 0,
            ISBN: "9789876543210",
            bName: "New Test Book",
            Author: "Another Author",
            publisher: "Another Publisher",
            pDate: "2024",
            pPlace: "Another Place",
            price: 19.99,
            picture: "",
            description: "Another test description"
        )
        
        // add book
        let addSuccess = bookController.addBook(book: newBook)
        XCTAssertTrue(addSuccess, "Adding book should succeed")
        
        // Verify that the book was added
        let books = bookController.loadBooks(userId: testUserId)
        let foundNewBook = books.first { $0.ISBN == "9789876543210" }
        XCTAssertNotNil(foundNewBook, "New book should be found in user's books")
        
        if let book = foundNewBook {
            // Remove books
            let removeSuccess = bookController.removeBookFromUser(userId: testUserId, bookId: book.BookId)
            XCTAssertTrue(removeSuccess, "Removing book should succeed")
            
            let updatedBooks = bookController.loadBooks(userId: testUserId)
            let bookStillExists = updatedBooks.contains { $0.BookId == book.BookId }
            XCTAssertFalse(bookStillExists, "Book should be removed from user's books")
        }
    }
    
    func testLabelOperations() {
        // Add labels to books
        let addSuccess = bookController.addLabelToBook(bookId: testBookId, labelId: testLabelId, userId: testUserId)
        XCTAssertTrue(addSuccess, "Adding label to book should succeed")
        
        // get book labels
        let labels = bookController.getBookLabels(bookId: testBookId, userId: testUserId)
        XCTAssertFalse(labels.isEmpty, "Book should have labels")
        
        let foundLabel = labels.first { $0.id == testLabelId }
        XCTAssertNotNil(foundLabel, "Test label should be found in book's labels")
        
        if let label = foundLabel {
            XCTAssertEqual(label.labelName, "TestLabel", "Label name should match")
            
            // remove the label
            let removeSuccess = bookController.removeLabelFromBook(bookId: testBookId, labelId: testLabelId, userId: testUserId)
            XCTAssertTrue(removeSuccess, "Removing label from book should succeed")
            
            let updatedLabels = bookController.getBookLabels(bookId: testBookId, userId: testUserId)
            let labelStillExists = updatedLabels.contains { $0.id == testLabelId }
            XCTAssertFalse(labelStillExists, "Label should be removed from book")
        }
    }
    
    func testGetBooksWithLabel() {
        let addSuccess = bookController.addLabelToBook(bookId: testBookId, labelId: testLabelId, userId: testUserId)
        XCTAssertTrue(addSuccess, "Adding label to book should succeed")
        
        let books = bookController.getBooksWithLabel(labelId: testLabelId, userId: testUserId)
        XCTAssertFalse(books.isEmpty, "Should find books with the test label")
        
        let foundBook = books.first { $0.BookId == testBookId }
        XCTAssertNotNil(foundBook, "Test book should be found with the test label")
    }
    
    func testCreateLabelAndAddToBook() {
        let success = bookController.createLabelAndAddToBook(
            labelName: "NewTestLabel",
            personalized: true,
            userId: testUserId,
            bookId: testBookId
        )
        
        XCTAssertTrue(success, "Creating and adding label should succeed")
        
        let labels = bookController.getBookLabels(bookId: testBookId, userId: testUserId)
        let foundLabel = labels.first { $0.labelName == "NewTestLabel" }
        XCTAssertNotNil(foundLabel, "New label should be found in book's labels")
    }
    
    func testAddCustomLabel() {
        // add personalized label
        if let label = bookController.addCustomLabel(labelName: "CustomTestLabel", userId: testUserId) {
            XCTAssertEqual(label.labelName, "CustomTestLabel", "Label name should match")
            XCTAssertTrue(label.personalized, "Label should be personalized")
            
            let userLabels = bookController.getUserLabels(userId: testUserId)
            let foundLabel = userLabels.first { $0.labelName == "CustomTestLabel" }
            XCTAssertNotNil(foundLabel, "Custom label should be found in user's labels")
        } else {
            XCTFail("Adding custom label should succeed")
        }
    }
    
    func testGetAllAvailableLabels() {
        // Get all available labels (system labels and user labels)
        let allLabels = bookController.getAllAvailableLabels(userId: testUserId)
        
        XCTAssertFalse(allLabels.isEmpty, "Available labels should not be empty")
        
        let foundUserLabel = allLabels.first { $0.id == testLabelId }
        XCTAssertNotNil(foundUserLabel, "Test label should be found in available labels")
        
        let systemLabels = allLabels.filter { !$0.personalized }
        XCTAssertFalse(systemLabels.isEmpty, "System labels should be available")
    }
    
    func testLastScannedBook() {
        let scannedBook = Book(
            UserId: testUserId,
            BookId: testBookId,
            ISBN: "9781234567897",
            bName: "Scanned Book",
            Author: "Scanned Author",
            publisher: "Scanned Publisher",
            pDate: "2023",
            pPlace: "Scanned Place",
            price: 29.99,
            picture: "",
            description: "Scanned description"
        )
        
        // Save recently scanned books
        bookController.saveLastScannedBook(scannedBook)
        
        // Get recently scanned books
        if let retrievedBook = bookController.getLastScannedBook() {
            XCTAssertEqual(retrievedBook.ISBN, scannedBook.ISBN, "ISBN should match")
            XCTAssertEqual(retrievedBook.bName, scannedBook.bName, "Book name should match")
        } else {
            XCTFail("Should be able to retrieve last scanned book")
        }
 
        bookController.clearLastScannedBook()
        
        XCTAssertNil(bookController.getLastScannedBook(), "Last scanned book should be cleared")
    }
    
    func testAddBookIfNotExists() {
        let newBook = Book(
            UserId: testUserId,
            BookId: 0,
            ISBN: "9789876543210",
            bName: "Unique Book",
            Author: "Unique Author",
            publisher: "Unique Publisher",
            pDate: "2024",
            pPlace: "Unique Place",
            price: 19.99,
            picture: "",
            description: "Unique description"
        )
        
        // Add books that don't exist
        let addSuccess = bookController.addBookIfNotExists(newBook: newBook)
        XCTAssertTrue(addSuccess, "Adding new book should succeed")
        
        // Try adding the same book again
        let addAgainSuccess = bookController.addBookIfNotExists(newBook: newBook)
        XCTAssertFalse(addAgainSuccess, "Adding existing book should fail")
    }
    
    func testAddBookIfNotExistsWithId() {
        let newBook = Book(
            UserId: testUserId,
            BookId: 0,
            ISBN: "9789876543211",
            bName: "Another Unique Book",
            Author: "Another Unique Author",
            publisher: "Another Unique Publisher",
            pDate: "2024",
            pPlace: "Another Unique Place",
            price: 19.99,
            picture: "",
            description: "Another unique description"
        )
        
        // Add a book that doesn't exist and get an ID
        let (success, bookId) = bookController.addBookIfNotExistsWithId(newBook: newBook)
        XCTAssertTrue(success, "Adding new book should succeed")
        XCTAssertGreaterThan(bookId, 0, "Book ID should be positive")
        
        // Try adding the same book again
        let (addAgainSuccess, existingId) = bookController.addBookIfNotExistsWithId(newBook: newBook)
        XCTAssertFalse(addAgainSuccess, "Adding existing book should indicate it already exists")
        XCTAssertEqual(existingId, bookId, "Should return the existing book ID")
    }
    
    func testGetRecommendedBooks() {
        // Add labels to test books
        _ = bookController.addLabelToBook(bookId: testBookId, labelId: testLabelId, userId: testUserId)
        
        // Create another book with the same label
        let similarBook = Book(
            UserId: testUserId,
            BookId: 0,
            ISBN: "9789876543212",
            bName: "Similar Book",
            Author: "Similar Author",
            publisher: "Similar Publisher",
            pDate: "2024",
            pPlace: "Similar Place",
            price: 24.99,
            picture: "",
            description: "Similar description"
        )
        
        let similarBookId = Int(DatabaseHelper.shared.insertBook(book: similarBook))
        XCTAssertGreaterThan(similarBookId, 0, "Failed to create similar book")
        
        // Add the same tags for similar books
        _ = bookController.addLabelToBook(bookId: similarBookId, labelId: testLabelId, userId: testUserId)
        
        let recommendedBooks = bookController.getRecommendedBooks(forBook: testBookId, userId: testUserId)
        
        // Verify that the recommended book list contains similar books
        XCTAssertFalse(recommendedBooks.isEmpty, "Should find recommended books")
        
        let foundSimilarBook = recommendedBooks.first { $0.BookId == similarBookId }
        XCTAssertNotNil(foundSimilarBook, "Similar book should be recommended")
    }
}
