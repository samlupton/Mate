//
//  OtherUserProfileView.swift
//  Mate
//
//  Created by Samuel Lupton on 5/30/23.
//
import Firebase
import SwiftUI
import SDWebImageSwiftUI

struct OtherUserProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    var username: String
    var profileImage: String
    @State var newFollower: String = ""
    @State var uid: String
    @State private var searchOtherUserUID: [(String)] = []
    
    
    
    var body: some View {
        VStack {
            HStack (spacing: 16) {
                VStack{
                    Text("Followers")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("10k")
                        .font(.headline)
                }.padding()
                VStack {
                    WebImage(url: URL(string: profileImage))
                        .resizable()
                        .frame(width: 82, height: 84)
                        .clipShape(Circle())
                        .foregroundColor(Color.black)
                        .clipped()
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        .padding()
                        .foregroundColor(Color.black)
                }
                VStack {
                    Text("Following")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("5k")
                        .font(.headline)
                }
                .padding()
            }
            Button {
                updateFollowingStatus()
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle")
                } .frame(maxWidth: .infinity)
                
            }
            .padding()
            .buttonStyle(.bordered)
            .tint(.black)
            Spacer()
        }
        .navigationBarTitle(Text(username.lowercased()), displayMode: .inline)
        .textCase(.lowercase)
        .navigationBarItems(leading: backButton)
        .accentColor(.black)
        .navigationBarBackButtonHidden(true)
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .imageScale(.large)
        }
    }
    
    private func updateFollowingStatus() {
        let db = Firestore.firestore()
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        let followerRef = db.collection("Users").document(uid).collection("Following")
        
        // Query to check if the follower already exists
        followerRef.whereField("Following", isEqualTo: username)
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
                    let userData = ["Following": username, "uid": getOtherUsersUID()]
                    followerRef.addDocument(data: userData) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            print("User followed successfully!")
                        }
                    }
                }
            }
    }
    
    private func getOtherUsersUID() -> String {
        
        let usersRef = Firestore.firestore().collection("Users")
        
        usersRef.whereField("username", isEqualTo: username)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error searching for users: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No user documents found.")
                    return
                }
                
                self.searchOtherUserUID = documents.compactMap { document in
                    guard  let uid = document.data()["uid"] as? String else {
                        return ""
                    }
                    return uid
                }
            }
        return uid
    }
}

struct OtherUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        @State var username: String = ""
        @State var profileImage: String = ""
        @State var uid: String = ""

        OtherUserProfileView(username: username, profileImage: profileImage, uid: uid)
    }
}
