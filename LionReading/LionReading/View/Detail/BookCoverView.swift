//
//  BookCoverView.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct BookCoverView: View {
    let imageURLString: String?
    
    var body: some View {
        Group {
            if let urlString = imageURLString, !urlString.isEmpty, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        defaultCoverImage
                    @unknown default:
                        defaultCoverImage
                    }
                }
            } else {
                defaultCoverImage
            }
        }
    }
    
    var defaultCoverImage: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(
                Image(systemName: "book.closed")
                    .foregroundColor(.gray)
            )
    }
}
