//
//  UserModel.swift
//  Mate
//
//  Created by Samuel Lupton on 5/28/23.
//

//
//  UserModel.swift
//  eBook
//
//  Created by Samuel Lupton on 5/25/23.
//  Copyright © 2023 Balaji. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import SDWebImageSwiftUI

struct User {
    let uid, email, username, profileImageUrl, bio, name: String
}

class UserViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var numFollowers: Int = 0
    @Published var numFollowing: Int = 0
    
    init() {
        fetchCurrentUser()
        fetchNumFollowers()
        fetchNumFollowing()
    }
    
    private func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return
            
        }
        FirebaseManager.shared.firestore.collection("Users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print(error)
                return
            }
            guard let data = snapshot?.data() else {
                return
            }
            print(data)
            let uid = data["uid"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let username = data["username"] as? String ?? ""
            let profileImageUrl = data["profileImageURL"] as? String ?? ""
            let bio = data["bio"] as? String ?? ""
            let name = data["name"] as? String ?? ""
            self.user = User(uid: uid, email: email, username: username, profileImageUrl: profileImageUrl, bio: bio, name: name)
            
        }
    }
    
    private func fetchNumFollowers() {
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
    
    private func fetchNumFollowing() {
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
}
