//
//  ActionButtonsView.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct ActionButtonsView: View {
    let saveAction: () -> Void
    let clearAction: () -> Void
    
    var body: some View {
        HStack {
            Button(action: saveAction) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Add to my shelf")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Button(action: clearAction) {
                HStack {
                    Image(systemName: "xmark.circle")
                    Text("Clear")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.orange)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.orange, lineWidth: 1)
                )
            }
        }
        .padding(.top, 10)
    }
}
