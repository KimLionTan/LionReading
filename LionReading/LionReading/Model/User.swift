//
//  User.swift
//  LionReading
//
//  Created by TanJianing on 2025/2/9.
//

import Foundation

struct User: Hashable,Codable,Identifiable {
    var id:Int
    var account: String
    var password: String
    var userName: String
    var headPort: String
    
    func withUpdatedUserName(_ newUserName: String) -> User {
        return User(id: self.id, account: self.account, password: self.password, userName: newUserName, headPort: self.headPort)
    }
        
    func withUpdatedHeadPort(_ newHeadPort: String) -> User {
        return User(id: self.id, account: self.account, password: self.password, userName: self.userName, headPort: newHeadPort)
    }
}
