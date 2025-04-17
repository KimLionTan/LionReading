//
//  Login.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct Login: View {
    @StateObject private var controller = LoginController()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Background()
                VStack {
                    Text("Lion Reading")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(Color.red)
                    
                    CircleImage(imageURL: "dHeadPor")
                    
                    HStack {
                        Text("Account: ")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        TextField("Please enter your account", text: $controller.account)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                    }
                    
                    HStack {
                        Text("Password")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        SecureField("Please enter your password", text: $controller.password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                    }
                    
                    //Register
                    Button(action: {
                        controller.navigateToRegister()
                    }) {
                        Text("New Here?")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    // Login
                    Button(action: {
                        controller.login()
                    }) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                    }
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $controller.shouldNavigate) {
                Register()
            }
            .navigationDestination(isPresented: $controller.isAuthenticated) {
                HomePage(user: controller.currentUser)
                    .environmentObject(controller)
            }
            .alert(isPresented: $controller.showAlert) {
                Alert(title: Text("Message"), message: Text(controller.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    Login()
}
