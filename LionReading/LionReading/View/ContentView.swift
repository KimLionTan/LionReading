//
//  ContentView.swift
//  LionReading
//
//  Created by TanJianing.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var loginController: LoginController
    @StateObject private var viewModel = ContentViewModel()
    @State private var showScanner = false
    @State private var showManualInput = false
    @State private var selectedBook: Book?
    @State private var showingBookDetail = false
    
    var body: some View {
        ZStack {
            Background()
            
            VStack {
                if viewModel.myBooks.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "book.closed")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                        
                        Text("Empty Bookshelf")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Add books by scanning ISBN or manual input")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    
                } else {
                    List {
                        ForEach(viewModel.myBooks, id: \.BookId) { book in
                            BookRow(book: book)
                                .onTapGesture {
                                    selectedBook = book
                                    showingBookDetail = true
                                }
                                .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: viewModel.removeBook)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                    .onAppear {
                        UITableView.appearance().backgroundColor = .clear
                    }
                    .onDisappear {
                        UITableView.appearance().backgroundColor = nil
                    }
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        showScanner = true
                    }) {
                        HStack {
                            Image(systemName: "barcode.viewfinder")
                            Text("Scan ISBN")
                        }
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showManualInput = true
                    }) {
                        HStack {
                            Image(systemName: "keyboard")
                            Text("Manual Input")
                        }
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("My Bookshelf")
            .sheet(isPresented: $showScanner) {
                ScannerView()
                    .onDisappear {
                        viewModel.checkForNewBooks()
                    }
            }
            .sheet(isPresented: $showingBookDetail) {
                if let book = selectedBook {
                    BookDetailView(book: book)
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Book Info"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationDestination(isPresented: $showManualInput) {
                ISBNInputView()
                    .environmentObject(loginController)
                    .environmentObject(viewModel)
            }
        }
        .onAppear {
            if loginController.isAuthenticated {
                viewModel.setUser(userId: loginController.currentUser.id)
            }
        }
        .onChange(of: loginController.isAuthenticated) { oldValue, newValue in
            if newValue {
                viewModel.setUser(userId: loginController.currentUser.id)
            } else {
                viewModel.setUser(userId: 0) 
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
            .environmentObject(LoginController())
    }
}
