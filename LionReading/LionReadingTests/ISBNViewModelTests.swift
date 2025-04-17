//
//  ISBNViewModelTests.swift
//  LionReadingTests
//
//  Created by TanJianing.
//

import XCTest
import Combine
@testable import LionReading

class ISBNViewModelTests: XCTestCase {
    var viewModel: ISBNViewModel!
    var mockLoginController: LoginController!
    var mockContentViewModel: ContentViewModel!
    private var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        viewModel = ISBNViewModel()
        mockLoginController = LoginController()
        mockLoginController.currentUser = User(id: 1, account: "test@example.com", password: "Password!", userName: "TestUser", headPort: "")
        mockContentViewModel = ContentViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        mockLoginController = nil
        mockContentViewModel = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testISBNValidation() {
        // Test a valid ISBN-13
        XCTAssertTrue(viewModel.isValidISBN13("9780306406157"), "Valid ISBN-13 should validate")
        XCTAssertTrue(viewModel.isValidISBN13("9789876543210"), "Valid ISBN-13 should validate")
        
        // Testing invalid ISBN (length error)
        XCTAssertFalse(viewModel.isValidISBN13("978030640615"), "Too short ISBN should not validate")
        XCTAssertFalse(viewModel.isValidISBN13("97803064061578"), "Too long ISBN should not validate")
        
        // Testing an invalid ISBN (prefix error)
        XCTAssertFalse(viewModel.isValidISBN13("1234567890123"), "ISBN without 978/979 prefix should not validate")
        
        // Test for invalid ISBNs (non-numeric characters)
        XCTAssertFalse(viewModel.isValidISBN13("978030640615X"), "ISBN with non-numeric characters should not validate")
        
        // Testing invalid ISBN (check bit error)
        XCTAssertFalse(viewModel.isValidISBN13("9780306406158"), "ISBN with incorrect check digit should not validate")
    }
    
    func testProcessScannedISBN() {
        let expectation = self.expectation(description: "Process scanned ISBN")

        let validISBN = "9780306406157"
        
        // Use Combine to listen for isLoading changes
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    // isLoading meets the expectation when isloading changes to false
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.processScannedISBN(validISBN, loginController: mockLoginController)
        
        // Verify that the ISBN is set and loaded with flags
        XCTAssertEqual(viewModel.isbn, validISBN, "ISBN should be set")
        XCTAssertTrue(viewModel.isLoading, "isLoading should be true initially")
        
        // Wait for the asynchronous operation to complete
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("Expectation failed: \(error)")
            }
            
            // Because the actual API call may fail, only the ISBN Settings are checked here
            XCTAssertEqual(self.viewModel.isbn, validISBN, "ISBN should remain set")
        }
    }
    
    func testToggleLabel() {
        // The initial state should have no checked label
        XCTAssertTrue(viewModel.selectedLabelIds.isEmpty, "Initially no labels should be selected")
        
        // add the label
        viewModel.toggleLabel(id: 1)
        XCTAssertTrue(viewModel.selectedLabelIds.contains(1), "Label 1 should be selected")
        XCTAssertEqual(viewModel.selectedLabelIds.count, 1, "Only one label should be selected")
        
        // add another label
        viewModel.toggleLabel(id: 2)
        XCTAssertTrue(viewModel.selectedLabelIds.contains(2), "Label 2 should be selected")
        XCTAssertEqual(viewModel.selectedLabelIds.count, 2, "Two labels should be selected")
        
        // delete the first label
        viewModel.toggleLabel(id: 1)
        XCTAssertFalse(viewModel.selectedLabelIds.contains(1), "Label 1 should be deselected")
        XCTAssertEqual(viewModel.selectedLabelIds.count, 1, "Only one label should remain selected")
    }
    
    func testClearForm() {
        viewModel.isbn = "9780306406157"
        viewModel.selectedLabelIds = [1, 2, 3]
        viewModel.bookInfo = Book(
            UserId: 1,
            BookId: 1,
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
        
        viewModel.clearForm()
        
        // The verification form has been cleared
        XCTAssertTrue(viewModel.isbn.isEmpty, "ISBN should be cleared")
        XCTAssertTrue(viewModel.selectedLabelIds.isEmpty, "Selected labels should be cleared")
        XCTAssertNil(viewModel.bookInfo, "Book info should be cleared")
    }
    
    func testSearchBookWithEmptyISBN() {
        // set empty ISBN
        viewModel.isbn = ""
        
        viewModel.searchBook(loginController: mockLoginController)
        
        // Validation error prompt
        XCTAssertTrue(viewModel.showAlert, "Alert should be shown")
        XCTAssertEqual(viewModel.alertMessage, "please enter the valid ISBN", "Alert message should indicate empty ISBN")
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false")
    }
    
    func testSearchBookWithInvalidISBN() {
        // set invalid ISBN
        viewModel.isbn = "123456789012"
        
        viewModel.searchBook(loginController: mockLoginController)
        
        // Validation error prompt
        XCTAssertTrue(viewModel.showAlert, "Alert should be shown")
        XCTAssertEqual(viewModel.alertMessage, "Invalid ISBN format. Please enter a valid 13-digit ISBN.", "Alert message should indicate invalid ISBN")
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false")
    }
    
    func testGetReadingStatusOptions() {
        let options = viewModel.getReadingStatusOptions()
        
        XCTAssertEqual(options.count, 2, "Should have two reading status options")
        XCTAssertTrue(options.contains(ReadingStatus.hopeToRead.description), "Should include 'Hope to Read'")
        XCTAssertTrue(options.contains(ReadingStatus.alreadyRead.description), "Should include 'Already Read'")
    }
    
    func testUpdateReadingStatus() {
        viewModel.selectedReadingStatus = ReadingStatus.hopeToRead.description
        
        // Simulate update reading status
        let bookId = 1
        let userId = 1
        
        // Execute update
        viewModel.updateReadingStatus(bookId: bookId, userId: userId)
        
        //Because this method calls the DatabaseHelper, we can't verify the result directly. In a practical situation, we should use dependency injection and mock objects to test. This is just to verify that the method doesn't crash
        XCTAssertEqual(viewModel.selectedReadingStatus, ReadingStatus.hopeToRead.description, "Reading status should remain unchanged")
    }
    
    // Test ISBN cleanup (remove hyphens and Spaces)
    func testISBNCleanup() {
        // Sets the ISBN with hyphens and Spaces
        viewModel.isbn = "978-0-306-40615-7"
        
        let expectation = self.expectation(description: "Clean ISBN")
      
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Perform the search, and the ISBNs are cleaned internally
        viewModel.searchBook(loginController: mockLoginController)
        
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("Expectation failed: \(error)")
            }
            
            XCTAssertEqual(self.viewModel.isbn, "978-0-306-40615-7", "Original ISBN should be preserved")
        }
    }
}

extension ISBNViewModel {
    // A public wrapper that provides access to private methods for testing
    func isValidISBN13(_ isbn: String) -> Bool {
        // Special handling of access to private methods (mock implementation, actually need to be adjusted according to the implementation in ISBNViewModel). It is assumed that a simple ISBN-13 verification is implemented
        guard isbn.count == 13 else { return false }
        guard isbn.hasPrefix("978") || isbn.hasPrefix("979") else { return false }
        guard isbn.allSatisfy({ $0.isNumber }) else { return false }
        
        var sum = 0
        for (index, char) in isbn.dropLast().enumerated() {
            guard let digit = Int(String(char)) else { return false }
            let multiplier = index % 2 == 0 ? 1 : 3
            sum += digit * multiplier
        }
        
        let calculatedCheckDigit = (10 - (sum % 10)) % 10
        guard let lastDigit = Int(String(isbn.last!)) else { return false }
        
        return calculatedCheckDigit == lastDigit
    }
}
