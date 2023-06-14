//
//  OtherUserProfileView.swift
//  Mate
//
//  Created by Samuel Lupton on 5/30/23.
//
import Firebase
import SwiftUI
import SDWebImageSwiftUI

struct OtherUserProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    var username: String
    var profileImage: String
    @State var newFollower: String = ""
    @State var uid: String
    @State private var searchOtherUserUID: [(String)] = []
    @State private var showingFollowersView = false
    @State private var showingFollowingView = false
    @State private var otherUserInfo: [(username: String, profileImage: String, uid: String)] = []
    @State private var selectedUser: (username: String, profileImage: String, uid: String)? = nil
    @State private var gotonextpage = false


    var body: some View {
        VStack {
            HStack (spacing: 16) {
                Spacer()
                Button(action: {
                    fetchAllFollowingUsernamesInfo { usernames in }
                    showingFollowersView = true
                }) {
                    HStack {
                        VStack {
                            Text("Following")
                                .font(.caption)
                                .foregroundColor(.black)
                            Text("10k")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                    }
                }.fullScreenCover(isPresented: $showingFollowingView) {
                    NavigationView {
                        List(otherUserInfo, id: \.username) { userInfo in
                            NavigationLink(destination: OtherUserProfileView(username: userInfo.username, profileImage: userInfo.profileImage, uid: userInfo.uid)) {
                                HStack {
                                    WebImage(url: URL(string: userInfo.profileImage))
                                        .placeholder(Image(systemName: "person.circle"))
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                        .foregroundColor(Color.black)

                                    Text(userInfo.username)
                                        .textCase(.lowercase)
                                }
                            }
                        }
                        .foregroundColor(Color.black)
                        .navigationBarItems(leading: Button(action: {
                                    showingFollowingView = false
                                }) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(Color.black)
                                })
                        .navigationTitle(Text("Following"))
                    }
                }
                Spacer()
                VStack {
                    WebImage(url: URL(string: profileImage))
                        .resizable()
                        .frame(width: 82, height: 84)
                        .clipShape(Circle())
                        .foregroundColor(Color.black)
                        .clipped()
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        .padding()
                        .foregroundColor(Color.black)
                }
                Spacer()
                Button(action: {
                    fetchAllFollowersUsernamesInfo { usernames in }
                    showingFollowingView = true
                }) {
                    HStack {
                        VStack {
                            Text("Followers")
                                .font(.caption)
                                .foregroundColor(.black)
                            Text("5k")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                    }
                }
                .fullScreenCover(isPresented: $showingFollowersView) {
                    NavigationView {
                        List(otherUserInfo, id: \.username) { userInfo in
                            NavigationLink(destination: OtherUserProfileView(username: userInfo.username, profileImage: userInfo.profileImage, uid: userInfo.uid)) {
                                HStack {
                                    WebImage(url: URL(string: userInfo.profileImage))
                                        .placeholder(Image(systemName: "person.circle"))
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                        .foregroundColor(Color.black)

                                    Text(userInfo.username)
                                        .textCase(.lowercase)
                                }
                            }
                        }
                        .foregroundColor(Color.black)
                        .navigationBarItems(leading: Button(action: {
                                    showingFollowersView = false
                                }) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(Color.black)
                                })
                        .navigationTitle(Text("Following"))
                    }
                }
                Spacer()
            }
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(Color("primarycolor").opacity(0.25))
            )
            .padding(.horizontal)
            Button {
                updateFollowerStatus()
                updateFollowingStatus()
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle")
                } .frame(maxWidth: .infinity)

            }
            .padding(.horizontal)
            .buttonStyle(.bordered)
            .tint(.black)
            Spacer()
        }

        .navigationBarTitle(Text(username.lowercased()), displayMode: .inline)
        .textCase(.lowercase)
        .navigationBarItems(leading: backButton)
        .accentColor(.black)
        .navigationBarBackButtonHidden(true)
    }

    func fetchAllFollowingUsernamesInfo(completion: @escaping ([String]) -> Void) {

        let db = Firestore.firestore()
        let followingCollection = db.collection("Users").document(getOtherUsersUID()).collection("Following")

        followingCollection.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching following documents: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            var usernames: [String] = []
            var updatedOtherUserInfo: [(username: String, profileImage: String, uid: String)] = []

            let group = DispatchGroup()

            for document in documents {
                let uid = document.data()["uid"] as? String ?? ""
                group.enter()

                searchOtherUsersProfileImagesAndUsernames(uid: uid) { fetchedUsername, fetchedProfileImage, fetchuid in
                    updatedOtherUserInfo.append((username: fetchedUsername, profileImage: fetchedProfileImage, uid: fetchuid))
                    usernames.append(fetchedUsername)
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.otherUserInfo = updatedOtherUserInfo
                completion(usernames)
            }
        }
    }

    func fetchAllFollowersUsernamesInfo(completion: @escaping ([String]) -> Void) {

        let db = Firestore.firestore()
        let followingCollection = db.collection("Users").document(getOtherUsersUID()).collection("Followers")

        followingCollection.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching following documents: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            var usernames: [String] = []
            var updatedOtherUserInfo: [(username: String, profileImage: String, uid: String)] = []

            let group = DispatchGroup()

            for document in documents {
                let uid = document.data()["uid"] as? String ?? ""
                group.enter()

                searchOtherUsersProfileImagesAndUsernames(uid: uid) { fetchedUsername, fetchedProfileImage, fetchuid in
                    updatedOtherUserInfo.append((username: fetchedUsername, profileImage: fetchedProfileImage, uid: fetchuid))
                    usernames.append(fetchedUsername)
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.otherUserInfo = updatedOtherUserInfo
                completion(usernames)
            }
        }
    }

    private func searchOtherUsersProfileImagesAndUsernames(uid: String, completion: @escaping (String, String, String) -> Void) {
        let usersRef = Firestore.firestore().collection("Users")

        usersRef.whereField("uid", isEqualTo: uid).getDocuments { snapshot, error in
            if let error = error {
                print("Error searching for users: \(error.localizedDescription)")
                completion("", "", "")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No user documents found.")
                completion("", "", "")
                return
            }

            if let document = documents.first,
               let username = document.data()["username"] as? String,
               let uid = document.data()["uid"] as? String,
               let profileImage = document.data()["profileImageURL"] as? String {

                print(username + " or " + profileImage)
                completion(username, profileImage, uid)
            } else {
                completion("", "", "")
            }
        }
    }

    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .imageScale(.large)
        }
    }

    private func updateFollowingStatus() {
        let db = Firestore.firestore()

        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }

        let followerRef = db.collection("Users").document(uid).collection("Following")

        // Query to check if the follower already exists
        followerRef.whereField("uid", isEqualTo: getOtherUsersUID())
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error querying documents: \(error)")
                    return
                }

                if let documents = querySnapshot?.documents, !documents.isEmpty {
                    for document in documents {
                        document.reference.delete { error in
                            if let error = error {
                                print("Error removing document: \(error)")
                            } else {
                                print("User unfollowed successfully!")
                            }
                        }
                    }
                } else {
                    let userData = ["uid": getOtherUsersUID()]
                    followerRef.addDocument(data: userData) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            print("User followed successfully!")
                        }
                    }
                }
            }
    }

    private func updateFollowerStatus() {
        let db = Firestore.firestore()

        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }

        let followerRef = db.collection("Users").document(getOtherUsersUID()).collection("Followers")

        // Query to check if the follower already exists
        followerRef.whereField("uid", isEqualTo: uid)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error querying documents: \(error)")
                    return
                }

                if let documents = querySnapshot?.documents, !documents.isEmpty {
                    for document in documents {
                        document.reference.delete { error in
                            if let error = error {
                                print("Error removing document: \(error)")
                            } else {
                                print("User unfollowed successfully!")
                            }
                        }
                    }
                } else {
                    let userData = ["uid": uid]
                    followerRef.addDocument(data: userData) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            print("User followed successfully!")
                        }
                    }
                }
            }
    }

    private func getOtherUsersUID() -> String {

        let usersRef = Firestore.firestore().collection("Users")

        usersRef.whereField("username", isEqualTo: username)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error searching for users: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No user documents found.")
                    return
                }

                self.searchOtherUserUID = documents.compactMap { document in
                    guard  let uid = document.data()["uid"] as? String else {
                        return ""
                    }
                    return uid
                }
            }
        return uid
    }
}

struct OtherUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        @State var username: String = ""
        @State var profileImage: String = ""
        @State var uid: String = ""

        OtherUserProfileView(username: username, profileImage: profileImage, uid: uid)
    }
}
