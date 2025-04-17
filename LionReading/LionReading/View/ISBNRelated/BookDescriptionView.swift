//
//  BookDescriptionView.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct BookDescriptionView: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Description")
                .font(.headline)
                .padding(.bottom, 4)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
