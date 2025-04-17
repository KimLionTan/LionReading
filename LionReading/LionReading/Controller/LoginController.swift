//  LoginController.swift
//  LionReading
//
//  Created by TanJianing.
//

import Foundation
import SwiftUI

class LoginController: ObservableObject {
    private let dbHelper = DatabaseHelper.shared

    @Published var account: String = ""
    @Published var password: String = ""
    @Published var userName: String = ""
    @Published var headPort: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var shouldNavigate: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User = User(id: 0, account: "", password: "", userName: "", headPort: "")
    
    func validateInputs() -> Bool {
        if account.isEmpty || password.isEmpty {
            alertMessage = "Inputs can't be empty"
            showAlert = true
            return false
        }
        return true
    }
    
    func login() {
        if !validateInputs() {
            return
        }

        if let user = dbHelper.getUserByAccount(account: account) {
            //Authentication password
            if user.password == password {
                currentUser = user
                isAuthenticated = true
            } else {
                alertMessage = "Incorrect password"
                showAlert = true
            }
        } else {
            alertMessage = "Account not found"
            showAlert = true
        }
    }

    func navigateToRegister() {
        shouldNavigate = true
    }

    func resetFields() {
        account = ""
        password = ""
    }
}
