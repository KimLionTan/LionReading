//
//  BookInfoView.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct BookInfoView: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(book.bName)
                .font(.headline)
                .lineLimit(2)
            
            Text("Author: \(book.Author)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Publisher: \(book.publisher)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Published Date: \(book.pDate)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !book.pPlace.isEmpty {
                Text("Published Place: \(book.pPlace)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if book.price > 0 {
                Text("Price: ¥\(String(format: "%.2f", book.price))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
