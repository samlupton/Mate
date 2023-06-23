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
    var username: String
    var profileImage: String
    @State var uid: String
    @State private var searchOtherUserUID: [(String)] = []
    @State private var showingFollowersView = false
    @State private var showingFollowingView = false
    @State private var numFollowers: Int = 0
    @State private var numFollowing: Int = 0
    @State private var otherUserInfo: [(username: String, profileImage: String, uid: String)] = []
    @State private var selectedUser: (username: String, profileImage: String, uid: String)? = nil
    @State private var gotonextpage = false
    @State private var openBetsTabisSelected = true
    @State private var highlightsTabisSelected = false
    @State private var badgesTabisSelected = false
    
    
    var body: some View {
        VStack {
            HStack {
                WebImage(url: URL(string: profileImage))
                    .placeholder(Image(systemName: "person.circle"))
                    .resizable()
                    .frame(width: 82, height: 84)
                    .clipShape(Circle())
                    .foregroundColor(Color.black)
                    .clipped()
                    .background(Color.gray)
                    .clipShape(Circle())
                    .padding(.horizontal)
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
            HStack {
                VStack {
                    HStack {
                        Text("John Doe")
                            .bold()
                            .padding(.bottom, 0.5)
                        Spacer()
                    }
                    HStack {
                        Text("This is a bio that can only be 50 letters in length")
                            .font(.body)
                        Spacer()
                    }
                    
                }
                Spacer()
                Button(action: {
                }) {
                    Image(systemName: "text.bubble")
                        .font(.system(size:25))
                }
                Spacer()
            }.padding(.horizontal)
            
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
            HStack {
                Button(action: {
                    withAnimation {
                        openBetsTabisSelected = true
                        highlightsTabisSelected = false
                        badgesTabisSelected = false
                    }
                }) {
                    Text("Open Bets")
                        .font(.system(size:18))
                        .foregroundColor(Color.black)
                        .underline(openBetsTabisSelected)
                    
                }.padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue.opacity(0.0))
                    )
                Spacer()
                Button(action: {
                    withAnimation {
                        openBetsTabisSelected = false
                        highlightsTabisSelected = true
                        badgesTabisSelected = false
                        
                    }
                }) {
                    Text("Highlights")
                        .font(.system(size:18))
                        .foregroundColor(Color.black)
                        .underline(highlightsTabisSelected)
                }.padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue.opacity(0.0))
                    )
                Spacer()
                Button(action: {
                    withAnimation {
                        openBetsTabisSelected = false
                        highlightsTabisSelected = false
                        badgesTabisSelected = true
                    }
                }) {
                    Text("Badges")
                        .font(.system(size:18))
                        .foregroundColor(Color.black)
                        .underline(badgesTabisSelected)
                    
                }.padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue.opacity(0.0))
                    )
            }
            .padding(.horizontal, 0)
            Spacer()
        }.onAppear {
            fetchNumFollowers()
            fetchNumFollowing()
            
        }
        .navigationBarTitle(Text(username.lowercased()), displayMode: .inline)
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
    
    func fetchNumFollowers() {
        
        let db = Firestore.firestore()
        let followingCollection = db.collection("Users").document(getOtherUsersUID()).collection("Followers")
        
        followingCollection.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching followers: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else {
                print("Snapshot is nil")
                return
            }
            
            let count = snapshot.documents.count
            print("Number of followers: \(count)")
            
            // Update the state variable on the main queue
            DispatchQueue.main.async {
                self.numFollowers = count
            }
        }
    }
    
    func fetchNumFollowing() {
        
        let db = Firestore.firestore()
        let followingCollection = db.collection("Users").document(getOtherUsersUID()).collection("Following")
        
        followingCollection.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching followers: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else {
                print("Snapshot is nil")
                return
            }
            
            let count = snapshot.documents.count
            print("Number of followers: \(count)")
            
            // Update the state variable on the main queue
            DispatchQueue.main.async {
                self.numFollowing = count
            }
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
        OtherUserProfileView(username: "John", profileImage: "Image", uid: "my_uid")
    }
}
