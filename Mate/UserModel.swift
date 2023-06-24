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
import FirebaseAuth
import FirebaseStorage
import SDWebImageSwiftUI

struct User {
    let uid, email, username, profileImageUrl, bio: String
}

class UserViewModel: ObservableObject {
    
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
