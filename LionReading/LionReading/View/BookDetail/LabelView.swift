//
//  LabelView.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct LabelView: View {
    let label: Label
    let isEditing: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            if !label.personalized {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            Text(label.labelName)
            
            if isEditing {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(label.personalized ? .red : .red)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(label.personalized ? Color.white.opacity(0.8) : Color.white.opacity(0.8))
        .foregroundColor(label.personalized ? .orange : .orange)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(label.personalized ? Color.orange.opacity(0.4) : Color.orange.opacity(0.4), lineWidth: 1)
        )
    }
}
