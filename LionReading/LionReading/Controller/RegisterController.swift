//
//  RegisterController.swift
//  LionReading
//
//  Created by TanJianing on.
//
import Foundation
import SwiftUI
import Combine

class RegisterController: ObservableObject {
    private let dbHelper = DatabaseHelper.shared

    @Published var username: String = ""
    @Published var account: String = ""
    @Published var password1: String = ""
    @Published var password2: String = ""
    @Published var headPort: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var shouldNavigate: Bool = false
    @Published var registrationSuccessful: Bool = false
    
    func validateInputs() -> Bool {
        // Check for empty fields
        if username.isEmpty || account.isEmpty || password1.isEmpty || password2.isEmpty {
            alertMessage = "Inputs can't be empty"
            showAlert = true
            return false
        }
        
        // Check that the account conforms to the mail format
        if !account.contains("@"){
            alertMessage = "Account must be a valid email address containing @"
            showAlert = true
            return false
        }
        
        // Check whether the two passwords are the same
        if password1 != password2 {
            alertMessage = "Passwords are not same!"
            showAlert = true
            return false
        }
        
        // Check password format
        if !isValidPassword(password1) {
            alertMessage = "Password must be at least 8 characters long and include uppercase letters, lowercase letters, and special symbols (e.g., !)"
            showAlert = true
            return false
        }
        
        return true
    }
    
    // Authentication password format
    private func isValidPassword(_ password: String) -> Bool {
        // At least 8 bits
        if password.count < 8 {
            return false
        }
        
        // Include capital letters
        let uppercaseLetterRegex = ".*[A-Z]+.*"
        if password.range(of: uppercaseLetterRegex, options: .regularExpression) == nil {
            return false
        }
        
        // Include lowercase letters
        let lowercaseLetterRegex = ".*[a-z]+.*"
        if password.range(of: lowercaseLetterRegex, options: .regularExpression) == nil {
            return false
        }
        
        // Contains special symbols (e.g.! @ # $% ^ & * () _ + - = [] {} |; :,. < >? / ~ `)
        let specialCharacterRegex = ".*[!@#$%^&*()_+-=\\[\\]{}|;:,.<>?/~`]+.*"
        if password.range(of: specialCharacterRegex, options: .regularExpression) == nil {
            return false
        }
        
        return true
    }
    
    func register() {
        if !validateInputs() {
            return
        }
        
        // create new user
        let newUser = User(
            id: 0,
            account: account,
            password: password1,
            userName: username,
            headPort: headPort.isEmpty ? "dHeadPor" : headPort
        )
        
        // Trying to add a user to the database
        let userId = dbHelper.addUser(user: newUser)
        
        if userId > 0 {
            alertMessage = "Registration successful: \(username)"
            registrationSuccessful = true
            shouldNavigate = true
        } else {
            alertMessage = "Registration failed. Please try again."
            showAlert = true
        }
    }

    func resetFields() {
        username = ""
        account = ""
        password1 = ""
        password2 = ""
        headPort = ""
    }
}
