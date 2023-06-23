//
//  UIDHelperClass.swift
//  Mate
//
//  Created by Samuel Lupton on 6/21/23.
//
import SwiftUI
import Firebase
import FirebaseFirestore

class OtherUser {
    
    let uid: String
    
    init(uid: String) {
        self.uid = uid
    }
    
    static func getOtherUsersUID(username: String, completion: @escaping (String?) -> Void) {
        let usersRef = Firestore.firestore().collection("Users")
        
        usersRef.whereField("username", isEqualTo: username)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error searching for users: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No user documents found.")
                    completion(nil)
                    return
                }
                
                if let document = documents.first, let uid = document.data()["uid"] as? String {
                    completion(uid)
                } else {
                    completion(nil)
                }
            }
    }
    
    func getOtherUsersUID(username: String, completion: @escaping (String?) -> Void) {
        let usersRef = Firestore.firestore().collection("Users")
        
        usersRef.whereField("username", isEqualTo: username)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error searching for users: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No user documents found.")
                    completion(nil)
                    return
                }
                
                if let document = documents.first, let uid = document.data()["uid"] as? String {
                    completion(uid)
                } else {
                    completion(nil)
                }
            }
    }
    
    func fetchAllFollowingUsernamesInfo(completion: @escaping ([String]) -> Void) {
        let db = Firestore.firestore()
        let followingCollection = db.collection("Users").document(uid).collection("Following")
        
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
                
                self.searchOtherUsersProfileImagesAndUsernames(uid: uid) { fetchedUsername, fetchedProfileImage, fetchuid in
                    updatedOtherUserInfo.append((username: fetchedUsername, profileImage: fetchedProfileImage, uid: fetchuid))
                    usernames.append(fetchedUsername)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(usernames)
            }
        }
    }
    
    func fetchAllFollowersUsernamesInfo(completion: @escaping ([String]) -> Void) {
        let db = Firestore.firestore()
        let followersCollection = db.collection("Users").document(uid).collection("Followers")
        
        followersCollection.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching followers documents: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            var usernames: [String] = []
            var updatedOtherUserInfo: [(username: String, profileImage: String, uid: String)] = []
            
            let group = DispatchGroup()
            
            for document in documents {
                let uid = document.data()["uid"] as? String ?? ""
                group.enter()
                
                self.searchOtherUsersProfileImagesAndUsernames(uid: uid) { fetchedUsername, fetchedProfileImage, fetchuid in
                    updatedOtherUserInfo.append((username: fetchedUsername, profileImage: fetchedProfileImage, uid: fetchuid))
                    usernames.append(fetchedUsername)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
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
                
                completion(username, profileImage, uid)
            } else {
                completion("", "", "")
            }
        }
    }
    
    func fetchNumFollowers(completion: @escaping (Int) -> Void) {
        let db = Firestore.firestore()
        let followersCollection = db.collection("Users").document(uid).collection("Followers")
        
        followersCollection.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching followers: \(error.localizedDescription)")
                completion(0)
                return
            }
            
            guard let snapshot = snapshot else {
                print("Snapshot is nil")
                completion(0)
                return
            }
            
            let count = snapshot.documents.count
            
            // Update the state variable on the main queue
            DispatchQueue.main.async {
                completion(count)
            }
        }
    }
    
    func fetchNumFollowing(completion: @escaping (Int) -> Void) {
        let db = Firestore.firestore()
        let followingCollection = db.collection("Users").document(uid).collection("Following")
        
        followingCollection.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching followers: \(error.localizedDescription)")
                completion(0)
                return
            }
            
            guard let snapshot = snapshot else {
                print("Snapshot is nil")
                completion(0)
                return
            }
            
            let count = snapshot.documents.count
            
            // Update the state variable on the main queue
            DispatchQueue.main.async {
                completion(count)
            }
        }
    }
    
    private func updateFollowingStatus() {
        let db = Firestore.firestore()
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        let followingRef = db.collection("Users").document(uid).collection("Following")
        
        // Query to check if the user is already being followed
        followingRef.whereField("uid", isEqualTo: uid)
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
                    followingRef.addDocument(data: userData) { error in
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
        
        let followersRef = db.collection("Users").document(uid).collection("Followers")
        
        // Query to check if the user is already being followed
        followersRef.whereField("uid", isEqualTo: uid)
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
                    followersRef.addDocument(data: userData) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            print("User followed successfully!")
                        }
                    }
                }
            }
    }
}
