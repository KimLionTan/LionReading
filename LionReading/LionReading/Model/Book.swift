//
//  Book.swift
//  LionReading
//
//  Created by TanJianing
//

import Foundation

struct Book: Hashable,Codable {
    var UserId:Int
    var BookId: Int
    var ISBN: String
    var bName: String
    var Author: String
    var publisher: String
    var pDate:String
    var pPlace: String
    var price: Double
    var picture: String
    var description: String
    
}
