//
//  ContentView.swift
//  Mate
//
//  Created by Samuel Lupton on 5/28/23.
//

import SwiftUI
import SwiftyJSON
import SDWebImageSwiftUI
import WebKit
import Firebase
import FirebaseAuth

struct ContentView: View {

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoggedIn: Bool = true

    var body: some View {
        if isLoggedIn {
            TabView {
                FeedView()
                    .tabItem {
                        Label("Feed", systemImage: "globe.asia.australia")
                    }
                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                PostView()
                    .tabItem {
                        Label("Post", systemImage: "plus.app")
                    }
                LocalSellerView()
                    .tabItem {
                        Label("Referral", systemImage: "dollarsign.circle")
                    }
                ProfileView(isLoggedIn: $isLoggedIn)
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }
            }.accentColor(Color.gray).background(Color.white).opacity(1)
        } else {
            WelcomeScreen().navigationBarBackButtonHidden()
        }
    }
}

struct LocalSellerView: View {
    var body: some View {
        Text("Local Seller")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Book : Identifiable {

    var id : String
    var title : String
    var authors : String
    var desc : String
    var imurl : String
    var url : String
}
