//
//  SearchView.swift
//  Mate
//
//  Created by Samuel Lupton on 5/29/23.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

//struct SearchView: View {
//    @State private var searchText = ""
//    @State private var searchResults: [(username: String, profileImage: String)] = [] // List of search results
//
//    var body: some View {
//        VStack {
//            HStack {
//                TextField("Search users", text: $searchText)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//
//                Button(action: {
//                    searchUsers()
//
//                }) {
//                    Image(systemName: "magnifyingglass")
//                        .font(.body)
//                        .frame(width: 2, height: 2)
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.gray)
//                        .cornerRadius(30)
//                }.padding()
//            }
//
//            List(searchResults, id: \.username) { result in
//                HStack {
//                    WebImage(url: URL(string: result.profileImage))
//                        .placeholder(Image(systemName: "person.circle"))
//                        .resizable()
//                        .frame(width: 40, height: 40)
//                        .clipShape(Circle())
//                        .foregroundColor(Color.black)
//                        .foregroundColor(Color.black)
//
//                    Text(result.username)
//                        .textCase(.lowercase)
//                }
//            }
//        }.navigationBarHidden(true)
//
//    }
//
//    private func searchUsers() {
//        guard !searchText.isEmpty else {
//            return
//        }
//
//        // Search for users in Firebase based on the entered text
//        let usersRef = Firestore.firestore().collection("Users")
//
//        usersRef.whereField("username", isEqualTo: searchText)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("Error searching for users: \(error.localizedDescription)")
//                    return
//                }
//
//                guard let documents = snapshot?.documents else {
//                    print("No user documents found.")
//                    return
//                }
//
//                self.searchResults = documents.compactMap { document in
//                    guard let username = document.data()["username"] as? String,
//                          let profileImage = document.data()["profileImageURL"] as? String else {
//                        return nil
//                    }
//
//                    return (username: username, profileImage: profileImage)
//                }
//            }
//    }
//}


struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults: [(username: String, profileImage: String)] = [] // List of search results
    
    var body: some View {
        VStack {
            HStack {
                TextField("Search users", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    searchUsers()
                    
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.body)
                        .frame(width: 2, height: 2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(30)
                }.padding()
            }
            List {
                ForEach(searchResults, id: \.username) { result in
                    NavigationLink(destination: OtherUserProfileView(username: result.username)) {
                        HStack {
                            WebImage(url: URL(string: result.profileImage))
                                .placeholder(Image(systemName: "person.circle"))
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .foregroundColor(Color.black)
                                .foregroundColor(Color.black)
                            
                            Text(result.username)
                                .textCase(.lowercase)
                        }
                    }
                }
            }
        }.navigationBarHidden(true)

    }
    
    private func searchUsers() {
        guard !searchText.isEmpty else {
            return
        }
        
        let usersRef = Firestore.firestore().collection("Users")
        
        usersRef.whereField("username", isEqualTo: searchText)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error searching for users: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No user documents found.")
                    return
                }
                
                self.searchResults = documents.compactMap { document in
                    guard let username = document.data()["username"] as? String,
                          let profileImage = document.data()["profileImageURL"] as? String else {
                        return nil
                    }
                    
                    return (username: username, profileImage: profileImage)
                }
            }
    }
}




struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
