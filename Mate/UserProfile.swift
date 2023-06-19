//
//  UserProfile.swift
//  Mate
//
//  Created by Samuel Lupton on 6/15/23.
//

import Foundation

struct Users {
    
    let uid: String
    let email: String
    let username: String
    let profileImageUrl: String
    let bio: String
    let numFollowers: Int
    let numFollowing: Int
    let following: [String]
    let followers: [String]
    
}

class UserProfile: ObservableObject {
    
    @Published var user: User?
    
    init() {
        fetchCurrentUser()
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
            self.user = User(uid: uid, email: email, username: username, profileImageUrl: profileImageUrl, bio: bio)
            
        }
    }
}
