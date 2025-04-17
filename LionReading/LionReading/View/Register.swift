//
//  Register.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI
import Combine

struct Register: View {
    @StateObject private var controller = RegisterController()
    
    var body: some View {
        ZStack{
            Background()
            VStack{
                CircleImage(imageURL: "dHeadPor")
                
                HStack {
                    Text("User Name: ")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    TextField("Please enter your name", text: $controller.username)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                }
                
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
                    Text("Password: ")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    TextField("Please enter your password", text: $controller.password1)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                }
                
                HStack {
                    Text("Confirm Password: ")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    TextField("Please enter your password", text: $controller.password2)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                }
                
                // Save and Cancel
                HStack{
                    Button(action: {
                        //clear
                        controller.resetFields()
                        
                    }) {
                        
                        Text("Cancel")
                        .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                    }
                    
                    Button(action: {
                        controller.register()
                    }) {
                        Text("Save")
                        .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                    }
                }
            NavigationLink(destination: Login(), isActive: $controller.shouldNavigate) {
                                EmptyView()
                            }
                Spacer()
            }
            .alert(isPresented: $controller.showAlert) {
                Alert(title: Text(controller.alertMessage))
            }
        }
    }
}

#Preview {
    Register()
}
