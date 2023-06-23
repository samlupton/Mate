//
//  ProfileView.swift
//  Mate
//
//  Created by Samuel Lupton on 5/28/23.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import SDWebImageSwiftUI
import FirebaseFirestore

struct ProfileView: View {
    
    @State private var showAccountInfo = false
    @State private var showingFollowersView = false
    @State private var showingFolloweringView = false
    @State private var gotonextpage = false
    @State private var openBetsTabisSelected = true
    @State private var highlightsTabisSelected = false
    @State private var badgesTabisSelected = false
    @State private var numFollowers: Int = 0
    @State private var numFollowing: Int = 0
    @State private var selectedUser: (username: String, profileImage: String, uid: String)? = nil
    @State private var otherUserInfo: [(username: String, profileImage: String, uid: String)] = []
    
    @Binding var isLoggedIn: Bool
    @ObservedObject private var vm = MainViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Text("\(vm.user?.username ?? "User")")
                    .font(.title)
                    .bold()
                    .textCase(.lowercase)
                Spacer()
                Button(action: {
                    showAccountInfo = true
                }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size:25))
                        .foregroundColor(Color.black)
                }
                .sheet(isPresented: $showAccountInfo) {
                    AccountInfoView(isLoggedIn: $isLoggedIn)
                }
            }
            
            HStack {
                
                
                WebImage(url: URL(string: vm.user?.profileImageUrl  ?? ""))
                    .placeholder(Image(systemName: "person.circle"))
                    .resizable()
                    .frame(width: 82, height: 84)
                    .clipShape(Circle())
                    .foregroundColor(Color.black)
                    .clipped()
                    .background(Color.gray)
                    .clipShape(Circle())
                
                
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
                        showingFolloweringView = true
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
                    .sheet(isPresented: $showingFollowersView) {
                        NavigationView {
                            List(otherUserInfo, id: \.username) { userInfo in
                                Button(action: {
                                    selectedUser = userInfo
                                    gotonextpage = true
                                }) {
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
                            .navigationTitle(Text("Followers"))
                            .background(
                                NavigationLink(
                                    destination:
                                        OtherUserProfileView(
                                            username: selectedUser?.username ?? "",
                                            profileImage: selectedUser?.profileImage ?? "",
                                            uid: selectedUser?.uid ?? ""),
                                    isActive: $gotonextpage) { EmptyView() }
                            )
                            .foregroundColor(Color.black)
                        }
                    }
                    Spacer()
                    Button(action: {
                        fetchAllFollowingUsernamesInfo { usernames in }
                        showingFolloweringView = true
                    }) {
                        HStack {
                            VStack {
                                Text("Following")
                                    .font(.caption)
                                    .lineLimit(1)
                                    .foregroundColor(.black)
                                Text("\(numFollowing)")
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $showingFolloweringView) {
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
                            .background(
                                NavigationLink(
                                    destination:
                                        OtherUserProfileView(
                                            username: selectedUser?.username ?? "",
                                            profileImage: selectedUser?.profileImage ?? "",
                                            uid: selectedUser?.uid ?? ""),
                                    isActive: $gotonextpage) { EmptyView() }
                            )
                            .foregroundColor(Color.black)
                            .navigationBarItems(leading: Button(action: {
                                showingFolloweringView = false
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
                        Text("\(vm.user?.bio ?? "This is a bio that can only be 50 letters in length")")
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
                
            }
//            HStack {
//                Text("John Doe")
//                    .bold()
//                    .padding(.bottom, 1)
//                Spacer()
//            }
//            HStack{
//                Text("\(vm.user?.bio ?? "This is a bio that can only be 50 letters in length")")
//                    .font(.body)
//                Spacer()
//                Button(action: {
//                }) {
//                    Image(systemName: "text.bubble")
//                        .font(.system(size:25))
//                }
//            }
            HStack {
                Button(action: {
                    withAnimation {
                        openBetsTabisSelected = true
                        highlightsTabisSelected = false
                        badgesTabisSelected = false
                    }
                }) {
                    Text("Open Bets")                        .font(.system(size:18))
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
                    Text("Highlights")                        .font(.system(size:18))
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
                    Text("Badges")                        .font(.system(size:18))
                        .foregroundColor(Color.black)
                        .underline(badgesTabisSelected)
                    
                }.padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue.opacity(0.0))
                    )
            }
            .padding(.horizontal, 0)
            //            .background(
            //                RoundedRectangle(cornerRadius: 10)
            //                    .fill(Color.blue.opacity(0.25))
            //            )
            Spacer()
        }
        .onAppear {
            fetchNumFollowers()
            fetchNumFollowing()
        }
        .padding()
        .navigationBarHidden(true)
    }
    
    
    
    func fetchNumFollowers() {
        guard let currentUserID = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        let followingCollection = db.collection("Users").document(currentUserID).collection("Followers")
        
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
            
            // Update the state variable on the main queue
            DispatchQueue.main.async {
                self.numFollowers = count
            }
        }
    }
    
    func fetchNumFollowing() {
        guard let currentUserID = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        let followingCollection = db.collection("Users").document(currentUserID).collection("Following")
        
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
    
    
    // fetchAllFollowingUsernamesInfo gets all the user ID's from the documents inside
    // Collection: 'Users' -> Collection: 'Following' -> Field: 'uid'
    // The 'uid' field is passed into the searchOtherUsersProfileImageAndUsername function
    
    func fetchAllFollowersUsernamesInfo(completion: @escaping ([String]) -> Void) {
        guard let currentUserID = FirebaseManager.shared.auth.currentUser?.uid else {
            completion([])
            return
        }
        
        let db = Firestore.firestore()
        let followingCollection = db.collection("Users").document(currentUserID).collection("Followers")
        
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
    
    func fetchAllFollowingUsernamesInfo(completion: @escaping ([String]) -> Void) {
        guard let currentUserID = FirebaseManager.shared.auth.currentUser?.uid else {
            completion([])
            return
        }
        
        let db = Firestore.firestore()
        let followingCollection = db.collection("Users").document(currentUserID).collection("Following")
        
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
    
    // searchOtherUsersProfileImageAndUsername takes in the 'uid' field as a parameter and searchs for
    // the profileImageURL, username, and uid associated with the account. These are all sent back as Strings
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
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isLoggedIn: Bool = true
        ProfileView(isLoggedIn: $isLoggedIn)
    }
}


extension Text {
    func underline(_ active: Bool) -> some View {
        self.modifier(UnderlineModifier(active: active))
    }
}

struct UnderlineModifier: ViewModifier {
    let active: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .frame(height: active ? 1 : 0)
                    .foregroundColor(.black)
                    .animation(.default)
                    .opacity(active ? 1 : 0)
                    .animation(.default)
                    .offset(y: active ? 15 : 0)
            )
    }
}
