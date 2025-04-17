//
//  FlowLayout.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

// Flow Layout Help View - for label display
struct FlowLayout<T: Identifiable, Content: View>: View {
    let items: [T]
    let spacing: CGFloat
    @ViewBuilder let content: (T) -> Content
    
    init(items: [T], spacing: CGFloat = 8, @ViewBuilder content: @escaping (T) -> Content) {
        self.items = items
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(self.items) { item in
                content(item)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                    .alignmentGuide(.leading) { d in
                        if abs(width - d.width) > geometry.size.width {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item.id == self.items.last?.id {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item.id == self.items.last?.id {
                            height = 0
                        }
                        return result
                    }
            }
        }
    }
}
