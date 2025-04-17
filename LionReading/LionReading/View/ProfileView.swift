//
//  ProfileView.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct ProfileView: View {
    var user: User
    @StateObject private var userController = UserController()
    @State private var showingEditProfile = false
    @State private var showingLabelManager = false
  
    var body: some View {
        ZStack {
            Background()
            
            VStack(spacing: 20) {
                CircleImage(imageURL: user.headPort)
                
                Text(user.userName)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(user.account)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                
                VStack(spacing: 15) {
                    Button(action: {
                        showingEditProfile = true
                    }) {
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                            Text("Edit Profile")
                        }
                        .frame(minWidth: 200)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showingLabelManager = true
                    }) {
                        HStack {
                            Image(systemName: "tag.fill")
                            Text("Manage Labels")
                        }
                        .frame(minWidth: 200)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(controller: userController)
        }
        .sheet(isPresented: $showingLabelManager) {
            LabelManagerView(controller: userController)
        }
        .onAppear {
            userController.loadUser(user)
        }
    }
}

