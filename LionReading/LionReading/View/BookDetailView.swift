//
//  BookDetailView.swift
//  LionReading
//
//  Created by TanJianing.
//  Used to view details and manage tags for added books

import SwiftUI

struct BookDetailView: View {
    @StateObject private var viewModel: BookDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(book: Book) {
        _viewModel = StateObject(wrappedValue: BookDetailViewModel(book: book))
    }
    
    var body: some View {
        ZStack {
            Background()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    Text("Book Details")
                        .font(.title)
                        .foregroundColor(.black)
                    Spacer()
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.red)
                }
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        bookInfoSection
                        
                        Divider()
                        
                        if !viewModel.book.description.isEmpty {
                            descriptionSection
                            Divider()
                        }
                        
                        labelsSection
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        
                        Divider()
                        
                        readingStatusSection
                        
                        if !viewModel.recommendedBooks.isEmpty {
                            Divider()
                            recommendedBooksSection
                        }
                    }
                }
                .background(Color.clear)
                .sheet(isPresented: $viewModel.showAddLabel) {
                    AddLabelView(isPresented: $viewModel.showAddLabel, onAdd: { labelName in
                        viewModel.addLabel(name: labelName)
                    })
                }
                .alert(isPresented: $viewModel.showDeleteAlert) {
                    createDeleteAlert()
                }
                .alert("Reminder", isPresented: $viewModel.showCalendarAlert) {
                    Button("Sure", role: .cancel) { }
                } message: {
                    Text(viewModel.calendarAlertMessage)
                }
                .alert("Add to the calendar", isPresented: $viewModel.shouldAddToCalendar) {
                    Button("Yes", role: .none) {
                        viewModel.addBookToCalendar()
                    }
                    Button("No", role: .cancel) { }
                } message: {
                    Text("Do you want to add the history of reading 《\(viewModel.book.bName)》in your calendar?")
                }
                .onAppear {
                    viewModel.loadBookLabels()
                    viewModel.loadReadingStatus()
                    viewModel.loadRecommendedBooks()
                    print("BookDetailView appears and is loading the tag for the book ID: \(viewModel.book.BookId)")
                }
            }
            .background(Color.clear)
        }
    }
    
    // MARK: - subview
    
    private var bookInfoSection: some View {
        HStack(alignment: .top) {
            coverView
            
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.book.bName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(viewModel.book.Author)
                    .font(.headline)
                
                if !viewModel.book.publisher.isEmpty {
                    Text("Publisher: \(viewModel.book.publisher)")
                        .font(.subheadline)
                }
                
                if !viewModel.book.pDate.isEmpty {
                    Text("Published: \(viewModel.book.pDate)")
                        .font(.subheadline)
                }
                
                Text("ISBN: \(viewModel.book.ISBN)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private var coverView: some View {
        Group {
            if !viewModel.book.picture.isEmpty {
                AsyncImage(url: URL(string: viewModel.book.picture)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image(systemName: "book")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                }
                .frame(width: 120, height: 180)
                .cornerRadius(8)
            } else {
                Image(systemName: "book")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 180)
                    .foregroundColor(.gray)
                    .cornerRadius(8)
            }
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
            
            Text(viewModel.book.description)
                .font(.body)
        }
        .padding(.horizontal)
    }
    
    private var labelsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            labelHeader
            
            if viewModel.labels.isEmpty {
                Text("No labels yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            } else {
                FlowLayout(items: viewModel.labels) { label in
                    LabelView(
                        label: label,
                        isEditing: viewModel.isEditingLabels,
                        onDelete: {
                            viewModel.prepareLabelForDeletion(label)
                        }
                    )
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var labelHeader: some View {
        HStack {
            Text("Labels")
                .font(.headline)
            
            Spacer()
            
            if viewModel.isEditingLabels {
                Button(action: {
                    viewModel.isEditingLabels = false
                }) {
                    Text("Done")
                        .foregroundColor(.red)
                }
                .padding(.trailing, 8)
            }
            
            HStack(spacing: 15) {
                Button(action: {
                    viewModel.toggleEditMode()
                }) {
                    Image(systemName: viewModel.isEditingLabels ? "pencil.slash" : "minus.circle")
                        .foregroundColor(viewModel.isEditingLabels ? .orange : .red)
                }
                
                Button(action: {
                    viewModel.showAddLabel = true
                }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.orange)
                }
            }
        }
    }
    
    private var readingStatusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Reading Status:")
                    .font(.headline)
                
                Spacer()
                
                if viewModel.readingStatus == .alreadyRead {
                    // already read status
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        Text(viewModel.readingStatus.description)
                        
                        if let finishDate = viewModel.finishDate {
                            Text("(\(DateFormatter.yyyyMMdd.string(from: finishDate)))")
                                .foregroundColor(.gray)
                        }
                    }
                    .onTapGesture {
                        viewModel.showDatePicker.toggle()
                    }
                    
                    // 添加日历按钮
                    Button(action: {
                        viewModel.addBookToCalendar()
                    }) {
                        Image(systemName: "calendar.badge.plus")
                            .foregroundColor(.orange)
                    }
                    .padding(.leading, 8)
                } else {
                    // want to read- changable
                    Button(action: {
                        viewModel.toggleReadingStatus()
                    }) {
                        HStack {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                            
                            Text(viewModel.readingStatus.description)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // date selector
            if viewModel.showDatePicker {
                DatePicker(
                    "Select Finish Date",
                    selection: Binding<Date>(
                        get: { viewModel.finishDate ?? Date() },
                        set: {
                            viewModel.finishDate = $0
                            //save the date change
                            DatabaseHelper.shared.setBookReadingStatus(
                                bookId: viewModel.book.BookId,
                                userId: viewModel.book.UserId,
                                status: .alreadyRead,
                                finishDate: $0
                            )
                        }
                    ),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .tint(.orange)
                .transition(.slide)
            }
        }
        .padding(.horizontal)
        .animation(.default, value: viewModel.showDatePicker)
    }

    
    // MARK: - Auxiliary method
    
    private func createDeleteAlert() -> Alert {
        guard let label = viewModel.labelToDelete else {
            return Alert(
                title: Text("Error"),
                message: Text("No label selected for removal."),
                dismissButton: .default(Text("OK"))
            )
        }
        // If the label is user-defined, a normal deletion confirmation is displayed
        return Alert(
            title: Text("Confirm Removal"),
            message: Text("Are you sure you want to remove the label '\(label.labelName)' from this book?"),
            primaryButton: .destructive(Text("Remove")) {
                viewModel.removeLabel(label)
            },
            secondaryButton: .cancel()
        )
    }
    
    // Add the recommended books section
    private var recommendedBooksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Other users also read:")
                    .font(.headline)
                
                Text("(\(viewModel.recommendedBooks.count) books)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
               
                Button(action: {
                    viewModel.loadRecommendedBooks()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal)
            
            if viewModel.recommendedBooks.isEmpty {
                Text("No recommendations found")
                    .foregroundColor(.gray)
                    .italic()
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.recommendedBooks, id: \.BookId) { book in
                            VStack(alignment: .center) {
                                if !book.picture.isEmpty {
                                    AsyncImage(url: URL(string: book.picture)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    } placeholder: {
                                        Image(systemName: "book")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 80, height: 120)
                                    .cornerRadius(6)
                                } else {
                                    Image(systemName: "book")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 80, height: 120)
                                        .foregroundColor(.gray)
                                        .cornerRadius(6)
                                }

                                Text(book.bName)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 80)
                            }
                            .onTapGesture {
                                print("Click on recommended books: \(book.bName)")
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 160)
            }
        }
        .padding(.vertical)
        .background(Color.clear)
        .onAppear {
            print("The recommended books section appears")
        }
    }
}
