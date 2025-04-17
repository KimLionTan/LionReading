//
//  Background.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct Background: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.orange.opacity(0.4), // Top right orange, 40% trans
                Color.yellow.opacity(0.4)  // Bottom left yellow, 40% trans
            ]),
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
        .edgesIgnoringSafeArea(.all) // fill the entire screen
    }
}

#Preview {
    Background()
}
