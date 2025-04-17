//
//  BookController.swift
//  LionReading
//
//  Created by TanJianing.
//

import Foundation

class BookController: ObservableObject {
    private let dbHelper = DatabaseHelper.shared
    private let lastScannedBookKey = "lastScannedBook"
    
    static let shared = BookController()
    
    func loadBooks(userId: Int) -> [Book] {
        return dbHelper.getUserBooks(userId: userId)
    }
    
    func addBook(book: Book) -> Bool {
        let bookId = dbHelper.insertBook(book: book)
        return bookId > 0
    }
    
    func getBook(bookId: Int) -> Book? {
        return dbHelper.getBook(byId: bookId)
    }
    
    func removeBookFromUser(userId: Int, bookId: Int) -> Bool {
        return dbHelper.removeBookFromUser(userId: userId, bookId: bookId)
    }
    
    func getBooksWithLabel(labelId: Int, userId: Int) -> [Book] {
        return dbHelper.getBooksWithLabel(labelId: labelId, userId: userId)
    }
    
    func getBookLabels(bookId: Int, userId: Int) -> [Label] {
        return dbHelper.getBookLabels(bookId: bookId, userId: userId)
    }
    
    func addLabelToBook(bookId: Int, labelId: Int, userId: Int) -> Bool {
        return dbHelper.addLabelToBook(bookId: bookId, labelId: labelId, userId: userId)
    }
    
    func addBookIfNotExistsWithId(newBook: Book) -> (Bool, Int) {
        let dbHelper = DatabaseHelper.shared
       
        if let existingBook = dbHelper.getBookByISBN(isbn: newBook.ISBN, userId: newBook.UserId) {
            return (false, existingBook.BookId)
        }
       
        let bookId = dbHelper.insertBook(book: newBook)
        return (bookId > 0, Int(bookId))
    }
    
    func removeLabelFromBook(bookId: Int, labelId: Int, userId: Int) -> Bool {
        return dbHelper.removeLabelFromBook(bookId: bookId, labelId: labelId, userId: userId)
    }
    
    func saveLastScannedBook(_ book: Book) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(book)
            UserDefaults.standard.set(data, forKey: lastScannedBookKey)
        } catch {
            print("Failed to save scanned book: \(error.localizedDescription)")
        }
    }
    
    func getLastScannedBook() -> Book? {
        guard let scannedBook = UserDefaults.standard.data(forKey: lastScannedBookKey) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let book = try decoder.decode(Book.self, from: scannedBook)
            return book
        } catch {
            print("Failed to decode scanned book: \(error.localizedDescription)")
            return nil
        }
    }
    
    func clearLastScannedBook() {
        UserDefaults.standard.removeObject(forKey: lastScannedBookKey)
    }
    
    func addBookIfNotExists(newBook: Book) -> Bool {
        let userBooks = dbHelper.getUserBooks(userId: newBook.UserId)
    
        if userBooks.contains(where: { $0.ISBN == newBook.ISBN }) {
            return false
        }
        let bookId = dbHelper.insertBook(book: newBook)
        return bookId > 0
    }
    
    func createLabelAndAddToBook(labelName: String, personalized: Bool, userId: Int, bookId: Int) -> Bool {
        let dbHelper = DatabaseHelper.shared
        
        if let existingLabel = dbHelper.getLabelByName(name: labelName) {
            return dbHelper.addLabelToBook(bookId: bookId, labelId: existingLabel.id, userId: userId)
        } else {
            let newLabel = Label(id: 0, labelName: labelName, personalized: personalized)
            let labelId = dbHelper.insertLabel(label: newLabel, userId: userId)
            
            if labelId > 0 {
                return dbHelper.addLabelToBook(bookId: bookId, labelId: Int(labelId), userId: userId)
            }
        }
        
        return false
    }

    func getAllAvailableLabels(userId: Int) -> [Label] {
        return dbHelper.getAllAvailableLabels(userId: userId)
    }

    func getSystemLabels() -> [Label] {
        return dbHelper.getSystemLabels()
    }

    func getUserLabels(userId: Int) -> [Label] {
        return dbHelper.getUserLabels(userId: userId)
    }

    func addCustomLabel(labelName: String, userId: Int) -> Label? {
        if dbHelper.labelExists(name: labelName) {
            return nil
        }
        
        let label = Label(id: 0, labelName: labelName, personalized: true)
        let labelId = dbHelper.insertLabel(label: label, userId: userId)
        
        if labelId > 0 {
            return Label(id: Int(labelId), labelName: labelName, personalized: true)
        }
        
        return nil
    }
    
    func getRecommendedBooks(forBook bookId: Int, userId: Int) -> [Book] {
        return dbHelper.getBooksWithSimilarLabels(bookId: bookId, userId: userId)
    }
}
