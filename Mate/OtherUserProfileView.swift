//
//  OtherUserProfileView.swift
//  Mate
//
//  Created by Samuel Lupton on 5/30/23.
//
import Firebase
import SwiftUI
import FirebaseFirestore
import SDWebImageSwiftUI

struct OtherUserProfileView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var newFollower: String = ""
    @State private var searchOtherUserUID: [(String)] = []
    @State private var showingFollowersView = false
    @State private var showingFollowingView = false
    @State private var otherUserInfo: [(username: String, profileImage: String, uid: String)] = []
    @State private var selectedUser: (username: String, profileImage: String, uid: String)? = nil
//    @State private var gotonextpage = false
    @State private var numFollowers: Int = 0
    @State private var numFollowing: Int = 0
    let username: String
    let profileImage: String
    let uid: String
    let userHelper: OtherUser
    
    init(username: String, profileImage: String, uid: String) {
        self.username = username
        self.profileImage = profileImage
        self.uid = uid
        self.userHelper = OtherUser(uid: uid) // Initialize userHelper in the init method
    }
    
    var body: some View {
        VStack {
            HStack {
                WebImage(url: URL(string: profileImage))
                    .resizable()
                    .frame(width: 82, height: 84)
                    .clipShape(Circle())
                    .foregroundColor(Color.black)
                    .clipped()
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    .padding()
                    .foregroundColor(Color.black)
                
                
                Spacer()
                HStack {
                    Spacer()
                    
                    HStack {
                        VStack {
                            Text("Winnings")
                                .font(.caption)
                                .foregroundColor(.black)
                                .lineLimit(1)
                            Text("$\(numFollowers)")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
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
                                                Text("\(numFollowers)")
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
                    Button(action: {
                                        fetchAllFollowingUsernamesInfo { usernames in }
                                        showingFollowersView = true
                                    }) {
                                        HStack {
                                            VStack {
                                                Text("Following")
                                                    .font(.caption)
                                                    .foregroundColor(.black)
                                                Text("\(numFollowing)")
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
                }
                
                Spacer()
                
            }
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
        }.onAppear {
            userHelper.fetchNumFollowers { count in
                numFollowers = count
                // Handle the fetched count
                print("Number of followers: \(count)")
            }
            userHelper.fetchNumFollowing { count in
                numFollowing = count
                // Handle the fetched count
                print("Number of following: \(count)")
            }
            OtherUser.getOtherUsersUID(username: username) { uid in
                // Handle the UID result here
                if let uid = uid {
                    // UID is available
                    print("UID: \(uid)")
                    print("Username: \(username)")
                } else {
                    // UID is nil
                    print("UID not found.")
                    print("No username")
                    
                }
            }
        }
        .navigationBarTitle(Text(username.lowercased()), displayMode: .inline)
        .textCase(.lowercase)
        .navigationBarItems(leading: backButton)
        .accentColor(.black)
        .navigationBarBackButtonHidden(true)
    }
    
    func fetchAllFollowingUsernamesInfo(completion: @escaping ([String]) -> Void) {
        
        let db = Firestore.firestore()
        let followingCollection = db.collection("Users").document(uid).collection("Following")
        
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
        let followingCollection = db.collection("Users").document(uid).collection("Followers")
        
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
                
                completion(username, profileImage, uid)
            } else {
                completion("", "", "")
            }
        }
    }
    
    private func updateFollowingStatus() {
        let db = Firestore.firestore()
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        let followingRef = db.collection("Users").document(uid).collection("Following")
        
        // Query to check if the user is already being followed
        followingRef.whereField("uid", isEqualTo: uid)
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
                    followingRef.addDocument(data: userData) { error in
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
        
        let followersRef = db.collection("Users").document(uid).collection("Followers")
        
        // Query to check if the user is already being followed
        followersRef.whereField("uid", isEqualTo: uid)
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
                    followersRef.addDocument(data: userData) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            print("User followed successfully!")
                        }
                    }
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
}

struct OtherUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        OtherUserProfileView(username: "John", profileImage: "profile.png", uid: "exampleUID")
    }
}

