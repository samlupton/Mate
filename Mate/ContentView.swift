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
    @State private var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")

    var body: some View {
        VStack {
            if isLoggedIn {
                TabView {
                    FeedView()
                        .tabItem {
                            Label("Feed", systemImage: "house")
                                .foregroundColor(.black)
                        }
                    SearchView()
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                                .foregroundColor(.black)
                               
                        }
                    PostView()
                        .tabItem {
                            Label("Place", systemImage: "plus.circle")
                                .foregroundColor(.black)
                        }
                    ProfileView(isLoggedIn: $isLoggedIn)
                        .tabItem {
                            Label("Profile", systemImage: "person")
                                .foregroundColor(.black)
                        }
                }
                .accentColor(Color("PrimaryGold"))
                .background(Color.white).opacity(1)
            } else {
                WelcomeScreen().navigationBarBackButtonHidden()
            }
        }
        .onAppear(perform: {
            getData()
        })
    }
    func getData() {
        isLoggedIn =  UserDefaults.standard.bool(forKey: "isLoggedIn")
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
