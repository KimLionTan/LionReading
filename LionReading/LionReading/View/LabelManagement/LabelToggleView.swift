//
//  LabelToggleView.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct LabelToggleView: View {
    let label: Label
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: label.personalized ? "label" : "lock.fill")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : label.personalized ? .orange : .gray)
                    .padding(.trailing, 4)
                
                Text(label.labelName)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.orange : Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
