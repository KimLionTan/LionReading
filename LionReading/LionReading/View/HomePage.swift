//
//  HomePage.swift
//  LionReading
//
//  Created by Tan Jianing.
//

import SwiftUI

struct HomePage: View {
    var user: User
    
    @EnvironmentObject var loginController: LoginController
    @StateObject private var contentViewModel = ContentViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Library")
                }
                .tag(0)
            
            ProfileView(user: user)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(1)
        }
        .accentColor(.orange)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    loginController.isAuthenticated = false
                }) {
                    Text("Logout")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                }
            }
        }
        .onAppear {
            contentViewModel.setUser(userId: user.id)
                
            // Add account cancellation notification listening
            NotificationCenter.default.addObserver(forName: NSNotification.Name("LogoutUser"), object: nil, queue: .main) { _ in
                
            // Set the user login status to false when the logout notification is received
            loginController.isAuthenticated = false
            }
        }
        .onDisappear {
            // Remove notification listening
            NotificationCenter.default.removeObserver(NSNotification.Name("LogoutUser"))
        }
        .environmentObject(contentViewModel)
        
    }
}

#Preview {
    NavigationStack {
        HomePage(user: User(id: 1, account: "2021213020@163.com", password: "123", userName: "Kim", headPort: "dHeadPor"))
            .environmentObject(LoginController())
    }
}
