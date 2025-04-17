//
//  BookDetail.swift
//  LionReading
//
//  Created by TanJianing.
//  For previewing and adding new books after scanning

import SwiftUI

struct BookDetail: View {
    let book: Book
    @Environment(\.presentationMode) var presentationMode
    private let bookController = BookController.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Book Information")) {
                    if let url = URL(string: book.picture), !book.picture.isEmpty {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                    }
                    
                    DetailRow(label: "Name", value: book.bName)
                    DetailRow(label: "Author", value: book.Author)
                    DetailRow(label: "ISBN", value: book.ISBN)
                    DetailRow(label: "Publisher", value: book.publisher)
                    DetailRow(label: "Publish Date", value: book.pDate)
                    DetailRow(label: "Publish Place", value: book.pPlace)
                    DetailRow(label: "Price", value: String(format: "¥%.2f", book.price))
                }
                
                Section(header: Text("Description")) {
                    Text(book.description)
                        .font(.body)
                }
                
                Section {
                    Button("Add to My Bookshelf") {
                        saveBook()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
                }
            }
            .navigationTitle("Book Details")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func saveBook() {
        bookController.saveLastScannedBook(book)
        presentationMode.wrappedValue.dismiss()
    }
}
