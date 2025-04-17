//
//  LionReadingApp.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

@main
struct LionReadingApp: App {
    init() {
        UIView.appearance().tintColor = UIColor(Color.orange)
    }
    
    var body: some Scene {
        WindowGroup {
            Login()
                .tint(.orange)
        }
    }
}
