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

struct ProfileView: View {

    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker: Bool = false
    @State private var showSaveAlert: Bool = false
    @State private var username: String = ""
    @State private var showAlert = false
    @State private var showAccountInfo = false
    @State private var showingFollowersView = false
    @State private var usernames: [String] = []
    @State private var otherUserInfo: [(username: String, profileImage: String)] = []
    @State private var profileImage: String = ""
    @State private var uid: String = ""

    
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
                    Image(systemName: "gear")
                        .font(.system(size:25))
                        .foregroundColor(Color.black)
                }
                .sheet(isPresented: $showAccountInfo) {
                    AccountInfoView(isLoggedIn: $isLoggedIn)
                }
            }
            HStack(spacing: 16) {
                Button(action: {
                    fetchAllFollowingUsernamesInfo { usernames in
                    }
                    showingFollowersView = true
                }) {
                    VStack {
                        Text("Following")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("5k")
                            .font(.headline)
                    }
                }.sheet(isPresented: $showingFollowersView) {
                    List(otherUserInfo, id: \.username) { userInfo in
                        //                            HStack {
                        //                                WebImage(url: URL(string: userInfo.profileImage))
                        //                                    .resizable()
                        //                                    .frame(width: 50, height: 50)
                        //                                    .clipShape(Circle())
                        //                                    .foregroundColor(Color.black)
                        //                                    .clipped()
                        ////                                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        //                                    .padding()
                        //                                    .foregroundColor(Color.black)
                        //                                Text(userInfo.username)
                        //                                    .foregroundColor(.black)
                        //                            }.frame(height: 65)
                        NavigationLink(destination: OtherUserProfileView(username: userInfo.username, profileImage: userInfo.profileImage, uid: uid)) {
                            HStack {
                                WebImage(url: URL(string: userInfo.profileImage))
                                    .placeholder(Image(systemName: "person.circle"))
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .foregroundColor(Color.black)
                                    .foregroundColor(Color.black)

                                Text(userInfo.username)
                                    .textCase(.lowercase)
                            }
                        }
                    }
                    .onAppear {
                        ProfileView(isLoggedIn: $isLoggedIn).fetchAllFollowingUsernamesInfo { usernames in
                            self.usernames = usernames
                        }
                    }
                }
                .padding()
                WebImage(url: URL(string: vm.user?.profileImageUrl  ?? ""))
                    .resizable()
                    .frame(width: 82, height: 84)
                    .clipShape(Circle())
                    .foregroundColor(Color.black)
                    .clipped()
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    .padding()
                    .foregroundColor(Color.black)
                
                VStack {
                    Text("Followers")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("10k")
                        .font(.headline)
                }
                .padding()
            }
            Spacer()
        }
        .padding()
        .navigationBarHidden(true)
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
            var updatedOtherUserInfo: [(username: String, profileImage: String)] = []
            
            let group = DispatchGroup()
                       
                       for document in documents {
                           let uid = document.data()["uid"] as? String ?? ""
                           
                           group.enter()
                           
                           searchOtherUsersProfileImageAndUsername(uid: uid) { fetchedUsername, fetchedProfileImage in
                               updatedOtherUserInfo.append((username: fetchedUsername, profileImage: fetchedProfileImage))
                               usernames.append(username)
                               group.leave()
                           }
                       }
                       
            group.notify(queue: .main) {
                        self.otherUserInfo = updatedOtherUserInfo // Assign the updated array to the original property
                        completion(usernames)
                    }
        }
    }

    private func searchOtherUsersProfileImageAndUsername(uid: String, completion: @escaping (String, String) -> Void) {
        let usersRef = Firestore.firestore().collection("Users")
        print("the uid is: " + uid)
        usersRef.whereField("uid", isEqualTo: uid).getDocuments { snapshot, error in
            if let error = error {
                print("Error searching for users: \(error.localizedDescription)")
                completion("", "")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No user documents found.")
                completion("", "")
                return
            }

            if let document = documents.first,
               let username = document.data()["username"] as? String,
               let profileImage = document.data()["profileImageURL"] as? String {
                
                print(username + " or " + profileImage)
                completion(username, profileImage)
            } else {
                completion("", "")
               
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


