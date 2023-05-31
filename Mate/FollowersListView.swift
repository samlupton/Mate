//
//  FollowersListView.swift
//  Mate
//
//  Created by Samuel Lupton on 5/31/23.
//

import Foundation
import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct FollowingListView: View {
    
    @State private var usersFollowing: [(username: String, profileImage: String)] = []

    var body: some View {
        // Fetch and display the list of users that you follow
        // You can use the existing FirebaseManager or any other method to retrieve the data
        
        // Example code to display a list of followers
        List {
            // Iterate through the list of users and display their usernames and profile images
            ForEach(usersFollowing, id: \.username) { user in
                HStack {
                    // Display the user's profile image
                    // Replace "URL(string: user.profileImageUrl)" with your actual code to load the image
                    WebImage(url: URL(string: user.profileImage))
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    
                    // Display the user's username
                    Text(user.username)
                        .font(.headline)
                }
            }
        }
    }
    
    private func UsersFollowingList() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        let followerRef = Firestore.firestore().collection("users").document(uid).collection("Following")
        
        followerRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error getting following list: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No following documents found")
                return
            }
            
            let followingUsers = documents.compactMap { document -> (username: String, profileImage: String)? in
                let data = document.data()
                guard let username = data["username"] as? String,
                      let profileImage = data["profileImage"] as? String else {
                    return nil
                }
                return (username, profileImage)
            }
            
            DispatchQueue.main.async {
                usersFollowing = followingUsers
            }
        }
    }


}

