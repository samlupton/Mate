//
//  MateApp.swift
//  Mate
//
//  Created by Samuel Lupton on 5/28/23.
//

import SwiftUI
import Firebase
@main
struct MateApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            WelcomeScreen()
        }
    }
}
