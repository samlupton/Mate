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
            if recipient != nil {
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
        let toMessagesRef = toUserRef.document(toUid).collection("Messages").document(currentUserID).collection("chatLog")
        
        let fromUserRef = Firestore.firestore().collection("Users")
        let fromMessagesRef = fromUserRef.document(currentUserID).collection("Messages").document(toUid).collection("chatLog")
        
        let newMessage: [String: Any] = [
            "message": message,
            "timestamp": Date(),
            "fromUid": currentUserID,
            "toUid": toUid
        ]
        
        let MessageID: [String: Any] = [
            "fromUid": currentUserID,
            "toUid": toUid
        ]
        
        // Add message to the toMessagesRef collection
        toMessagesRef.addDocument(data: newMessage) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully!")
            }
        }
        
        // Add message to the fromMessagesRef collection
        fromMessagesRef.addDocument(data: newMessage) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully!")
            }
        }
//         below is code that i wrote to save the uid as a feild inside the documents in the Message collection. however, it doesnt work. it gets errors like this: Error updating document: No document to update: projects/mate-23629/databases/(default)/documents/Users/gy2xjZtaBLcXHYqYbUvKuWUHzzc2/Messages/6DgY3kctVWV6Rs3LwEATHIZu4bq2
//        2023-06-26 10:49:07.253789-0500 Mate[83378:1755383] 10.10.0 - [FirebaseFirestore][I-FST000001] WriteStream (140e1b1e8) Stream error: 'Not found: No document to update: projects/mate-23629/databases/(default)/documents/Users/6DgY3kctVWV6Rs3LwEATHIZu4bq2/Messages/gy2xjZtaBLcXHYqYbUvKuWUHzzc2'
//        Error updating document: No document to update: projects/mate-23629/databases/(default)/documents/Users/6DgY3kctVWV6Rs3LwEATHIZu4bq2/Messages/gy2xjZtaBLcXHYqYbUvKuWUHzzc2
        let toMessagesRefID = toUserRef.document(toUid).collection("Messages").document(currentUserID)
        
        let fromMessagesRefID = fromUserRef.document(currentUserID).collection("Messages").document(toUid)
        
        // Add message to the toMessagesRef collection
        toMessagesRefID.setData(MessageID, merge: true) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                print("Document updated successfully!")
            }
        }
        
        // Add message ID to the fromMessagesRef document
        fromMessagesRefID.setData(MessageID, merge: true) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                print("Document updated successfully!")
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

