//
//  CreateMessage.swift
//  Mate
//
//  Created by Samuel Lupton on 6/24/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import SDWebImageSwiftUI

struct CreateMessageView: View {
    
    @State private var searchText = ""
    @State private var searchResults: [(username: String, profileImage: String, uid: String)] = []
    @State private var isRecipientSelected: Bool = false
    @State private var recipient: String?
    @State private var recipientInfo: (username: String, profileImage: String, uid: String) = ("", "", "")
    @State private var messageToRecipient = ""
    
    
    var body: some View {
        VStack {
            if let toUid = recipient {
                VStack {
                    HStack {
                        WebImage(url: URL(string: recipientInfo.profileImage))
                            .placeholder(Image(systemName: "person.circle"))
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .foregroundColor(Color.black)
                        
                        Text(recipientInfo.username)
                            .font(.title)
                            .bold()
                            .foregroundColor(Color.black)
                        Spacer()
                    }.padding()
                    
                    HStack {
                        TextField("Send a message to \(recipientInfo.username)", text: $messageToRecipient)
                            .padding()
                            .background(Color.white)
                        Button(action: {
                            let messageText = messageToRecipient
                            let recipientUID = recipientInfo.uid
                            sendMessage(to: recipientUID, message: messageText)
                            messageToRecipient = ""
                        }) {
                         Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(Color.black)
                        }.padding()
                    }
                    Spacer()
                }
                
            } else if searchText.isEmpty {
                Text("Search a User to message.")
            } else {
                List {
                    ForEach(searchResults, id: \.username) { result in
                        HStack {
                            Button(action: {
                                recipient = result.uid
                                recipientInfo = result
                                searchText = ""
                            }) {
                                HStack {
                                    WebImage(url: URL(string: result.profileImage))
                                        .placeholder(Image(systemName: "person.circle"))
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                        .foregroundColor(Color.black)
                                    
                                    Text(result.username)
                                        .textCase(.lowercase)
                                        .foregroundColor(Color.black)
                                }
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .disableAutocorrection(true)
        .onChange(of: searchText) { newValue in
            searchUsers()
        }
    }
    
    func sendMessage(to toUid: String, message: String) {
        
        guard let currentUserID = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        let toUserRef = Firestore.firestore().collection("Users")
        let toMessagesRef = toUserRef.document(toUid).collection("Messages")
        
        let fromUserRef = Firestore.firestore().collection("Users")
        let fromMessagesRef = fromUserRef.document(currentUserID).collection("Messages")
        
        
        
        let newMessageTo: [String: Any] = [
            "toUid": toUid
        ]
        
        let newMessageFrom: [String: Any] = [
            "fromUid": currentUserID
        ]
        
        
        toMessagesRef.addDocument(data: newMessageFrom) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully!")
            }
        }
        
        fromMessagesRef.addDocument(data: newMessageTo) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully!")
            }
        }
        
        toMessagesRef.whereField("fromUid", isEqualTo: currentUserID).getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error searching for user: \(error.localizedDescription)")
                    return
                }

                guard let snapshot = snapshot else {
                    print("No matching user found.")
                    return
                }

                if snapshot.documents.isEmpty {
                    print("No matching user found.")
                    return
                }

                let chatLogRef = snapshot.documents[0].reference.collection("chatLog")
                let newMessage: [String: Any] = [
                    "message": message,
                    "timestamp": Date()
                ]

                chatLogRef.addDocument(data: newMessage) { error in
                    if let error = error {
                        print("Error sending message: \(error.localizedDescription)")
                    } else {
                        print("Message sent successfully!")
                    }
                }
            }
        
        fromMessagesRef.whereField("toUid", isEqualTo: toUid).getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error searching for user: \(error.localizedDescription)")
                    return
                }

                guard let snapshot = snapshot else {
                    print("No matching user found.")
                    return
                }

                if snapshot.documents.isEmpty {
                    print("No matching user found.")
                    return
                }

                let chatLogRef = snapshot.documents[0].reference.collection("chatLog")
                let newMessage: [String: Any] = [
                    "message": message,
                    "timestamp": Date()
                ]

                chatLogRef.addDocument(data: newMessage) { error in
                    if let error = error {
                        print("Error sending message: \(error.localizedDescription)")
                    } else {
                        print("Message sent successfully!")
                    }
                }
            }
    }

    
    
    private func searchUsers() {
        guard !searchText.isEmpty else {
            return
        }
        
        let usersRef = Firestore.firestore().collection("Users")
        
        let startText = searchText
        let endText = searchText + "\u{f8ff}" // Unicode character that represents the highest possible character
        
        usersRef.whereField("username", isGreaterThanOrEqualTo: startText)
            .whereField("username", isLessThan: endText)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error searching for users: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No user documents found.")
                    return
                }
                
                self.searchResults = documents.compactMap { document in
                    guard let username = document.data()["username"] as? String,
                          let uid = document.data()["uid"] as? String,
                          let profileImage = document.data()["profileImageURL"] as? String else {
                        return nil
                    }
                    print(uid)
                    return (username: username, profileImage: profileImage, uid: uid)
                }
            }
    }
}

struct CreateMessageView_Previews: PreviewProvider {
    static var previews: some View {
        CreateMessageView()
    }
}

