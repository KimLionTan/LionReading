//
//  CircleImage.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct CircleImage: View {
    let imageURL: String
    let defaultImage: String = "dHeadPor"
    let size: CGFloat
    
    init(imageURL: String, size: CGFloat = 90) {
        self.imageURL = imageURL
        self.size = size
    }
    
    var body: some View {
        Group {
            if !imageURL.isEmpty, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(defaultImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            } else {
                Image(defaultImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 4))
        .shadow(radius: 10)
    }
}

#Preview {
    CircleImage(imageURL: "dHeadPor")
}
