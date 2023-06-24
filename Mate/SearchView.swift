//
//  SearchView.swift
//  Mate
//
//  Created by Samuel Lupton on 5/29/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import SDWebImageSwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults: [(username: String, profileImage: String, uid: String)] = []
//    private let userSearchHelper = UserSearchHelper()

    var body: some View {
        NavigationView {
            VStack {
                if searchText.isEmpty {
                        NewsView()
                    .padding(.top, 5)
                } else {
                    List {
                        ForEach(searchResults, id: \.username) { result in
                            NavigationLink(destination: OtherUserProfileView(username: result.username, profileImage: result.profileImage, uid: result.uid, bio: "")) {
                                HStack {
                                    WebImage(url: URL(string: result.profileImage))
                                        .placeholder(Image(systemName: "person.circle"))
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                        .foregroundColor(Color.black)

                                    Text(result.username)
                                        .textCase(.lowercase)
                                }
                            }
                        }
                    }
                }
            }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .disableAutocorrection(true)
                .onChange(of: searchText) { newValue in
                    searchUsers()
                }
        }
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
                          let uid = document.data()["uid"] as? String,
                          let profileImage = document.data()["profileImageURL"] as? String else {
                        return nil
                    }
                    print(uid)
                    return (username: username, profileImage: profileImage, uid: uid)
                }
            }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
