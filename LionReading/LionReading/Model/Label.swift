//
//  Label.swift
//  LionReading
//
//  Created by TanJianing.
//

import Foundation

struct Label: Hashable,Codable,Identifiable {
    var id:Int
    var labelName: String
    var personalized: Bool
}
