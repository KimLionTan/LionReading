//
//  HeadLine.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct HeadLine: View {
    var body: some View {
        HStack{
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
            Text("Lion Reading!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.red)
                .font(.system(size: 12, weight: .light, design: .serif))
                    .italic()
        }
    }
}

#Preview {
    HeadLine()
}
