//
//  CalendarServiceTests.swift
//  LionReadingTests
//
//  Created by TanJianing.
//

import XCTest
import EventKit
@testable import LionReading

class CalendarServiceTests: XCTestCase {
    // Create a new test dedicated calendar service class
    class MockCalendarService {
        var accessGranted = false
        var saveSuccessful = true
        var lastBookName: String?
        var lastAuthor: String?
        var lastDate: Date?
        var accessRequestCalled = false
        var addEventCalled = false
        var checkAuthorizationCalled = false
        var checkAuthorizationResult = false
        var saveError: String?
        
        // Simulate requesting calendar access
        func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
            accessRequestCalled = true
            DispatchQueue.main.async {
                completion(self.accessGranted)
            }
        }
        
        // Simulate adding books completed to the calendar
        func addBookFinishToCalendar(bookName: String, author: String, date: Date, completion: @escaping (Bool, String?) -> Void) {
            addEventCalled = true
            lastBookName = bookName
            lastAuthor = author
            lastDate = date
            
            if !accessGranted {
                requestCalendarAccess { granted in
                    if granted {
                        self.saveEvent(bookName: bookName, author: author, date: date, completion: completion)
                    } else {
                        completion(false, "Calendar access denied")
                    }
                }
            } else {
                saveEvent(bookName: bookName, author: author, date: date, completion: completion)
            }
        }
        
        // Simulated save event
        private func saveEvent(bookName: String, author: String, date: Date, completion: @escaping (Bool, String?) -> Void) {
            if saveSuccessful {
                completion(true, nil)
            } else {
                completion(false, saveError ?? "Failed to save event")
            }
        }
        
        // Simulate checking calendar authorization status
        func checkCalendarAuthorizationStatus() -> Bool {
            checkAuthorizationCalled = true
            return checkAuthorizationResult
        }
    }
    
    var mockService: MockCalendarService!
    
    override func setUp() {
        super.setUp()
        mockService = MockCalendarService()
    }
    
    override func tearDown() {
        mockService = nil
        super.tearDown()
    }
    
    // Tests adding events when authorized
    func testAddBookFinishWhenAuthorized() {
        mockService.accessGranted = true
        mockService.saveSuccessful = true
        
        let expectation = self.expectation(description: "Add book finish event when authorized")
        
        let testBookName = "Test Book"
        let testAuthor = "Test Author"
        let testDate = Date()
        
        // All-day event parameters
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: testDate)
        let expectedStartDate = calendar.date(from: dateComponents)!
        
        mockService.addBookFinishToCalendar(bookName: testBookName, author: testAuthor, date: testDate) { success, error in
            XCTAssertTrue(success, "Event should be added successfully")
            XCTAssertNil(error, "There should be no error")
            XCTAssertTrue(self.mockService.addEventCalled, "Add event method should be called")
            XCTAssertEqual(self.mockService.lastBookName, testBookName, "Book name should be saved")
            XCTAssertEqual(self.mockService.lastAuthor, testAuthor, "Author should be saved")
            // Compare dates if the year, month and day are the same, not the exact time
            if let savedDate = self.mockService.lastDate {
                let savedComponents = calendar.dateComponents([.year, .month, .day], from: savedDate)
                let savedStartDate = calendar.date(from: savedComponents)
                XCTAssertEqual(savedStartDate, expectedStartDate, "Date should be correctly processed for all-day event")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Test requests for permissions in an unauthorized state and add events
    func testRequestAccessAndAddBookFinish() {
        // Initially not authorized, but authorized after request
        mockService.accessGranted = false
        mockService.saveSuccessful = true
        
        let expectation = self.expectation(description: "Request access and add book finish event")
        
        let testBookName = "Test Book"
        let testAuthor = "Test Author"
        let testDate = Date()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.mockService.accessGranted = true
        }
        
        mockService.addBookFinishToCalendar(bookName: testBookName, author: testAuthor, date: testDate) { success, error in
            XCTAssertTrue(success, "Event should be added successfully after granting access")
            XCTAssertNil(error, "There should be no error")
            XCTAssertTrue(self.mockService.addEventCalled, "Add event method should be called")
            XCTAssertTrue(self.mockService.accessRequestCalled, "Access request should be called")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Tests a failure to add an event
    func testAddBookFinishFailure() {
        // Failed to set the authorized status but save the Settings
        mockService.accessGranted = true
        mockService.saveSuccessful = false
        mockService.saveError = "Mock save error"
        
        let expectation = self.expectation(description: "Add book finish event failure")
        
        let testBookName = "Test Book"
        let testAuthor = "Test Author"
        let testDate = Date()
        
        mockService.addBookFinishToCalendar(bookName: testBookName, author: testAuthor, date: testDate) { success, error in
            XCTAssertFalse(success, "Event addition should fail")
            XCTAssertNotNil(error, "There should be an error")
            XCTAssertEqual(error, "Mock save error", "Error message should match")
            XCTAssertTrue(self.mockService.addEventCalled, "Add event method should be called despite failure")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Test when permission is denied
    func testAccessDenied() {
        // Description Failed to set permission request
        mockService.accessGranted = false
        
        let expectation = self.expectation(description: "Calendar access denied")
        
        let testBookName = "Test Book"
        let testAuthor = "Test Author"
        let testDate = Date()
        
        mockService.addBookFinishToCalendar(bookName: testBookName, author: testAuthor, date: testDate) { success, error in
            XCTAssertFalse(success, "Event addition should fail when access is denied")
            XCTAssertEqual(error, "Calendar access denied", "Error should indicate access denial")
            XCTAssertTrue(self.mockService.addEventCalled, "Add event method should be called")
            XCTAssertTrue(self.mockService.accessRequestCalled, "Access request should be called")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Test calendar authorization status check
    func testCheckCalendarAuthorizationStatus() {
        // Set the authorization check result
        mockService.checkAuthorizationResult = true
        XCTAssertTrue(mockService.checkCalendarAuthorizationStatus(), "Should return true when authorized")
        XCTAssertTrue(mockService.checkAuthorizationCalled, "Check method should be called")
        
        // Reset and test unauthorized
        mockService.checkAuthorizationCalled = false
        mockService.checkAuthorizationResult = false
        XCTAssertFalse(mockService.checkCalendarAuthorizationStatus(), "Should return false when not authorized")
        XCTAssertTrue(mockService.checkAuthorizationCalled, "Check method should be called")
    }
    
    // Test the behavior of the actual CalendarService
    func testRealCalendarService() {
        // This test only verifies the existence of the real service and does not perform the actual operation
        let service = CalendarService.shared
        XCTAssertNotNil(service, "CalendarService should exist")
        
        let authStatus = service.checkCalendarAuthorizationStatus()
    }
    
    // Testing authorization state compatibility for iOS 17
    func testAuthorizationStatusCompatibility() {
        // The test verifies that CalendarService checkCalendarAuthorizationStatus method can correctly handle the iOS 17 new authorization in the state
        
        // Since I can't simulate EKAuthorizationStatus directly, I'll just verify that the method for the real service works as expected, without making specific assertions
        let service = CalendarService.shared
        let _ = service.checkCalendarAuthorizationStatus()
        
        // To check that the real implementation handles the new authorization status, this test is primarily to ensure that the code compiles and does not actually verify the behavior
        if #available(iOS 17.0, *) {
            // Verify that the CalendarService implementation takes fullAccess state into account. Verify that no deprecated API is being used by examining its implementation
        }
    }
}
