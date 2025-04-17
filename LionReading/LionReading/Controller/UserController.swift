//
//  UserController.swift
//  LionReading
//
//  Created by TanJianing
//

import Foundation
import SwiftUI
import Combine

class UserController: ObservableObject {
    private let dbHelper = DatabaseHelper.shared
    
    // The current user object that holds the original data
    private var currentUser: User?
    
    // A state variable bound to a view
    @Published var userName: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var updateSuccessful: Bool = false
    @Published var userLabels: [Label] = []

    init() {}
    
    // Convenient initializer that accepts direct initialization with user parameters
    convenience init(user: User) {
        self.init()
        loadUser(user)
    }
    
    // Loading user data
    func loadUser(_ user: User) {
        self.currentUser = user
        self.userName = user.userName
        self.password = ""
        self.confirmPassword = ""

        loadUserLabels()
    }
    
    func validateInputs() -> Bool {
        if userName.isEmpty {
            alertMessage = "Username can't be empty"
            showAlert = true
            return false
        }
        
        if !password.isEmpty {
            if password != confirmPassword {
                alertMessage = "Passwords do not match"
                showAlert = true
                return false
            }
            
            if !isValidPassword(password) {
                alertMessage = "Password must be at least 8 characters long and include uppercase letters, lowercase letters, and special symbols (e.g., !)"
                showAlert = true
                return false
            }
        }
        
        return true
    }

    private func isValidPassword(_ password: String) -> Bool {
        if password.count < 8 {
            return false
        }
        
        let uppercaseLetterRegex = ".*[A-Z]+.*"
        if password.range(of: uppercaseLetterRegex, options: .regularExpression) == nil {
            return false
        }
        
        let lowercaseLetterRegex = ".*[a-z]+.*"
        if password.range(of: lowercaseLetterRegex, options: .regularExpression) == nil {
            return false
        }
       
        let specialCharacterRegex = ".*[!@#$%^&*()_+-=\\[\\]{}|;:,.<>?/~`]+.*"
        if password.range(of: specialCharacterRegex, options: .regularExpression) == nil {
            return false
        }
        
        return true
    }
    
    func saveUser() {
        if !validateInputs() {
            return
        }
        
        guard let user = currentUser else {
            alertMessage = "Error: No user loaded"
            showAlert = true
            return
        }
        
        // Create the updated user object using the withUpdated method
        var updatedUser = user
        
        if userName != user.userName {
            updatedUser = updatedUser.withUpdatedUserName(userName)
        }
        
        if !password.isEmpty {
            updatedUser = User(
                id: updatedUser.id,
                account: updatedUser.account,
                password: password,
                userName: updatedUser.userName,
                headPort: updatedUser.headPort
            )
        }
        
        // Update database
        if dbHelper.updateUser(user: updatedUser) {
            currentUser = updatedUser
            alertMessage = "Profile updated successfully"
            updateSuccessful = true
        } else {
            alertMessage = "Failed to update profile"
        }
        
        showAlert = true
    }
    
    func resetFields() {
        if let user = currentUser {
            userName = user.userName
            password = ""
            confirmPassword = ""
        }
    }
    
    func getUserBooks() -> [Book] {
        guard let user = currentUser else { return [] }
        return dbHelper.getUserBooks(userId: user.id)
    }
    
    func loadUserLabels() {
        guard let user = currentUser else {
            userLabels = []
            return
        }
        userLabels = dbHelper.getUserLabels(userId: user.id)
    }
    
    func getUserLabels() -> [Label] {
        guard let user = currentUser else { return [] }
        return dbHelper.getUserLabels(userId: user.id)
    }
    
    func deleteAccount() -> Bool {
        guard let userId = self.currentUser?.id else {
            self.alertMessage = "Can't find user information"
            self.showAlert = true
            return false
        }
        
        let success = DatabaseHelper.shared.deleteUserAndRelatedData(userId: userId)
        
        if success {
            self.currentUser = nil
            self.userName = ""
            self.password = ""
            self.confirmPassword = ""
        } else {
            self.alertMessage = "Fail to delete the account."
            self.showAlert = true
        }
        
        return success
    }
    
    // MARK: - Label management method
    
    func addLabel(name: String) -> Bool {
        guard let userId = currentUser?.id, userId > 0, !name.isEmpty else {
            return false
        }
        
        let newLabel = Label(id: 0, labelName: name, personalized: true)
        let result = dbHelper.insertLabel(label: newLabel, userId: userId) > 0
        
        if result {
            loadUserLabels()
        }
        
        return result
    }

    func updateLabel(id: Int, newName: String) -> Bool {
        guard let userId = currentUser?.id, userId > 0, !newName.isEmpty else {
            return false
        }
        
        let success = updateLabelAlternative(id: id, newName: newName)
        
        if success {
            loadUserLabels()
        }
        
        return success
    }
  
    func deleteLabel(id: Int) -> Bool {
        guard let userId = currentUser?.id, userId > 0 else {
            return false
        }
        
        let books = dbHelper.getBooksWithLabel(labelId: id, userId: userId)
        for book in books {
            _ = dbHelper.removeLabelFromBook(bookId: book.BookId, labelId: id, userId: userId)
        }
        
        let success = dbHelper.deleteLabel(id: id, userId: userId)
        
        if success {
            loadUserLabels()
        }
        
        return success
    }
    
    private func updateLabelAlternative(id: Int, newName: String) -> Bool {
        guard let userId = currentUser?.id else { return false }
        
        let dbHelper = DatabaseHelper.shared
        
        let labels = dbHelper.getUserLabels(userId: userId)
        guard let label = labels.first(where: { $0.id == id }), label.personalized else {
            return false
        }
        
        let books = dbHelper.getBooksWithLabel(labelId: id, userId: userId)
        
        for book in books {
            _ = dbHelper.removeLabelFromBook(bookId: book.BookId, labelId: id, userId: userId)
        }
        
        guard dbHelper.deleteLabel(id: id, userId: userId) else {
            return false
        }
        
        let newLabel = Label(id: 0, labelName: newName, personalized: true)
        let newLabelId = dbHelper.insertLabel(label: newLabel, userId: userId)
        
        if newLabelId > 0 {
            for book in books {
                _ = dbHelper.addLabelToBook(bookId: book.BookId, labelId: Int(newLabelId), userId: userId)
            }
            return true
        }
        
        return false
    }
}
