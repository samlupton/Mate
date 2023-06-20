//////
//////  SearchUserHelper.swift
//////  Mate
//////
//////  Created by Samuel Lupton on 6/19/23.
//import SwiftUI
//import Firebase
//import FirebaseFirestore
////
//class UserSearchHelper {
//    //
//    //    private var searchText = ""
//    //    private var searchResults: [(username: String, profileImage: String, uid: String)] = []
//    //
//    //    func searchUsers() {
//    //        guard !searchText.isEmpty else {
//    //            return
//    //        }
//    //
//    //        let usersRef = Firestore.firestore().collection("Users")
//    //
//    //        usersRef.whereField("username", isEqualTo: searchText)
//    //            .getDocuments { snapshot, error in
//    //                if let error = error {
//    //                    print("Error searching for users: \(error.localizedDescription)")
//    //                    return
//    //                }
//    //
//    //                guard let documents = snapshot?.documents else {
//    //                    print("No user documents found.")
//    //                    return
//    //                }
//    //
//    //                self.searchResults = documents.compactMap { document in
//    //                    guard let username = document.data()["username"] as? String,
//    //                          let uid = document.data()["uid"] as? String,
//    //                          let profileImage = document.data()["profileImageURL"] as? String else {
//    //                        return nil
//    //                    }
//    //                    print(uid)
//    //                    return (username: username, profileImage: profileImage, uid: uid)
//    //                }
//    //            }
//    //    }
//    //}
//    
//    private var searchText = ""
//    private var searchResults: [(username: String, profileImage: String, uid: String)] = []
//    
//    func searchUsers(with: searchText: String, completion: @escaping ([(username: String, profileImage: String, uid: String)]) -> Void) {
//        guard !searchText.isEmpty else {
//            return
//        }
//        
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
//                          let uid = document.data()["uid"] as? String,
//                          let profileImage = document.data()["profileImageURL"] as? String else {
//                        return nil
//                    }
//                    print(uid)
//                    return (username: username, profileImage: profileImage, uid: uid)
//                }
//            }
//    }
//}
