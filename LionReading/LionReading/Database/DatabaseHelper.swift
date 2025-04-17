//
//  DatabaseHelper.swift
//  LionReading
//
//  Created by TanJianing.
//
//  This application uses SQLite database to store data.
//  The database is automatically created in the user's Documents directory when the application first runs.
//  Make sure the project is linked to the SQLite3 framework (libsqlite3.tbd)

import Foundation
import SQLite3

// Define the read state enumeration
enum ReadingStatus: Int {
    case hopeToRead = 0
    case alreadyRead = 1
    
    var description: String {
        switch self {
        case .hopeToRead:
            return "Hope to Read"
        case .alreadyRead:
            return "Already Read"
        }
    }
    
    static func fromString(_ string: String) -> ReadingStatus? {
        switch string {
        case "Hope to Read":
            return .hopeToRead
        case "Already Read":
            return .alreadyRead
        default:
            return nil
        }
    }
}

class DatabaseHelper {
    // Database connection
    private var db: OpaquePointer?
    private let dbPath: String
    
    // Singleton pattern
    static let shared = DatabaseHelper()
    
    // Get the database file path
    func getDatabasePath() -> String {
        return dbPath
    }
    
    
    private init() {

        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("BookshelfApp.sqlite")
        
        dbPath = fileURL.path
        print("Database path: \(dbPath)")
        
        // open the connection
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("Cannot open the database")
            return
        }

        createTables()
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    // MARK: - Table creation method
    
    private func createTables() {
        // Users
        let createUserTableQuery = """
        CREATE TABLE IF NOT EXISTS Users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            account TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            userName TEXT NOT NULL,
            headPort TEXT
        );
        """
        
        // Books
        let createBooksTableQuery = """
        CREATE TABLE IF NOT EXISTS Books (
            BookId INTEGER PRIMARY KEY AUTOINCREMENT,
            ISBN TEXT UNIQUE NOT NULL,
            bName TEXT NOT NULL,
            Author TEXT,
            publisher TEXT,
            pDate TEXT,
            pPlace TEXT,
            price REAL,
            picture TEXT,
            description TEXT
        );
        """
        
        // UserBooks: An intermediate table that associates users with books
        let createUserBooksTableQuery = """
        CREATE TABLE IF NOT EXISTS UserBooks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            UserId INTEGER NOT NULL,
            BookId INTEGER NOT NULL,
            FOREIGN KEY (UserId) REFERENCES Users(id) ON DELETE CASCADE,
            FOREIGN KEY (BookId) REFERENCES Books(BookId) ON DELETE CASCADE,
            UNIQUE(UserId, BookId)
        );
        """
        
        // Labels
        let createLabelsTableQuery = """
        CREATE TABLE IF NOT EXISTS Labels (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            labelName TEXT NOT NULL,
            personalized BOOLEAN NOT NULL,
            UserId INTEGER,
            FOREIGN KEY (UserId) REFERENCES Users(id) ON DELETE CASCADE
        );
        """
        
        // BookLabels: An intermediate table of associated books and labels
        let createBookLabelsTableQuery = """
        CREATE TABLE IF NOT EXISTS BookLabels (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            BookId INTEGER NOT NULL,
            LabelId INTEGER NOT NULL,
            UserId INTEGER NOT NULL,
            FOREIGN KEY (BookId) REFERENCES Books(BookId) ON DELETE CASCADE,
            FOREIGN KEY (LabelId) REFERENCES Labels(id) ON DELETE CASCADE,
            FOREIGN KEY (UserId) REFERENCES Users(id) ON DELETE CASCADE,
            UNIQUE(BookId, LabelId, UserId)
        );
        """
        
        // BookReadingStatus:save the books' states
        let createBookReadingStatusTableQuery = """
        CREATE TABLE IF NOT EXISTS BookReadingStatus (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            BookId INTEGER NOT NULL,
            UserId INTEGER NOT NULL,
            Status INTEGER NOT NULL DEFAULT 0,
            FinishDate TEXT, 
            FOREIGN KEY (BookId) REFERENCES Books(BookId) ON DELETE CASCADE,
            FOREIGN KEY (UserId) REFERENCES Users(id) ON DELETE CASCADE,
            UNIQUE(BookId, UserId)
        );
        """
        
        // Execute the query that creates the table
        executeQuery(query: createUserTableQuery)
        executeQuery(query: createBooksTableQuery)
        executeQuery(query: createUserBooksTableQuery)
        executeQuery(query: createLabelsTableQuery)
        executeQuery(query: createBookLabelsTableQuery)
        executeQuery(query: createBookReadingStatusTableQuery)
        
        // Create a default system label
        createDefaultSystemLabels()
    }
    
    // MARK: - Auxiliary method
    
    private func executeQuery(query: String) {
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Fail to query: \(errorMessage)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Fail to prepare to query: \(errorMessage)")
        }
        
        sqlite3_finalize(statement)
    }
    
    // MARK: - User related methods
    
    func addUser(user: User) -> Int64 {
        let insertUserQuery = "INSERT INTO Users (account, password, userName, headPort) VALUES (?, ?, ?, ?);"
        var statement: OpaquePointer?
        var userId: Int64 = -1
        
        if sqlite3_prepare_v2(db, insertUserQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (user.account as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (user.password as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (user.userName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (user.headPort as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                userId = sqlite3_last_insert_rowid(db)
            } else {
                print("Fail to inset a user")
            }
        } else {
            print("Fail to prepare")
        }
        
        sqlite3_finalize(statement)
        return userId
    }
    
    func updateUser(user: User) -> Bool {
        let updateUserQuery = "UPDATE Users SET account = ?, password = ?, userName = ?, headPort = ? WHERE id = ?;"
        var statement: OpaquePointer?
        var success = false
        
        if sqlite3_prepare_v2(db, updateUserQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (user.account as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (user.password as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (user.userName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (user.headPort as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 5, Int32(user.id))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                success = true
            } else {
                print("Fail to update the user")
            }
        } else {
            print("Fail to prepare")
        }
        
        sqlite3_finalize(statement)
        return success
    }
    
    func getUser(byId id: Int) -> User? {
        let getUserQuery = "SELECT * FROM Users WHERE id = ?;"
        var statement: OpaquePointer?
        var user: User?
        
        if sqlite3_prepare_v2(db, getUserQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let account = String(cString: sqlite3_column_text(statement, 1))
                let password = String(cString: sqlite3_column_text(statement, 2))
                let userName = String(cString: sqlite3_column_text(statement, 3))
                let headPort = sqlite3_column_text(statement, 4) != nil ? String(cString: sqlite3_column_text(statement, 4)) : ""
                
                user = User(id: id, account: account, password: password, userName: userName, headPort: headPort)
            }
        } else {
            print("Fail to prepare")
        }
        
        sqlite3_finalize(statement)
        return user
    }
    
    func getUserByAccount(account: String) -> User? {
        let getUserQuery = "SELECT * FROM Users WHERE account = ?;"
        var statement: OpaquePointer?
        var user: User?
        
        if sqlite3_prepare_v2(db, getUserQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (account as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let account = String(cString: sqlite3_column_text(statement, 1))
                let password = String(cString: sqlite3_column_text(statement, 2))
                let userName = String(cString: sqlite3_column_text(statement, 3))
                let headPort = sqlite3_column_text(statement, 4) != nil ? String(cString: sqlite3_column_text(statement, 4)) : ""
                
                user = User(id: id, account: account, password: password, userName: userName, headPort: headPort)
            }
        } else {
            print("Fail to prepare")
        }
        
        sqlite3_finalize(statement)
        return user
    }
    
    func deleteUserAndRelatedData(userId: Int) -> Bool {
        executeQuery(query: "BEGIN TRANSACTION;")
        
        var success = true
        
        // 1. Delete the label association of a user
        let deleteBookLabelsQuery = "DELETE FROM BookLabels WHERE UserId = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteBookLabelsQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(userId))
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Fail to delete the related label connection")
                success = false
            }
        } else {
            print("fail to prepare")
            success = false
        }
        
        sqlite3_finalize(statement)
        
        // 2. Delete personalized labels created by users
        let deleteLabelsQuery = "DELETE FROM Labels WHERE UserId = ? AND personalized = 1;"
        
        if sqlite3_prepare_v2(db, deleteLabelsQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(userId))
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Fail to delete the related labels")
                success = false
            }
        } else {
            print("fail to prepare")
            success = false
        }
        
        sqlite3_finalize(statement)
        
        // 3. Delete a user's book association
        let deleteUserBooksQuery = "DELETE FROM UserBooks WHERE UserId = ?;"
        
        if sqlite3_prepare_v2(db, deleteUserBooksQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(userId))
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Fail to clear the related bookshelf")
                success = false
            }
        } else {
            print("fail to prepare")
            success = false
        }
        
        sqlite3_finalize(statement)
        
        let deleteReadingStatusQuery = "DELETE FROM BookReadingStatus WHERE UserId = ?;"
        
        if sqlite3_prepare_v2(db, deleteReadingStatusQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(userId))
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Fail to clear the related reading status")
                success = false
            }
        } else {
            print("fail to prepare")
            success = false
        }
        
        sqlite3_finalize(statement)
        
        // 4. Finally, delete the user itself
        let deleteUserQuery = "DELETE FROM Users WHERE id = ?;"
        
        if sqlite3_prepare_v2(db, deleteUserQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(userId))
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Fail to delete the user")
                success = false
            }
        } else {
            print("fail to prepare")
            success = false
        }
        
        sqlite3_finalize(statement)
        
        // Commit or roll back a transaction
        if success {
            executeQuery(query: "COMMIT;")
            print("Successfully finished")
        } else {
            executeQuery(query: "ROLLBACK;")
            print("Fail to delete the account.")
        }
        
        return success
    }
    
    // MARK: - Book related methods
    
    func insertBook(book: Book) -> Int64 {

        let bookId = getBookIdByISBN(isbn: book.ISBN)
        
        //Check if the book already exists
        if bookId != -1 {
            let success = addBookToUser(userId: book.UserId, bookId: bookId)
            if !success {
                print("Failed to add book to user")
                return -1
            }
            return Int64(bookId)
        }
        
        let insertBookQuery = """
        INSERT INTO Books (ISBN, bName, Author, publisher, pDate, pPlace, price, picture, description)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var statement: OpaquePointer?
        var newBookId: Int64 = -1
        
        if sqlite3_prepare_v2(db, insertBookQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (book.ISBN as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (book.bName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (book.Author as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (book.publisher as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 5, (book.pDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 6, (book.pPlace as NSString).utf8String, -1, nil)
            sqlite3_bind_double(statement, 7, book.price)
            sqlite3_bind_text(statement, 8, (book.picture as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 9, (book.description as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                newBookId = sqlite3_last_insert_rowid(db)
                let success = addBookToUser(userId: book.UserId, bookId: Int(newBookId))
                if !success {
                    print("Failed to add book to user after insertion")//Inserted but association failed
                    newBookId = -1
                } else {
                    // error solution
                    setBookReadingStatus(bookId: Int(newBookId), userId: book.UserId, status: .hopeToRead)
                }
            } else {
                print("Fail to insert a book")
            }
        } else {
            print("Fail to prepare")
        }
        
        sqlite3_finalize(statement)
        return newBookId
    }
    
    private func getBookIdByISBN(isbn: String) -> Int {
        let getBookQuery = "SELECT BookId FROM Books WHERE ISBN = ?;"
        var statement: OpaquePointer?
        var bookId: Int = -1
        
        if sqlite3_prepare_v2(db, getBookQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (isbn as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                bookId = Int(sqlite3_column_int(statement, 0))
            }
        } else {
            print("Fail to get book id")
        }
        
        sqlite3_finalize(statement)
        return bookId
    }
    
    private func addBookToUser(userId: Int, bookId: Int) -> Bool {
        let insertUserBookQuery = "INSERT OR IGNORE INTO UserBooks (UserId, BookId) VALUES (?, ?);"
        var statement: OpaquePointer?
        var success = false
        
        if sqlite3_prepare_v2(db, insertUserBookQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(userId))
            sqlite3_bind_int(statement, 2, Int32(bookId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                success = true
            } else {
                print("Fail to add book information to the user.")
            }
        } else {
            print("Fail to prepare")
        }
        
        sqlite3_finalize(statement)
        return success
    }
    
    func getBook(byId id: Int) -> Book? {
        let getBookQuery = """
        SELECT b.BookId, b.ISBN, b.bName, b.Author, b.publisher, b.pDate, b.pPlace, b.price, b.picture, b.description, ub.UserId
        FROM Books b
        JOIN UserBooks ub ON b.BookId = ub.BookId
        WHERE b.BookId = ?;
        """
        var statement: OpaquePointer?
        var book: Book?
        
        if sqlite3_prepare_v2(db, getBookQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let bookId = Int(sqlite3_column_int(statement, 0))
                let isbn = String(cString: sqlite3_column_text(statement, 1))
                let bName = String(cString: sqlite3_column_text(statement, 2))
                let author = sqlite3_column_text(statement, 3) != nil ? String(cString: sqlite3_column_text(statement, 3)) : ""
                let publisher = sqlite3_column_text(statement, 4) != nil ? String(cString: sqlite3_column_text(statement, 4)) : ""
                let pDate = sqlite3_column_text(statement, 5) != nil ? String(cString: sqlite3_column_text(statement, 5)) : ""
                let pPlace = sqlite3_column_text(statement, 6) != nil ? String(cString: sqlite3_column_text(statement, 6)) : ""
                let price = sqlite3_column_double(statement, 7)
                let picture = sqlite3_column_text(statement, 8) != nil ? String(cString: sqlite3_column_text(statement, 8)) : ""
                let description = sqlite3_column_text(statement, 9) != nil ? String(cString: sqlite3_column_text(statement, 9)) : ""
                let userId = Int(sqlite3_column_int(statement, 10))
                
                book = Book(
                    UserId: userId,
                    BookId: bookId,
                    ISBN: isbn,
                    bName: bName,
                    Author: author,
                    publisher: publisher,
                    pDate: pDate,
                    pPlace: pPlace,
                    price: price,
                    picture: picture,
                    description: description
                )
            }
        } else {
            print("Failed to prepare the fetch book statement")
        }
        
        sqlite3_finalize(statement)
        return book
    }
    
    func getUserBooks(userId: Int) -> [Book] {
        let getUserBooksQuery = """
        SELECT b.BookId, b.ISBN, b.bName, b.Author, b.publisher, b.pDate, b.pPlace, b.price, b.picture, b.description
        FROM Books b
        JOIN UserBooks ub ON b.BookId = ub.BookId
        WHERE ub.UserId = ?;
        """
        var statement: OpaquePointer?
        var books: [Book] = []
        
        if sqlite3_prepare_v2(db, getUserBooksQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(userId))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let bookId = Int(sqlite3_column_int(statement, 0))
                let isbn = String(cString: sqlite3_column_text(statement, 1))
                let bName = String(cString: sqlite3_column_text(statement, 2))
                let author = sqlite3_column_text(statement, 3) != nil ? String(cString: sqlite3_column_text(statement, 3)) : ""
                let publisher = sqlite3_column_text(statement, 4) != nil ? String(cString: sqlite3_column_text(statement, 4)) : ""
                let pDate = sqlite3_column_text(statement, 5) != nil ? String(cString: sqlite3_column_text(statement, 5)) : ""
                let pPlace = sqlite3_column_text(statement, 6) != nil ? String(cString: sqlite3_column_text(statement, 6)) : ""
                let price = sqlite3_column_double(statement, 7)
                let picture = sqlite3_column_text(statement, 8) != nil ? String(cString: sqlite3_column_text(statement, 8)) : ""
                let description = sqlite3_column_text(statement, 9) != nil ? String(cString: sqlite3_column_text(statement, 9)) : ""
                
                let book = Book(
                    UserId: userId,
                    BookId: bookId,
                    ISBN: isbn,
                    bName: bName,
                    Author: author,
                    publisher: publisher,
                    pDate: pDate,
                    pPlace: pPlace,
                    price: price,
                    picture: picture,
                    description: description
                )
                
                books.append(book)
            }
        } else {
            print("Failed to prepare the user book statement")
        }
        
        sqlite3_finalize(statement)
        return books
    }
    
    func getBookByISBN(isbn: String, userId: Int) -> Book? {
        let getBookQuery = """
        SELECT b.BookId, b.ISBN, b.bName, b.Author, b.publisher, b.pDate, b.pPlace, b.price, b.picture, b.description
        FROM Books b
        JOIN UserBooks ub ON b.BookId = ub.BookId
        WHERE b.ISBN = ? AND ub.UserId = ?;
        """
        var statement: OpaquePointer?
        var book: Book?
        
        if sqlite3_prepare_v2(db, getBookQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (isbn as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(userId))
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let bookId = Int(sqlite3_column_int(statement, 0))
                let isbn = String(cString: sqlite3_column_text(statement, 1))
                let bName = String(cString: sqlite3_column_text(statement, 2))
                let author = sqlite3_column_text(statement, 3) != nil ? String(cString: sqlite3_column_text(statement, 3)) : ""
                let publisher = sqlite3_column_text(statement, 4) != nil ? String(cString: sqlite3_column_text(statement, 4)) : ""
                let pDate = sqlite3_column_text(statement, 5) != nil ? String(cString: sqlite3_column_text(statement, 5)) : ""
                let pPlace = sqlite3_column_text(statement, 6) != nil ? String(cString: sqlite3_column_text(statement, 6)) : ""
                let price = sqlite3_column_double(statement, 7)
                let picture = sqlite3_column_text(statement, 8) != nil ? String(cString: sqlite3_column_text(statement, 8)) : ""
                let description = sqlite3_column_text(statement, 9) != nil ? String(cString: sqlite3_column_text(statement, 9)) : ""
                
                book = Book(
                    UserId: userId,
                    BookId: bookId,
                    ISBN: isbn,
                    bName: bName,
                    Author: author,
                    publisher: publisher,
                    pDate: pDate,
                    pPlace: pPlace,
                    price: price,
                    picture: picture,
                    description: description
                )
            }
        } else {
            print("Failed to prepare the fetch book statement")
        }
        
        sqlite3_finalize(statement)
        return book
    }
    
    func removeBookFromUser(userId: Int, bookId: Int) -> Bool {
        executeQuery(query: "BEGIN TRANSACTION;")
        var success = true
        
        let removeBookQuery = "DELETE FROM UserBooks WHERE UserId = ? AND BookId = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, removeBookQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(userId))
            sqlite3_bind_int(statement, 2, Int32(bookId))
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Failed to remove books from user")
                success = false
            }
        } else {
            print("Failed to remove a book statement from the user")
            success = false
        }
        
        sqlite3_finalize(statement)
        
        let removeStatusQuery = "DELETE FROM BookReadingStatus WHERE UserId = ? AND BookId = ?;"
        
        if sqlite3_prepare_v2(db, removeStatusQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(userId))
            sqlite3_bind_int(statement, 2, Int32(bookId))
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Failed to remove reading status")
                success = false
            }
        } else {
            print("Failed to prepare removing reading status statement")
            success = false
        }
        
        sqlite3_finalize(statement)
        
        let removeLabelsQuery = "DELETE FROM BookLabels WHERE UserId = ? AND BookId = ?;"
        
        if sqlite3_prepare_v2(db, removeLabelsQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(userId))
            sqlite3_bind_int(statement, 2, Int32(bookId))
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Failed to remove book labels")
                success = false
            }
        } else {
            print("Failed to prepare removing book labels statement")
            success = false
        }
        
        sqlite3_finalize(statement)
        
        if success {
            executeQuery(query: "COMMIT;")
        } else {
            executeQuery(query: "ROLLBACK;")
        }
        
        return success
    }
    
    func getBooksWithSimilarLabels(bookId: Int, userId: Int, excludeCurrentBook: Bool = true) -> [Book] {
        let currentBookLabels = getBookLabels(bookId: bookId, userId: userId).map { $0.id }
        
        if currentBookLabels.isEmpty {
            return []
        }
        
        let query = """
        SELECT DISTINCT b.BookId, b.ISBN, b.bName, b.Author, b.publisher, b.pDate, b.pPlace, b.price, b.picture, b.description, ub.UserId
        FROM Books b
        JOIN UserBooks ub ON b.BookId = ub.BookId
        JOIN BookLabels bl ON b.BookId = bl.BookId
        WHERE bl.LabelId IN (\(currentBookLabels.map { String($0) }.joined(separator: ",")))
        AND b.BookId != ?  -- Only current books are excluded, regardless of user ID
        LIMIT 5
        """
        
        var statement: OpaquePointer?
        var books: [Book] = []
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(bookId))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let bookId = Int(sqlite3_column_int(statement, 0))
                let isbn = String(cString: sqlite3_column_text(statement, 1))
                let bName = String(cString: sqlite3_column_text(statement, 2))
                
                let author: String
                if let authorText = sqlite3_column_text(statement, 3) {
                    author = String(cString: authorText)
                } else {
                    author = ""
                }
                
                let publisher: String
                if let publisherText = sqlite3_column_text(statement, 4) {
                    publisher = String(cString: publisherText)
                } else {
                    publisher = ""
                }
                
                let pDate: String
                if let pDateText = sqlite3_column_text(statement, 5) {
                    pDate = String(cString: pDateText)
                } else {
                    pDate = ""
                }
                
                let pPlace: String
                if let pPlaceText = sqlite3_column_text(statement, 6) {
                    pPlace = String(cString: pPlaceText)
                } else {
                    pPlace = ""
                }
                
                let price = sqlite3_column_double(statement, 7)
                
                let picture: String
                if let pictureText = sqlite3_column_text(statement, 8) {
                    picture = String(cString: pictureText)
                } else {
                    picture = ""
                }
                
                let description: String
                if let descriptionText = sqlite3_column_text(statement, 9) {
                    description = String(cString: descriptionText)
                } else {
                    description = ""
                }
                
                let userId = Int(sqlite3_column_int(statement, 10))
                
                let book = Book(
                    UserId: userId,
                    BookId: bookId,
                    ISBN: isbn,
                    bName: bName,
                    Author: author,
                    publisher: publisher,
                    pDate: pDate,
                    pPlace: pPlace,
                    price: price,
                    picture: picture,
                    description: description
                )
                
                books.append(book)
            }
        } else {
            print("Failed to obtain a similar book statement")
        }
        
        sqlite3_finalize(statement)

        if books.isEmpty && excludeCurrentBook {
            print("No recommended books found, consider adding more books or adding the same label to existing books")
        }
        
        return books
    }
    
    // MARK: - Reading Related
    
    func setBookReadingStatus(bookId: Int, userId: Int, status: ReadingStatus, finishDate: Date? = nil) -> Bool {
        let upsertQuery = """
        INSERT INTO BookReadingStatus (BookId, UserId, Status, FinishDate)
        VALUES (?, ?, ?, ?)
        ON CONFLICT(BookId, UserId) DO UPDATE SET 
            Status = excluded.Status,
            FinishDate = excluded.FinishDate;
        """
        
        var statement: OpaquePointer?
        var success = false
        
        if sqlite3_prepare_v2(db, upsertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(bookId))
            sqlite3_bind_int(statement, 2, Int32(userId))
            sqlite3_bind_int(statement, 3, Int32(status.rawValue))
            
            if let date = finishDate {
                let dateString = DateFormatter.yyyyMMdd.string(from: date)
                sqlite3_bind_text(statement, 4, (dateString as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_null(statement, 4)
            }
            
            if sqlite3_step(statement) == SQLITE_DONE {
                success = true
            }
        }
        
        sqlite3_finalize(statement)
        return success
    }

    func getBookReadingStatus(bookId: Int, userId: Int) -> (status: ReadingStatus, finishDate: Date?) {
        let query = "SELECT Status, FinishDate FROM BookReadingStatus WHERE BookId = ? AND UserId = ?;"
        var statement: OpaquePointer?
        var status = ReadingStatus.hopeToRead
        var finishDate: Date? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(bookId))
            sqlite3_bind_int(statement, 2, Int32(userId))
            
            if sqlite3_step(statement) == SQLITE_ROW {
                status = ReadingStatus(rawValue: Int(sqlite3_column_int(statement, 0))) ?? .hopeToRead
                
                if let dateText = sqlite3_column_text(statement, 1) {
                    let dateString = String(cString: dateText)
                    finishDate = DateFormatter.yyyyMMdd.date(from: dateString)
                }
            }
        }
        
        sqlite3_finalize(statement)
        return (status, finishDate)
    }
    
    
    func getUserReadBooks(userId: Int) -> [Book] {
        return getBooksWithReadingStatus(userId: userId, status: .alreadyRead)
    }
    
    func getUserHopeToReadBooks(userId: Int) -> [Book] {
        return getBooksWithReadingStatus(userId: userId, status: .hopeToRead)
    }
    
    private func getBooksWithReadingStatus(userId: Int, status: ReadingStatus) -> [Book] {
        let query = """
        SELECT b.BookId, b.ISBN, b.bName, b.Author, b.publisher, b.pDate, b.pPlace, b.price, b.picture, b.description
        FROM Books b
        JOIN UserBooks ub ON b.BookId = ub.BookId
        JOIN BookReadingStatus brs ON b.BookId = brs.BookId AND ub.UserId = brs.UserId
        WHERE brs.UserId = ? AND brs.Status = ?;
        """
        
        var statement: OpaquePointer?
        var books: [Book] = []
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(userId))
            sqlite3_bind_int(statement, 2, Int32(status.rawValue))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let bookId = Int(sqlite3_column_int(statement, 0))
                let isbn = String(cString: sqlite3_column_text(statement, 1))
                let bName = String(cString: sqlite3_column_text(statement, 2))
                let author = sqlite3_column_text(statement, 3) != nil ? String(cString: sqlite3_column_text(statement, 3)) : ""
                let publisher = sqlite3_column_text(statement, 4) != nil ? String(cString: sqlite3_column_text(statement, 4)) : ""
                let pDate = sqlite3_column_text(statement, 5) != nil ? String(cString: sqlite3_column_text(statement, 5)) : ""
                let pPlace = sqlite3_column_text(statement, 6) != nil ? String(cString: sqlite3_column_text(statement, 6)) : ""
                let price = sqlite3_column_double(statement, 7)
                let picture = sqlite3_column_text(statement, 8) != nil ? String(cString: sqlite3_column_text(statement, 8)) : ""
                let description = sqlite3_column_text(statement, 9) != nil ? String(cString: sqlite3_column_text(statement, 9)) : ""
                
                let book = Book(
                    UserId: userId,
                    BookId: bookId,
                    ISBN: isbn,
                    bName: bName,
                    Author: author,
                    publisher: publisher,
                    pDate: pDate,
                    pPlace: pPlace,
                    price: price,
                    picture: picture,
                    description: description
                )
                
                books.append(book)
            }
        } else {
            print("Failed to prepare getting books with reading status statement")
        }
        
        sqlite3_finalize(statement)
        return books
    }
    
    // MARK: - Label related methods
    
    func insertLabel(label: Label, userId: Int) -> Int64 {
        let insertLabelQuery = "INSERT INTO Labels (labelName, personalized, UserId) VALUES (?, ?, ?);"
        var statement: OpaquePointer?
        var labelId: Int64 = -1
        
        if sqlite3_prepare_v2(db, insertLabelQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (label.labelName as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, label.personalized ? 1 : 0)
            sqlite3_bind_int(statement, 3, Int32(userId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                labelId = sqlite3_last_insert_rowid(db)
            } else {
                print("Fail to insert the label")
            }
        } else {
            print("Failed to prepare to insert label statement")
        }
        
        sqlite3_finalize(statement)
        return labelId
    }
    
    func getUserLabels(userId: Int) -> [Label] {
        let getLabelsQuery = "SELECT id, labelName, personalized FROM Labels WHERE UserId = ?;"
        var statement: OpaquePointer?
        var labels: [Label] = []
        
        if sqlite3_prepare_v2(db, getLabelsQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(userId))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let labelName = String(cString: sqlite3_column_text(statement, 1))
                let personalized = sqlite3_column_int(statement, 2) != 0
                
                let label = Label(id: id, labelName: labelName, personalized: personalized)
                labels.append(label)
            }
        } else {
            print("Failed to get the label statement ready")
        }
        
        sqlite3_finalize(statement)
        return labels
    }
    
    func addLabelToBook(bookId: Int, labelId: Int, userId: Int) -> Bool {
        let addLabelQuery = "INSERT OR IGNORE INTO BookLabels (BookId, LabelId, UserId) VALUES (?, ?, ?);"
        var statement: OpaquePointer?
        var success = false
        
        if sqlite3_prepare_v2(db, addLabelQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(bookId))
            sqlite3_bind_int(statement, 2, Int32(labelId))
            sqlite3_bind_int(statement, 3, Int32(userId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                success = true
            } else {
                print("Failed to add label to book")
            }
        } else {
            print("Failed to prepare to add label to book statement")
        }
        
        sqlite3_finalize(statement)
        return success
    }
    
    func removeLabelFromBook(bookId: Int, labelId: Int, userId: Int) -> Bool {
        let removeLabelQuery = "DELETE FROM BookLabels WHERE BookId = ? AND LabelId = ? AND UserId = ?;"
        var statement: OpaquePointer?
        var success = false
        
        if sqlite3_prepare_v2(db, removeLabelQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(bookId))
            sqlite3_bind_int(statement, 2, Int32(labelId))
            sqlite3_bind_int(statement, 3, Int32(userId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                success = true
            } else {
                print("Failed to remove a label from a book")
            }
        } else {
            print("Failed to prepare a label removal statement from a book")
        }
        
        sqlite3_finalize(statement)
        return success
    }
    
    func getBookLabels(bookId: Int, userId: Int) -> [Label] {
        let getBookLabelsQuery = """
        SELECT l.id, l.labelName, l.personalized
        FROM Labels l
        JOIN BookLabels bl ON l.id = bl.LabelId
        WHERE bl.BookId = ? AND bl.UserId = ?;
        """
        var statement: OpaquePointer?
        var labels: [Label] = []
        
        print("Try to query the label for book ID: \(bookId), user ID: \(userId)")
        
        if sqlite3_prepare_v2(db, getBookLabelsQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(bookId))
            sqlite3_bind_int(statement, 2, Int32(userId))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                
                // Handle text columns securely
                let labelName: String
                if let textPtr = sqlite3_column_text(statement, 1) {
                    labelName = String(cString: textPtr)
                } else {
                    labelName = "Unnamed tag" // default
                    print("Warning: The name of tag ID \(id) is empty")
                }
                
                let personalized = sqlite3_column_int(statement, 2) != 0
                
                print("Loading label: ID=\(id), name=\(labelName), psersonalized=\(personalized)")
                
                let label = Label(id: id, labelName: labelName, personalized: personalized)
                labels.append(label)
            }
            
            if labels.isEmpty {
                print("No label found. The number of labels is 0")
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(db))
            print("Failed to get the book label statement ready: \(errorMsg)")
        }
        
        sqlite3_finalize(statement)
        return labels
    }
    
    //Add a method to check label associations directly from the database
    func checkBookLabelAssociations(bookId: Int) {
        print("Check the label association directly for book ID \(bookId)")
        
        let query = """
        SELECT bl.id, bl.BookId, bl.LabelId, bl.UserId, l.labelName
        FROM BookLabels bl
        LEFT JOIN Labels l ON bl.LabelId = l.id
        WHERE bl.BookId = ?;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(bookId))
            
            var found = false
            while sqlite3_step(statement) == SQLITE_ROW {
                found = true
                let id = Int(sqlite3_column_int(statement, 0))
                let bookId = Int(sqlite3_column_int(statement, 1))
                let labelId = Int(sqlite3_column_int(statement, 2))
                let userId = Int(sqlite3_column_int(statement, 3))
                
                // 安全处理文本列
                let labelName: String
                if let textPtr = sqlite3_column_text(statement, 4) {
                    labelName = String(cString: textPtr)
                } else {
                    labelName = "Unknown label"
                    print("Warning: Label name associated with ID \(id) is empty")
                }
                
                print("Association record: ID=\(id), bookID=\(bookId), labelID=\(labelId), userID=\(userId), labelName=\(labelName)")
            }
            
            if !found {
                print("No label association for the book ID \(bookId) was found in the database")
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(db))
            print("Failed to prepare to check the book label association statement: \(errorMsg)")
        }
        
        sqlite3_finalize(statement)
    }
    
    func getBooksWithLabel(labelId: Int, userId: Int) -> [Book] {
        let getBooksQuery = """
        SELECT b.BookId, b.ISBN, b.bName, b.Author, b.publisher, b.pDate, b.pPlace, b.price, b.picture, b.description
        FROM Books b
        JOIN BookLabels bl ON b.BookId = bl.BookId
        WHERE bl.LabelId = ? AND bl.UserId = ?;
        """
        var statement: OpaquePointer?
        var books: [Book] = []
        
        if sqlite3_prepare_v2(db, getBooksQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(labelId))
            sqlite3_bind_int(statement, 2, Int32(userId))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let bookId = Int(sqlite3_column_int(statement, 0))
                let isbn = String(cString: sqlite3_column_text(statement, 1))
                let bName = String(cString: sqlite3_column_text(statement, 2))
                let author = sqlite3_column_text(statement, 3) != nil ? String(cString: sqlite3_column_text(statement, 3)) : ""
                let publisher = sqlite3_column_text(statement, 4) != nil ? String(cString: sqlite3_column_text(statement, 4)) : ""
                let pDate = sqlite3_column_text(statement, 5) != nil ? String(cString: sqlite3_column_text(statement, 5)) : ""
                let pPlace = sqlite3_column_text(statement, 6) != nil ? String(cString: sqlite3_column_text(statement, 6)) : ""
                let price = sqlite3_column_double(statement, 7)
                let picture = sqlite3_column_text(statement, 8) != nil ? String(cString: sqlite3_column_text(statement, 8)) : ""
                let description = sqlite3_column_text(statement, 9) != nil ? String(cString: sqlite3_column_text(statement, 9)) : ""
                
                let book = Book(
                    UserId: userId,
                    BookId: bookId,
                    ISBN: isbn,
                    bName: bName,
                    Author: author,
                    publisher: publisher,
                    pDate: pDate,
                    pPlace: pPlace,
                    price: price,
                    picture: picture,
                    description: description
                )
                
                books.append(book)
            }
        } else {
            print("Failed to get the labeled book statement ready")
        }
        
        sqlite3_finalize(statement)
        return books
    }
    
    func deleteLabel(id: Int, userId: Int) -> Bool {
        let deleteLabelQuery = "DELETE FROM Labels WHERE id = ? AND UserId = ?;"
        var statement: OpaquePointer?
        var success = false
        
        if sqlite3_prepare_v2(db, deleteLabelQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            sqlite3_bind_int(statement, 2, Int32(userId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                success = true
            } else {
                print("Fail to delete the label")
            }
        } else {
            print("Failed to prepare to delete a label statement")
        }
        
        sqlite3_finalize(statement)
        return success
    }
    
    // Get all system tags (personalized = false, for all users)
    func getSystemLabels() -> [Label] {
        let query = "SELECT id, labelName, personalized FROM Labels WHERE personalized = 0;"
        var statement: OpaquePointer?
        var labels: [Label] = []
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let labelName = String(cString: sqlite3_column_text(statement, 1))
                let personalized = sqlite3_column_int(statement, 2) != 0
                
                let label = Label(id: id, labelName: labelName, personalized: personalized)
                labels.append(label)
            }
        } else {
            print("Failed to obtain the system label statement")
        }
        
        sqlite3_finalize(statement)
        return labels
    }
    
    // Gets all tags available to the specified user (system tags + user-defined tags)
    func getAllAvailableLabels(userId: Int) -> [Label] {
        let query = """
        SELECT id, labelName, personalized FROM Labels 
        WHERE personalized = 0 OR (personalized = 1 AND UserId = ?);
        """
        var statement: OpaquePointer?
        var labels: [Label] = []
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(userId))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let labelName = String(cString: sqlite3_column_text(statement, 1))
                let personalized = sqlite3_column_int(statement, 2) != 0
                
                let label = Label(id: id, labelName: labelName, personalized: personalized)
                labels.append(label)
            }
        } else {
            print("Failed to get the available label statement ready")
        }
        
        sqlite3_finalize(statement)
        return labels
    }
    
    func getLabelByName(name: String) -> Label? {
        let getLabelQuery = "SELECT id, labelName, personalized FROM Labels WHERE labelName = ?;"
        var statement: OpaquePointer?
        var label: Label? = nil
        
        if sqlite3_prepare_v2(db, getLabelQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let labelName = String(cString: sqlite3_column_text(statement, 1))
                let personalized = sqlite3_column_int(statement, 2) != 0
                
                label = Label(id: id, labelName: labelName, personalized: personalized)
            }
        } else {
            print("Failed to obtain a label statement by name")
        }
        
        sqlite3_finalize(statement)
        return label
    }
    
    func labelExists(name: String) -> Bool {
        let checkQuery = "SELECT COUNT(*) FROM Labels WHERE labelName = ?;"
        var statement: OpaquePointer?
        var exists = false
        
        if sqlite3_prepare_v2(db, checkQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let count = sqlite3_column_int(statement, 0)
                exists = count > 0
            }
        } else {
            print("Failed to prepare a statement to check the existence of a label")
        }
        
        sqlite3_finalize(statement)
        return exists
    }
    
    func updateLabelName(id: Int, newName: String, userId: Int) -> Bool {
        // Make sure to update only tags created by the user (personalized = true)
        let updateLabelQuery = "UPDATE Labels SET labelName = ? WHERE id = ? AND UserId = ? AND personalized = 1;"
        var statement: OpaquePointer?
        var success = false
        
        if sqlite3_prepare_v2(db, updateLabelQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (newName as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(id))
            sqlite3_bind_int(statement, 3, Int32(userId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                success = true
            } else {
                print("Fail to update the label name")
            }
        } else {
            print("Failed to prepare the updating label name statement")
        }
        
        sqlite3_finalize(statement)
        return success
    }

    func removeAllBookLabelAssociations(labelId: Int, userId: Int) -> Bool {
        let removeLabelQuery = "DELETE FROM BookLabels WHERE LabelId = ? AND UserId = ?;"
        var statement: OpaquePointer?
        var success = false
        
        if sqlite3_prepare_v2(db, removeLabelQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(labelId))
            sqlite3_bind_int(statement, 2, Int32(userId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                success = true
            } else {
                print("Failed to delete the label association. Procedure")
            }
        } else {
            print("Failed to delete the label association statement.")
        }
        
        sqlite3_finalize(statement)
        return success
    }

    private func createDefaultSystemLabels() {
        // Check whether the system label exists
        let checkQuery = "SELECT COUNT(*) FROM Labels WHERE personalized = 0;"
        var statement: OpaquePointer?
        var count = 0
        
        if sqlite3_prepare_v2(db, checkQuery, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                count = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)

        if count == 0 {
            let defaultLabels = ["novel", "short story", "essay", "poems", "play"]
            
            for labelName in defaultLabels {
                // Use 0 as the UserId of the system label
                let insertQuery = "INSERT INTO Labels (labelName, personalized, UserId) VALUES (?, ?, 0);"
                var insertStatement: OpaquePointer?
                
                if sqlite3_prepare_v2(db, insertQuery, -1, &insertStatement, nil) == SQLITE_OK {
                       sqlite3_bind_text(insertStatement, 1, (labelName as NSString).utf8String, -1, nil)
                       sqlite3_bind_int(insertStatement, 2, 0)
               
                    if sqlite3_step(insertStatement) != SQLITE_DONE {
                        let errorMessage = String(cString: sqlite3_errmsg(db))
                        print("Fail to insert the label: \(labelName) - error: \(errorMessage)")
                    }
                } else {
                    let errorMessage = String(cString: sqlite3_errmsg(db))
                    print("Fail to prepare: \(errorMessage)")
                }
                
                sqlite3_finalize(insertStatement)
            }
        }
    }
    
    public func ensureSystemLabelsExist() {
        createDefaultSystemLabels()
    }
    
    func getReadingStatusOptions() -> [String] {
        return [ReadingStatus.hopeToRead.description, ReadingStatus.alreadyRead.description]
    }
}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
