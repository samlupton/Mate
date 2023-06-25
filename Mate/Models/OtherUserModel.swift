////
////  UserModel.swift
////  Mate
////
////  Created by Samuel Lupton on 5/28/23.
////
//
////
////  UserModel.swift
////  eBook
////
////  Created by Samuel Lupton on 5/25/23.
////  Copyright © 2023 Balaji. All rights reserved.
////
//
//import SwiftUI
//import Firebase
//import FirebaseAuth
//import FirebaseStorage
//import FirebaseFirestore
//import SDWebImageSwiftUI
//
//class OtherUserViewModel: ObservableObject {
//
//    @Published var user: User?
//    @Published var numFollowers: Int = 0
//    @Published var numFollowing: Int = 0
//    @Published var uid: String
//    @Published var username: String
//    @Published var searchOtherUserUID: [String] = []
//
//    init() {
//        self.fetchUser()
//        self.fetchNumFollowers()
//        self.fetchNumFollowing()
//    }
//
//    private func fetchUser() {
//        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return
//            
//        }
//        FirebaseManager.shared.firestore.collection("Users").document(uid).getDocument { snapshot, error in
//            if let error = error {
//                print(error)
//                return
//            }
//            guard let data = snapshot?.data() else {
//                return
//            }
//            print(data)
//            let uid = data["uid"] as? String ?? ""
//            let email = data["email"] as? String ?? ""
//            let username = data["username"] as? String ?? ""
//            let profileImageUrl = data["profileImageURL"] as? String ?? ""
//            let bio = data["bio"] as? String ?? ""
//            let name = data["name"] as? String ?? ""
//            self.user = User(uid: uid, email: email, username: username, profileImageUrl: profileImageUrl, bio: bio, name: name)
//
//        }
//    }
//
//    func fetchNumFollowers() {
//
//        let db = Firestore.firestore()
//        let followingCollection = db.collection("Users").document(getOtherUsersUID()).collection("Followers")
//
//        followingCollection.getDocuments { (snapshot, error) in
//            if let error = error {
//                print("Error fetching followers: \(error.localizedDescription)")
//                return
//            }
//
//            guard let snapshot = snapshot else {
//                print("Snapshot is nil")
//                return
//            }
//
//            let count = snapshot.documents.count
//            print("Number of followers: \(count)")
//
//            // Update the state variable on the main queue
//            DispatchQueue.main.async {
//                self.numFollowers = count
//            }
//        }
//    }
//
//    func fetchNumFollowing() {
//
//        let db = Firestore.firestore()
//        let followingCollection = db.collection("Users").document(getOtherUsersUID()).collection("Following")
//
//        followingCollection.getDocuments { (snapshot, error) in
//            if let error = error {
//                print("Error fetching followers: \(error.localizedDescription)")
//                return
//            }
//
//            guard let snapshot = snapshot else {
//                print("Snapshot is nil")
//                return
//            }
//
//            let count = snapshot.documents.count
//            print("Number of followers: \(count)")
//
//            // Update the state variable on the main queue
//            DispatchQueue.main.async {
//                self.numFollowing = count
//            }
//        }
//    }
//
//    func updateFollowingStatus() {
//        let db = Firestore.firestore()
//
//        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
//            return
//        }
//
//        let followerRef = db.collection("Users").document(uid).collection("Following")
//
//        // Query to check if the follower already exists
//        followerRef.whereField("uid", isEqualTo: getOtherUsersUID())
//            .getDocuments { (querySnapshot, error) in
//                if let error = error {
//                    print("Error querying documents: \(error)")
//                    return
//                }
//
//                if let documents = querySnapshot?.documents, !documents.isEmpty {
//                    for document in documents {
//                        document.reference.delete { error in
//                            if let error = error {
//                                print("Error removing document: \(error)")
//                            } else {
//                                print("User unfollowed successfully!")
//                            }
//                        }
//                    }
//                } else {
//                    let userData = ["uid": self.getOtherUsersUID()]
//                    followerRef.addDocument(data: userData) { error in
//                        if let error = error {
//                            print("Error adding document: \(error)")
//                        } else {
//                            print("User followed successfully!")
//                        }
//                    }
//                }
//            }
//    }
//
//
//
//    func updateFollowerStatus() {
//        let db = Firestore.firestore()
//
//        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
//            return
//        }
//
//        let followerRef = db.collection("Users").document(getOtherUsersUID()).collection("Followers")
//
//        // Query to check if the follower already exists
//        followerRef.whereField("uid", isEqualTo: uid)
//            .getDocuments { (querySnapshot, error) in
//                if let error = error {
//                    print("Error querying documents: \(error)")
//                    return
//                }
//
//                if let documents = querySnapshot?.documents, !documents.isEmpty {
//                    for document in documents {
//                        document.reference.delete { error in
//                            if let error = error {
//                                print("Error removing document: \(error)")
//                            } else {
//                                print("User unfollowed successfully!")
//                            }
//                        }
//                    }
//                } else {
//                    let userData = ["uid": uid]
//                    followerRef.addDocument(data: userData) { error in
//                        if let error = error {
//                            print("Error adding document: \(error)")
//                        } else {
//                            print("User followed successfully!")
//                        }
//                    }
//                }
//            }
//    }
//
//
//    private func getOtherUsersUID() -> String {
//
//        let usersRef = Firestore.firestore().collection("Users")
//
//        usersRef.whereField("username", isEqualTo: username)
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
//                self.searchOtherUserUID = documents.compactMap { document in
//                    guard  let uid = document.data()["uid"] as? String else {
//                        return ""
//                    }
//                    return uid
//                }
//            }
//        return uid
//    }
////
////
////    func fetchBio() {
////        let db = Firestore.firestore()
////        let usersCollection = db.collection("Users")
////
////        usersCollection.whereField("username", isEqualTo: username)
////            .getDocuments { snapshot, error in
////                if let error = error {
////                    print("Error searching for users: \(error.localizedDescription)")
////                    return
////                }
////
////                guard let documents = snapshot?.documents else {
////                    print("No user documents found.")
////                    return
////                }
////
////                if let bio = documents.first?.data()["bio"] as? String {
////                    DispatchQueue.main.async {
////                        self.bio = bio
////                    }
////                } else {
////                    print("No bio found for the user.")
////                }
////            }
////    }
////    func fetchName() {
////        let db = Firestore.firestore()
////        let usersCollection = db.collection("Users")
////
////        usersCollection.whereField("username", isEqualTo: username)
////            .getDocuments { snapshot, error in
////                if let error = error {
////                    print("Error searching for users: \(error.localizedDescription)")
////                    return
////                }
////
////                guard let documents = snapshot?.documents else {
////                    print("No user documents found.")
////                    return
////                }
////
////                if let name = documents.first?.data()["name"] as? String {
////                    DispatchQueue.main.async {
////                        self.name = name
////                        print("name: ", name)
////                    }
////                } else {
////                    print("No bio found for the user.")
////                }
////            }
////    }
//}
