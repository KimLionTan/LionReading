//
//  DetailRow.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.bold)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .font(.body)
                .multilineTextAlignment(.trailing)
        }
    }
}
