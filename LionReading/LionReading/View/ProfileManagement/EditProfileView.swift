//
//  EditProfileView.swift
//  LionReading
//
//  Created by TanJianing.
//  

import SwiftUI

struct EditProfileView: View {
    @ObservedObject var controller: UserController
    @Environment(\.presentationMode) var presentationMode
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        
        NavigationView {
            ZStack{
                Background()
            
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Profile Information")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            TextField("Username", text: $controller.userName)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Change Password")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            SecureField("New Password", text: $controller.password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            
                            SecureField("Confirm Password", text: $controller.confirmPassword)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        Button("Save Changes") {
                            controller.saveUser()
                            if controller.updateSuccessful {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Text("Delete account")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Edit Profile")
                .navigationBarItems(
                    trailing: Button("Cancel"){
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                    .fontWeight(.bold)
                )
                .alert(isPresented: $controller.showAlert) {
                    Alert(
                        title: Text("Profile Update"),
                        message: Text(controller.alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .alert("Are you sure to delete the account？", isPresented: $showDeleteConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Sure", role: .destructive) {
                        let success = controller.deleteAccount()
                        
                        if success {
                            NotificationCenter.default.post(name: NSNotification.Name("LogoutUser"), object: nil)
                            
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                } message: {
                    Text("After deleting the account, all your data will be deleted, including bookshelf information and custom labels, and this operation cannot be restored.")
                }
            }
        }
    }
}
