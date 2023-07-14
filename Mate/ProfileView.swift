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
    @State private var selectedUser: (username: String, profileImage: String, uid: String)? = nil
    @State private var otherUserInfo: [(username: String, profileImage: String, uid: String)] = []
    @Binding var isLoggedIn: Bool
    @ObservedObject private var vm = UserViewModel()
    @State private var selectedButton: Int?
    @State private var sizer: CGFloat = 0.0
    @State private var selectedButtonIndex: Int = 0
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    HStack {
                        HStack {
                            Button(action: {
                                showAccountInfo = true
                            }) {
                                Text("\(vm.user?.username ?? "User")")
                                    .font(.title)
                                    .bold()
                                    .textCase(.lowercase)
                                    .foregroundColor(Color.white)
                            }
                            .sheet(isPresented: $showAccountInfo) {
                                AccountInfoView(isLoggedIn: $isLoggedIn)
                            }
                            Spacer()
                            Button(action: {
                            }) {
                                Image(systemName: "plus.app")
                                    .font(.system(size:25))
                                    .foregroundColor(Color.white)
                            }
                        }
                    }.padding(.horizontal)
                        .padding(.vertical, 5)
                    
                }
                .background(Color("PrimaryGold"))
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
                    HStack {
                        Spacer()
                        HStack {
                            VStack {
                                Text("Winnings")
                                    .font(.custom("Silkscreen-Regular", size: 14))
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                Text("$137")
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                        }
                        Spacer()
                        Button(action: {
                            fetchFollowers { usernames in }
                            showingFolloweringView = true
                        }) {
                            HStack {
                                VStack {
                                    Text("Followers")
                                    //                                        .font(.caption)
                                        .font(.custom("Silkscreen-Regular", size: 14))
                                        .foregroundColor(.black)
                                    Text("\(vm.numFollowers)")
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
                                                uid: selectedUser?.uid ?? "", bio: ""),
                                        isActive: $gotonextpage) { EmptyView() }
                                )
                                .foregroundColor(Color.black)
                            }
                        }
                        Spacer()
                        Button(action: {
                            fetchFollowing { usernames in }
                            showingFolloweringView = true
                        }) {
                            HStack {
                                VStack {
                                    Text("Following")
                                        .font(.custom("Silkscreen-Regular", size: 14))
                                        .lineLimit(1)
                                        .foregroundColor(.black)
                                    Text("\(vm.numFollowing)")
                                        .font(.headline)
                                    
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .fullScreenCover(isPresented: $showingFolloweringView) {
                            NavigationView {
                                if otherUserInfo.isEmpty {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color.gray.opacity(0.5)))
                                        .scaleEffect(3)
                                } else {
                                    List(otherUserInfo, id: \.username) { userInfo in
                                        NavigationLink(destination: OtherUserProfileView(username: userInfo.username, profileImage: userInfo.profileImage, uid: userInfo.uid, bio: "")) {
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
                                                    uid: selectedUser?.uid ?? "", bio: ""),
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
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                HStack {
                    VStack {
                        HStack {
                            Text("\(vm.user?.name ?? "User")")
                                .bold()
                                .padding(.bottom, 0.0)
                            Spacer()
                        }
                        HStack {
                            Text("\(vm.user?.bio ?? "This is a bio that can only be 50 letters in length")")
                                .font(.body)
                            Spacer()
                        }
                    }.padding(.horizontal)
                    NavigationLink(
                        destination: DirectMessageView(),
                        label: {
                            Image(systemName: "message.circle.fill")
                                .foregroundColor(Color("PrimaryGold"))
                                .font(.system(size:35))
                        }
                    ).padding(.horizontal, 0)
                        .navigationTitle("Back")
                        .foregroundColor(Color.gray)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarHidden(false)
                    Spacer()
                    
                }
                .padding(.horizontal, 0)
                
                Divider().padding(.horizontal)
//                VStack {
                    HStack {
                        Button(action: {
                            selectedButton = 0
                            withAnimation { //light.max
                                openBetsTabisSelected = true
                                highlightsTabisSelected = false
                                badgesTabisSelected = false
                                selectedButtonIndex = 0

                            }
                        }) {
                            Text("OPEN BETS")
                                .font(.system(size:15))
                                .bold()
                                .lineLimit(1)
                                .foregroundColor(Color.black)
                                .padding(.top, 8)
                                .padding(.horizontal)

                        }
                        Spacer()
                        Button(action: {
                            selectedButton = 1
                            withAnimation {
                                openBetsTabisSelected = false
                                highlightsTabisSelected = true
                                badgesTabisSelected = false
                                selectedButtonIndex = 1
                                
                            }
                        }) {
                            Text("HIGHLIGHTS")
                                .font(.system(size:15))
                                .bold()
                                .lineLimit(1)
                                .foregroundColor(Color.black)
                                .padding(.top, 8)
                                .padding(.horizontal)
                        }
                        Spacer()
                        Button(action: {
                            selectedButton = 2
                            withAnimation {
                                openBetsTabisSelected = false
                                highlightsTabisSelected = false
                                badgesTabisSelected = true
                                selectedButtonIndex = 2
                            }
                        }) {
                            Text("BADGES")
                                .font(.system(size:15))
                                .bold()
                                .lineLimit(1)
                                .foregroundColor(Color.black)
                                .padding(.top, 8)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                    GeometryReader { geo in
                        VStack {
                            Rectangle()
                                .fill(Color("PrimaryGold"))
                                .frame(width: geo.size.width * 1 / 3, height: 1)
                                .offset(x: CGFloat(selectedButtonIndex) * (geo.size.width / 3))
                            .animation(.default, value: selectedButtonIndex)
                        }.padding(.bottom, 9)
                    }
//                }
                
                if openBetsTabisSelected {
                    OpenBetsView()
                } else if highlightsTabisSelected {
                    HighlightsView()
                } else if badgesTabisSelected {
                    BadgesView()
                }
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
    
    // fetchFollowers gets all the user ID's from the documents inside
    // Collection: 'Users' -> Collection: 'Following' -> Field: 'uid'
    // The 'uid' field is passed to fetchOtherUserInfo
    
    func fetchFollowers(completion: @escaping ([String]) -> Void) {
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
            
            var updatedOtherUserInfo: [(username: String, profileImage: String, uid: String)] = []
            
            let group = DispatchGroup()
            
            for document in documents {
                let uid = document.data()["uid"] as? String ?? ""
                group.enter()
                
                fetchOtherUserInfo(uid: uid) {
                    fetchedUsername,
                    fetchedProfileImage,
                    fetchuid in
                    updatedOtherUserInfo.append((username: fetchedUsername, profileImage: fetchedProfileImage, uid: fetchuid))
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.otherUserInfo = updatedOtherUserInfo
            }
        }
    }
    
    private func buttonBackground(index: Int) -> Color {
        if let selectedButton = selectedButton, selectedButton == index {
            return Color("PrimaryGold")
        } else {
            return Color.white
        }
    }
    
    func fetchFollowing(completion: @escaping ([String]) -> Void) {
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
            
            var updatedOtherUserInfo: [(username: String, profileImage: String, uid: String)] = []
            
            let group = DispatchGroup()
            
            for document in documents {
                let uid = document.data()["uid"] as? String ?? ""
                group.enter()
                
                fetchOtherUserInfo(uid: uid) {
                    fetchedUsername,
                    fetchedProfileImage,
                    fetchuid in
                    updatedOtherUserInfo.append((username: fetchedUsername, profileImage: fetchedProfileImage, uid: fetchuid))
                    
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.otherUserInfo = updatedOtherUserInfo
            }
        }
    }
    
    // searchOtherUsersProfileImageAndUsername takes in the 'uid' field as a parameter and searchs for
    // the profileImageURL, username, and uid associated with the account. These are all sent back as Strings
    private func fetchOtherUserInfo(uid: String, completion: @escaping (String, String, String) -> Void) {
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
                    .opacity(active ? 1 : 0)
                    .offset(y: active ? 15 : 0)
            )
            .animation(.default, value: active) // Apply animation with value parameter
    }
}
