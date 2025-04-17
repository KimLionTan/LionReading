//
//  SearchBarView.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var isbn: String
    let searchAction: () -> Void
    
    var body: some View {
        HStack {
            TextField("Enter ISBN", text: $isbn)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            Button(action: searchAction) {
                Text("Search")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
}
