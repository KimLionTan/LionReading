//
//  ISBNViewModel.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI
import Combine

class ISBNViewModel: ObservableObject {
    @Published var isbn: String = ""
    @Published var customLabel: String = ""
    @Published var showingCustomLabelInput = false
    @Published var bookInfo: Book?
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var availableLabels: [Label] = []
    @Published var selectedLabelIds: Set<Int> = []
    @Published var selectedReadingStatus: String = ReadingStatus.hopeToRead.description
    @Published var finishDate: Date = Date()
    @Published var showDatePicker: Bool = false
    @Published var shouldAddToCalendar: Bool = false
    @Published var calendarAlertMessage: String = ""
    @Published var showCalendarAlert: Bool = false

    init(initialISBN: String = "", autoSearch: Bool = false) {
        self.isbn = initialISBN
        self.isLoading = autoSearch
    }
    
    // MARK: - Public methods
    
    func onAppear(loginController: LoginController) {
        loadAvailableLabels(loginController: loginController)
        
        if !isbn.isEmpty && isLoading {
            searchBook(loginController: loginController)
        }
        // Check if there are ISBNs from UserDefaults (as backups)
        else if isbn.isEmpty && bookInfo == nil {
            if let savedISBN = UserDefaults.standard.string(forKey: "lastScannedISBN") {
                isbn = savedISBN
                isLoading = true
                searchBook(loginController: loginController)
                
                UserDefaults.standard.removeObject(forKey: "lastScannedISBN")
            }
        }
    }
    
    func processScannedISBN(_ isbn: String, loginController: LoginController) {
        self.isbn = isbn
        self.isLoading = true
        self.searchBook(loginController: loginController)
    }
    
    func toggleLabel(id: Int) {
        if selectedLabelIds.contains(id) {
            selectedLabelIds.remove(id)
        } else {
            selectedLabelIds.insert(id)
        }
    }
    
    func searchBook(loginController: LoginController) {
        guard !isbn.isEmpty else {
            alertMessage = "please enter the valid ISBN"
            showAlert = true
            isLoading = false
            return
        }
        
        // Clean up possible hyphens or Spaces in ISBNs
        let cleanISBN = isbn.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "")
        
        guard isValidISBN13(cleanISBN) else {
            alertMessage = "Invalid ISBN format. Please enter a valid 13-digit ISBN."
            showAlert = true
            isLoading = false
            return
        }
        
        isLoading = true
        BookAPIService.fetchBookByISBN(isbn: cleanISBN) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let book):
                    var updatedBook = book
                    updatedBook.UserId = loginController.currentUser.id
                    self.bookInfo = updatedBook
                    
                case .failure(let error):
                    self.alertMessage = "Fail to find the book: \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
        }
    }

    // Verify the 13-bit ISBN
    private func isValidISBN13(_ isbn: String) -> Bool {
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
    
    func createNewLabel(loginController: LoginController) {
        guard !customLabel.isEmpty else { return }
        
        guard loginController.currentUser.id > 0 else {
            alertMessage = "Please Login"
            showAlert = true
            return
        }
        
        if availableLabels.contains(where: { $0.labelName.lowercased() == customLabel.lowercased() }) {
            alertMessage = "Label exists"
            showAlert = true
            return
        }
        
        let dbHelper = DatabaseHelper.shared
        
        let newLabel = Label(
            id: 0,
            labelName: customLabel,
            personalized: true
        )
        
        let newLabelId = dbHelper.insertLabel(label: newLabel, userId: loginController.currentUser.id)
        
        if newLabelId > 0 {
            let insertedLabel = Label(
                id: Int(newLabelId),
                labelName: customLabel,
                personalized: true
            )
            
            availableLabels.append(insertedLabel)
            selectedLabelIds.insert(Int(newLabelId)) // Select the newly created label
            customLabel = ""
            showingCustomLabelInput = false
        } else {
            alertMessage = "Fail to create"
            showAlert = true
        }
    }
  
    func saveLabelsToBook(bookId: Int, userId: Int) {
        let dbHelper = DatabaseHelper.shared
        var allLabelsAdded = true
        
        for labelId in selectedLabelIds {
            if !dbHelper.addLabelToBook(bookId: bookId, labelId: labelId, userId: userId) {
                allLabelsAdded = false
            }
        }
        
        if !allLabelsAdded {
            print("Warning: Some labels failed to be added")
        }
    }
    
    func saveBook(loginController: LoginController, contentViewModel: ContentViewModel) {
        guard let book = bookInfo else {
            alertMessage = "No information"
            showAlert = true
            return
        }
        
        if loginController.currentUser.id == 0 {
            alertMessage = "Login please"
            showAlert = true
            return
        }
        
        guard !selectedLabelIds.isEmpty else {
            alertMessage = "Please select at least one label"
            showAlert = true
            return
        }
        
        // Use BookController to add books
        _ = BookController.shared
        var bookToSave = book
        bookToSave.UserId = loginController.currentUser.id
        let dbHelper = DatabaseHelper.shared
        let bookId: Int64

        if let existingBook = dbHelper.getBookByISBN(isbn: bookToSave.ISBN, userId: loginController.currentUser.id) {
            bookId = Int64(existingBook.BookId)
            alertMessage = "《\(bookToSave.bName)》already exists, adding label"
            showAlert = true
        } else {
            bookId = dbHelper.insertBook(book: bookToSave)
            if bookId <= 0 {
                alertMessage = "Failed to add book"
                showAlert = true
                return
            }
        }
        
        // save book state
        if let status = ReadingStatus.fromString(selectedReadingStatus) {
            let finishDateToSave = status == .alreadyRead ? finishDate : nil
            let success = dbHelper.setBookReadingStatus(
                bookId: Int(bookId),
                userId: loginController.currentUser.id,
                status: status,
                finishDate: finishDateToSave
            )
            print("Status saved: \(success), Date: \(finishDateToSave?.description ?? "nil")")
            
            if let status = ReadingStatus.fromString(selectedReadingStatus),
               status == .alreadyRead,
               let date = finishDateToSave {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self else { return }
                    self.shouldAddToCalendar = true
                }
            }
        }
        
        
        var allLabelsAdded = true
        
        for labelId in selectedLabelIds {
            print("Add label ID: \(labelId) for book ID: \(bookId)")
            if !dbHelper.addLabelToBook(bookId: Int(bookId), labelId: labelId, userId: loginController.currentUser.id) {
                allLabelsAdded = false
                print("Label \(labelId) fail to be added")
            }
        }
        
        // refresh the shelf
        contentViewModel.loadBooks()
        
        if allLabelsAdded {
            alertMessage = "《\(bookToSave.bName)》has been added and associated with all selected labels"
        } else {
            alertMessage = "《\(bookToSave.bName)》has been added, but some label association failed"
        }
        
        showAlert = true
        
        // Clear the current data and prepare to add the next one
        bookInfo = nil
        isbn = ""
        selectedLabelIds.removeAll()
    }
    
    func clearForm() {
        bookInfo = nil
        isbn = ""
        selectedLabelIds.removeAll()
    }
    
    func updateReadingStatus(bookId: Int, userId: Int) {
        if let status = ReadingStatus.fromString(selectedReadingStatus) {
            let finishDateToSave = status == .alreadyRead ? finishDate : nil
            DatabaseHelper.shared.setBookReadingStatus(
                bookId: bookId,
                userId: userId,
                status: status,
                finishDate: finishDateToSave
            )
        }
    }
    
    func loadReadingStatus(bookId: Int, userId: Int) {
        let result = DatabaseHelper.shared.getBookReadingStatus(bookId: bookId, userId: userId)
        selectedReadingStatus = result.status.description

        if result.status == .alreadyRead {
            finishDate = result.finishDate ?? Date()
        }
    }
    
    func addBookToCalendar(bookName: String, author: String, date: Date) {
        CalendarService.shared.addBookFinishToCalendar(
            bookName: bookName,
            author: author,
            date: date
        ) { [weak self] success, errorMessage in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    self.calendarAlertMessage = "Add《\(bookName)》in your calendar successfully"
                } else {
                    self.calendarAlertMessage = errorMessage ?? "Fail to add the book in your calendar"
                }
                self.showCalendarAlert = true
            }
        }
    }

    func getReadingStatusOptions() -> [String] {
        return [ReadingStatus.hopeToRead.description, ReadingStatus.alreadyRead.description]
    }
    
    // MARK: - Private methods
    
    private func loadAvailableLabels(loginController: LoginController) {
        guard loginController.currentUser.id > 0 else {
            return
        }
        
        let dbHelper = DatabaseHelper.shared
        let systemLabels = dbHelper.getSystemLabels()
        let userLabels = dbHelper.getUserLabels(userId: loginController.currentUser.id)
        
        // Merge labels and make sure they don't duplicate
        availableLabels = systemLabels
        for label in userLabels {
            if !availableLabels.contains(where: { $0.id == label.id }) {
                availableLabels.append(label)
            }
        }
        
        if availableLabels.isEmpty {
            dbHelper.ensureSystemLabelsExist()
            availableLabels = dbHelper.getSystemLabels()
        }
        
        if !availableLabels.isEmpty && selectedLabelIds.isEmpty {
            selectedLabelIds.insert(availableLabels[0].id)
        }
    }
}
