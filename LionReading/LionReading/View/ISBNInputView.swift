//
//  ISBNInputView.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct ISBNInputView: View {
    @StateObject private var viewModel: ISBNViewModel
    @EnvironmentObject var loginController: LoginController
    @EnvironmentObject var contentViewModel: ContentViewModel
    
    init(initialISBN: String = "", autoSearch: Bool = false) {
        _viewModel = StateObject(wrappedValue: ISBNViewModel(initialISBN: initialISBN, autoSearch: autoSearch))
    }
    
    var body: some View {
        ZStack {
            Background()
            
            ScrollView {
                VStack(spacing: 20) {
                    SearchBarView(isbn: $viewModel.isbn, searchAction: {
                        viewModel.searchBook(loginController: loginController)
                    })
                    
                    if viewModel.isLoading {
                        ProgressView("Searching...")
                            .padding()
                    }
                    
                    if let book = viewModel.bookInfo {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(alignment: .top) {
                                BookCoverView(imageURLString: book.picture)
                                    .frame(width: 100, height: 150)
                                    .cornerRadius(8)
                                
                                BookInfoView(book: book)
                                    .padding(.leading, 8)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                            
                            if !book.description.isEmpty {
                                BookDescriptionView(description: book.description)
                            }
                            
                            LabelsSelectionView(
                                viewModel: viewModel,
                                loginController: loginController
                            )
                            
                            ReadingStatusSelectionView(viewModel: viewModel)
                                .onChange(of: viewModel.selectedReadingStatus) { newStatus in
                                    if newStatus == ReadingStatus.alreadyRead.description {
                                        viewModel.showDatePicker = true
                                    } else {
                                        viewModel.showDatePicker = false
                                    }
                                }

                            if viewModel.showDatePicker {
                                DatePicker(
                                    "Finish Date",
                                    selection: $viewModel.finishDate,
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(.graphical)
                                .tint(.orange) 
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                            }
                            
                            ActionButtonsView(
                                saveAction: {
                                    viewModel.saveBook(
                                        loginController: loginController,
                                        contentViewModel: contentViewModel
                                    )
                                },
                                clearAction: { viewModel.clearForm() }
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Add books")
        .tint(.orange)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Tips"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("Sure"))
            )
        }
        .alert("Reminder", isPresented: $viewModel.showCalendarAlert) {
            Button("Sure", role: .cancel) { }
        } message: {
            Text(viewModel.calendarAlertMessage)
        }
        .alert("Add to the calendar", isPresented: $viewModel.shouldAddToCalendar) {
            Button("Yes", role: .none) {
                if let book = viewModel.bookInfo {
                    viewModel.addBookToCalendar(bookName: book.bName, author: book.Author, date: viewModel.finishDate)
                }
            }
            Button("No", role: .cancel) { }
        } message: {
            if let book = viewModel.bookInfo {
                Text("Do you want to add the history of reading《\(book.bName)》in your calendar?")
            } else {
                Text("Should the reading record of this book be added to the calendar?")
            }
        }
        .onAppear {
            viewModel.onAppear(loginController: loginController)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ProcessScannedISBN"))) { notification in
            if let scannedISBN = notification.userInfo?["isbn"] as? String {
                viewModel.processScannedISBN(scannedISBN, loginController: loginController)
            }
        }
    }
    

}

extension ISBNInputView {
    func processScannedISBN(_ isbn: String) {
        viewModel.processScannedISBN(isbn, loginController: loginController)
    }
}

#Preview {
    NavigationStack {
        ISBNInputView()
            .environmentObject(LoginController())
            .environmentObject(ContentViewModel())
    }
}
