//
//  ContentViewModel.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    @Published var myBooks: [Book] = []
    @Published var showScanner = false
    @Published var alertMessage = ""
    @Published var showAlert = false
    
    private let bookController: BookController
    private var currentUserId: Int = 0
    
    init(bookController: BookController = BookController.shared, userId: Int = 0) {
        self.bookController = bookController
        self.currentUserId = userId
        loadBooks()
    }
    
    func setUser(userId: Int) {
        self.currentUserId = userId
        loadBooks()
    }

    func loadBooks() {
        if currentUserId > 0 {
            myBooks = bookController.loadBooks(userId: currentUserId)
        } else {
            myBooks = []
        }
    }
    
    func checkForNewBooks() {
        guard let newBook = bookController.getLastScannedBook() else { return }
        
        var bookToAdd = newBook
        bookToAdd.UserId = currentUserId
        
        if bookController.addBookIfNotExists(newBook: bookToAdd) {
            loadBooks()
            alertMessage = "New Book 《\(bookToAdd.bName)》is added"
        } else {
            alertMessage = "You have already had the book《\(bookToAdd.bName)》"
        }
        showAlert = true
        
        bookController.clearLastScannedBook()
    }
    
    // Removes books from the user's shelf
    func removeBook(at indexSet: IndexSet) {
        guard currentUserId > 0 else { return }
        
        // Converts the index to an array of book ids
        let booksToRemove = indexSet.map { myBooks[$0] }
        
        for book in booksToRemove {
            _ = bookController.removeBookFromUser(userId: currentUserId, bookId: book.BookId)
        }

        loadBooks()
    }
    
    func addLabelToBook(bookId: Int, labelName: String, personalized: Bool = true) -> Bool {
        guard currentUserId > 0 else { return false }
        
        return bookController.createLabelAndAddToBook(
            labelName: labelName,
            personalized: personalized,
            userId: currentUserId,
            bookId: bookId
        )
    }
    
    func getBookLabels(bookId: Int) -> [Label] {
        guard currentUserId > 0 else { return [] }
        
        return bookController.getBookLabels(bookId: bookId, userId: currentUserId)
    }
}
