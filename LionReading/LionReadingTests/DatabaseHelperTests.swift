//
//  DatabaseHelperTests.swift
//  LionReadingTests
//
//  Created by TanJianing.
//

import XCTest
@testable import LionReading

class DatabaseHelperTests: XCTestCase {
    var testDBHelper: DatabaseHelper!
    
    override func setUp() {
        super.setUp()
        // Create a test instance that uses an in-memory database to avoid affecting the actual data
        testDBHelper = DatabaseHelper.shared
        cleanupTestData()
    }
    
    override func tearDown() {
        // Clean test data
        cleanupTestData()
        super.tearDown()
    }
    
    private func cleanupTestData() {
        // Delete all test created users
        let testUsers = testDBHelper.getUserByAccount(account: "test@example.com")
        if let user = testUsers {
            _ = testDBHelper.deleteUserAndRelatedData(userId: user.id)
        }
    }
    
    func testUserCreationAndRetrieval() {
        let testUser = User(id: 0, account: "test@example.com", password: "Password123!", userName: "TestUser", headPort: "")
        let userId = Int(testDBHelper.addUser(user: testUser))
        XCTAssertGreaterThan(userId, 0, "User ID should be positive after successful creation")
        
        if let retrievedUser = testDBHelper.getUser(byId: userId) {
            XCTAssertEqual(retrievedUser.account, testUser.account)
            XCTAssertEqual(retrievedUser.userName, testUser.userName)
        } else {
            XCTFail("Failed to retrieve created user")
        }
    }
    
    func testUserUpdate() {
        // Create a test user
        let testUser = User(id: 0, account: "test@example.com", password: "Password123!", userName: "TestUser", headPort: "")
        let userId = Int(testDBHelper.addUser(user: testUser))
        
        // The user is successfully created
        guard userId > 0, var userToUpdate = testDBHelper.getUser(byId: userId) else {
            XCTFail("Failed to create test user")
            return
        }
        
        // update information
        let newUserName = "UpdatedName"
        userToUpdate = userToUpdate.withUpdatedUserName(newUserName)
        let updateSuccess = testDBHelper.updateUser(user: userToUpdate)
        
        XCTAssertTrue(updateSuccess, "User update should succeed")
        
        // Verify that the update was saved successfully
        if let updatedUser = testDBHelper.getUser(byId: userId) {
            XCTAssertEqual(updatedUser.userName, newUserName, "User name should be updated")
            XCTAssertEqual(updatedUser.account, testUser.account, "Account should remain unchanged")
        } else {
            XCTFail("Failed to retrieve updated user")
        }
    }
    
    func testUserDeletion() {
        // Create a test user
        let testUser = User(id: 0, account: "test@example.com", password: "Password123!", userName: "TestUser", headPort: "")
        let userId = Int(testDBHelper.addUser(user: testUser))
        
        // The user is successfully created
        guard userId > 0 else {
            XCTFail("Failed to create test user")
            return
        }
        
        // Delete the user
        let deleteSuccess = testDBHelper.deleteUserAndRelatedData(userId: userId)
        XCTAssertTrue(deleteSuccess, "User deletion should succeed")
        
        // Verify that the user is indeed deleted
        let retrievedUser = testDBHelper.getUser(byId: userId)
        XCTAssertNil(retrievedUser, "User should be deleted")
    }
    
    func testBookOperations() {
        // Create a test user
        let testUser = User(id: 0, account: "test@example.com", password: "Password123!", userName: "TestUser", headPort: "")
        let userId = Int(testDBHelper.addUser(user: testUser))
        
        // The user is successfully created
        guard userId > 0 else {
            XCTFail("Failed to create test user")
            return
        }
        
        // Create a test book
        let testBook = Book(
            UserId: userId,
            BookId: 0,
            ISBN: "9780306406157",
            bName: "Test Book",
            Author: "Test Author",
            publisher: "Test Publisher",
            pDate: "2023",
            pPlace: "Test Place",
            price: 29.99,
            picture: "",
            description: "Test description"
        )
        
        let bookId = Int(testDBHelper.insertBook(book: testBook))
        XCTAssertGreaterThan(bookId, 0, "Book ID should be positive after successful creation")
        
        // Verified book search
        if let retrievedBook = testDBHelper.getBook(byId: bookId) {
            XCTAssertEqual(retrievedBook.ISBN, testBook.ISBN)
            XCTAssertEqual(retrievedBook.bName, testBook.bName)
            XCTAssertEqual(retrievedBook.Author, testBook.Author)
        } else {
            XCTFail("Failed to retrieve created book")
        }
        
        // The test gets all the user's books
        let userBooks = testDBHelper.getUserBooks(userId: userId)
        XCTAssertFalse(userBooks.isEmpty, "User should have books")
        XCTAssertEqual(userBooks.first?.ISBN, testBook.ISBN, "Retrieved book should match test book")
        
        // Test delete book
        let removeSuccess = testDBHelper.removeBookFromUser(userId: userId, bookId: bookId)
        XCTAssertTrue(removeSuccess, "Book removal should succeed")
        
        // Verify that the book has been deleted
        let updatedUserBooks = testDBHelper.getUserBooks(userId: userId)
        XCTAssertTrue(updatedUserBooks.isEmpty, "User should have no books after removal")
    }
    
    func testLabelOperations() {
        //Create a test user
        let testUser = User(id: 0, account: "test@example.com", password: "Password123!", userName: "TestUser", headPort: "")
        let userId = Int(testDBHelper.addUser(user: testUser))
        
        //The user is successfully created
        guard userId > 0 else {
            XCTFail("Failed to create test user")
            return
        }
        
        // Create test tags
        let testLabel = Label(id: 0, labelName: "Test Label", personalized: true)
        let labelId = Int(testDBHelper.insertLabel(label: testLabel, userId: userId))
        XCTAssertGreaterThan(labelId, 0, "Label ID should be positive after successful creation")
        
        // Validation tag retrieval
        let userLabels = testDBHelper.getUserLabels(userId: userId)
        XCTAssertFalse(userLabels.isEmpty, "User should have labels")
        XCTAssertEqual(userLabels.first?.labelName, testLabel.labelName, "Retrieved label should match test label")
        
        // Test update tag name
        let newLabelName = "Updated Label"
        let updateSuccess = testDBHelper.updateLabelName(id: labelId, newName: newLabelName, userId: userId)
        XCTAssertTrue(updateSuccess, "Label update should succeed")
        
        // The verification label has been updated
        let updatedLabels = testDBHelper.getUserLabels(userId: userId)
        XCTAssertEqual(updatedLabels.first?.labelName, newLabelName, "Label name should be updated")
        
        // Test delete tag
        let deleteSuccess = testDBHelper.deleteLabel(id: labelId, userId: userId)
        XCTAssertTrue(deleteSuccess, "Label deletion should succeed")
        
        // Verification label removed
        let remainingLabels = testDBHelper.getUserLabels(userId: userId).filter { $0.id == labelId }
        XCTAssertTrue(remainingLabels.isEmpty, "Label should be deleted")
    }
    
    func testReadingStatusOperations() {
        // Create a test user
        let testUser = User(id: 0, account: "test@example.com", password: "Password123!", userName: "TestUser", headPort: "")
        let userId = Int(testDBHelper.addUser(user: testUser))
        
        // Create a test book
        let testBook = Book(
            UserId: userId,
            BookId: 0,
            ISBN: "9780306406157",
            bName: "Test Book",
            Author: "Test Author",
            publisher: "Test Publisher",
            pDate: "2023",
            pPlace: "Test Place",
            price: 29.99,
            picture: "",
            description: "Test description"
        )
        
        let bookId = Int(testDBHelper.insertBook(book: testBook))
        
        // Ensure successful user and book creation
        guard userId > 0 && bookId > 0 else {
            XCTFail("Failed to create test user or book")
            return
        }
        
        // The test is set to want to read
        let setHopeSuccess = testDBHelper.setBookReadingStatus(bookId: bookId, userId: userId, status: .hopeToRead)
        XCTAssertTrue(setHopeSuccess, "Setting hope to read status should succeed")
        
        // The verification status is set
        let hopeStatus = testDBHelper.getBookReadingStatus(bookId: bookId, userId: userId)
        XCTAssertEqual(hopeStatus.status, .hopeToRead, "Reading status should be hope to read")
        
        // The test is set to read, with a completion date
        let finishDate = Date()
        let setReadSuccess = testDBHelper.setBookReadingStatus(bookId: bookId, userId: userId, status: .alreadyRead, finishDate: finishDate)
        XCTAssertTrue(setReadSuccess, "Setting already read status should succeed")
        
        // Validation status and date are set
        let readStatus = testDBHelper.getBookReadingStatus(bookId: bookId, userId: userId)
        XCTAssertEqual(readStatus.status, .alreadyRead, "Reading status should be already read")
        XCTAssertNotNil(readStatus.finishDate, "Finish date should be set")
        
        // Format dates for comparison, as second-level accuracy can cause direct comparisons to fail
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let expectedDateString = formatter.string(from: finishDate)
        let actualDateString = formatter.string(from: readStatus.finishDate!)
        
        XCTAssertEqual(actualDateString, expectedDateString, "Stored finish date should match the set date")
        
        // Tests get books in a specific state
        let readBooks = testDBHelper.getUserReadBooks(userId: userId)
        XCTAssertFalse(readBooks.isEmpty, "User should have read books")
        XCTAssertEqual(readBooks.first?.BookId, bookId, "Retrieved book should match test book")
        
        // The test switches back to the desired read state, confirming that the date is cleared
        let resetSuccess = testDBHelper.setBookReadingStatus(bookId: bookId, userId: userId, status: .hopeToRead)
        XCTAssertTrue(resetSuccess, "Resetting to hope read status should succeed")
        
        let resetStatus = testDBHelper.getBookReadingStatus(bookId: bookId, userId: userId)
        XCTAssertEqual(resetStatus.status, .hopeToRead, "Reading status should be reset to hope to read")
        XCTAssertNil(resetStatus.finishDate, "Finish date should be cleared")
    }
}
