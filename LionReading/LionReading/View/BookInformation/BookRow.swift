//
//  BookRow.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct BookRow: View {
    let book: Book
    
    var body: some View {
        HStack {
            // Can add book cover pictures
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
                .frame(width: 50, height: 70)
            } else {
                Image(systemName: "book")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 70)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading) {
                Text(book.bName)
                    .font(.headline)
                
                Text(book.Author)
                    .font(.subheadline)
                
                if !book.publisher.isEmpty {
                    Text(book.publisher)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
