//
//  BookDetailViewModel.swift
//  LionReading
//
//  Created by TanJianing.
//

import Foundation
import SwiftUI
import Combine

class BookDetailViewModel: ObservableObject {
    let book: Book
    @Published var labels: [Label] = []
    @Published var isEditingLabels = false
    @Published var showAddLabel = false
    @Published var showDeleteAlert = false
    @Published var labelToDelete: Label?
    @Published var recommendedBooks: [Book] = []
    @Published var readingStatus: ReadingStatus = .hopeToRead
    @Published var finishDate: Date?
    @Published var showDatePicker: Bool = false
    @Published var showCalendarAlert: Bool = false
    @Published var calendarAlertMessage: String = ""
    @Published var shouldAddToCalendar: Bool = false

    
    private let bookController = BookController.shared
    private let dbHelper = DatabaseHelper.shared
    
    init(book: Book) {
        self.book = book
        loadBookLabels()
        loadRecommendedBooks()
        loadReadingStatus()
    }
    
    // MARK: - Public methods
    
    func loadBookLabels() {
        dbHelper.checkBookLabelAssociations(bookId: book.BookId)
        
        self.labels = dbHelper.getBookLabels(bookId: book.BookId, userId: book.UserId)
        
        print("Loaded \(self.labels.count) tags for the BookId \(book.BookId)")
    }
    
    func toggleEditMode() {
        isEditingLabels.toggle()
    }
    
    func removeLabel(_ label: Label) {
        let success = dbHelper.removeLabelFromBook(
            bookId: book.BookId,
            labelId: label.id,
            userId: book.UserId
        )
        
        if success {
            loadBookLabels()
        }
    }
    
    func addLabel(name: String) {
        let success = bookController.createLabelAndAddToBook(
            labelName: name,
            personalized: true,
            userId: book.UserId,
            bookId: book.BookId
        )
        
        if success {
            loadBookLabels()
        }
    }
    
    func prepareLabelForDeletion(_ label: Label) {
        self.labelToDelete = label
        self.showDeleteAlert = true
    }
    
    func loadRecommendedBooks() {
        print("Start loading recommended books")
        let bookController = BookController.shared
        recommendedBooks = bookController.getRecommendedBooks(forBook: book.BookId, userId: book.UserId)
        print("Recommended books loading completed, number: \(recommendedBooks.count)")
        for (index, book) in recommendedBooks.enumerated() {
            print("Recommend Book #\(index+1): \(book.bName) (ID: \(book.BookId))")
        }
    }
    
    func loadReadingStatus() {
        let result = DatabaseHelper.shared.getBookReadingStatus(
            bookId: book.BookId,
            userId: book.UserId
        )
        print("""
        Loading reading status for book \(book.BookId):
        - Status: \(result.status)
        - Finish Date: \(result.finishDate?.description ?? "nil")
        """)
        
        readingStatus = result.status
        finishDate = result.finishDate

        if readingStatus == .alreadyRead && finishDate == nil {
            finishDate = Date()
            print("Setting default finish date for already read book")
        }
    }
    
    func toggleReadingStatus() {
        let newStatus: ReadingStatus = readingStatus == .hopeToRead ? .alreadyRead : .hopeToRead
        let dateToSave = newStatus == .alreadyRead ? (finishDate ?? Date()) : nil
        
        print("""
        Toggling reading status for book \(book.BookId):
        - From: \(readingStatus)
        - To: \(newStatus)
        - Date: \(dateToSave?.description ?? "nil")
        """)
        
        if newStatus == .alreadyRead && readingStatus == .hopeToRead {
            // 当状态从"想读"变为"已读"时，提示是否添加到日历
            shouldAddToCalendar = true
        }
        
        let success = DatabaseHelper.shared.setBookReadingStatus(
            bookId: book.BookId,
            userId: book.UserId,
            status: newStatus,
            finishDate: dateToSave
        )
        
        if success {
            print("Status update successful")
            readingStatus = newStatus
            finishDate = dateToSave
            showDatePicker = newStatus == .alreadyRead
        } else {
            print("Failed to update reading status")
        }
    }
    
    func addBookToCalendar() {
        guard let date = finishDate else {
            calendarAlertMessage = "Can't add to the calendar as the finished date isn't set now"
            showCalendarAlert = true
            return
        }
        
        CalendarService.shared.addBookFinishToCalendar(
            bookName: book.bName,
            author: book.Author,
            date: date
        ) { [weak self] success, errorMessage in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    self.calendarAlertMessage = "Add 《\(self.book.bName)》to the calendar successfully"
                } else {
                    self.calendarAlertMessage = errorMessage ?? "Fail to add to the calendar"
                }
                self.showCalendarAlert = true
            }
        }
    }
    
    func checkCalendarPermission() -> Bool {
        return CalendarService.shared.checkCalendarAuthorizationStatus()
    }
}
