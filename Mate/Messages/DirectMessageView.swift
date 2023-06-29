//
//  DirectMessageView.swift
//  Mate
//
//  Created by Samuel Lupton on 6/24/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import SDWebImageSwiftUI

struct ContactInfo {
    let profileImageURL: String
    let username: String
}

class MessageListViewModel: ObservableObject {
    @Published var followingUIDs: [String] = []
    @Published var contactInfo: [String: ContactInfo] = [:]
    @Published var lastMessageTimestamps: [String: String] = [:]
    @Published var lastMessages: [String: String] = [:]
    
    func fetchFollowing(completion: @escaping ([String]) -> Void) {
        guard let currentUserID = FirebaseManager.shared.auth.currentUser?.uid else {
            completion([])
            return
        }
        
        let db = Firestore.firestore()
        let followingCollection = db.collection("Users").document(currentUserID).collection("Messages")
        
        followingCollection.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching following documents: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            let group = DispatchGroup()
            var followingUIDs: [String] = []
            
            for document in documents {
                
                //                let uid = document.data()["toUid"] as? String ?? ""
                
                let toUid = document.data()["toUid"] as? String ?? ""
                let fromUid = document.data()["fromUid"] as? String ?? ""
                
                group.enter()
                
                if fromUid != currentUserID {
                    followingUIDs.append(fromUid)
                } else {
                    followingUIDs.append(toUid)
                }
                
                //                followingUIDs.append(uid)
                group.leave()
            }
            
            group.notify(queue: .main) {
                self.followingUIDs = followingUIDs // Update the following UIDs property
                completion(followingUIDs)
                
                // Fetch contact information for each UID
                self.fetchContactInfo(for: followingUIDs)
                
                // Fetch last message timestamps for each UID
                self.fetchLastMessageTimestamps(for: followingUIDs)
            }
        }
    }
    
    private func fetchContactInfo(for uids: [String]) {
        let db = Firestore.firestore()
        let usersCollection = db.collection("Users")
        
        for uid in uids {
            usersCollection.document(uid).getDocument { document, error in
                if let error = error {
                    print("Error fetching contact info for UID \(uid): \(error.localizedDescription)")
                    return
                }
                
                if let data = document?.data(),
                   let profileImageURL = data["profileImageURL"] as? String,
                   let username = data["username"] as? String {
                    DispatchQueue.main.async {
                        self.contactInfo[uid] = ContactInfo(profileImageURL: profileImageURL, username: username)
                    }
                }
            }
        }
    }
    
    private func fetchLastMessageTimestamps(for uids: [String]) {
        guard let currentUserID = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        for uid in uids {
            let chatLogCollection = db.collection("Users").document(currentUserID).collection("Messages").document(uid).collection("chatLog")
            
            chatLogCollection.order(by: "timestamp", descending: true).limit(to: 1).getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching chat log: \(error.localizedDescription)")
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    return
                }
                
                if let timestamp = document.data()["timestamp"] as? Timestamp {
                    let date = timestamp.dateValue()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM d, h:mm a"
                    let formattedDate = formatter.string(from: date)
                    
                    let message = document.data()["message"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        self.lastMessageTimestamps[uid] = formattedDate // Store the last message timestamp for the UID
                        self.lastMessages[uid] = message // Store the last message for the UID
                    }
                }
            }
        }
    }
    
}

struct DirectMessageView: View {
    //
    @State private var searchText = ""
    @State private var searchResults: [(username: String, profileImage: String, uid: String)] = []
    @State private var isRecipientSelected: Bool = false
    @State private var recipient: String?
    @State private var recipientInfo: (username: String, profileImage: String, uid: String) = ("", "", "")
    @State private var messageToRecipient = ""
    let currentUserID = FirebaseManager.shared.auth.currentUser?.uid

    @State private var showingCreateMessageView = false
    
    @StateObject private var viewModel = MessageListViewModel()
    
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
                VStack {
                    List(viewModel.followingUIDs, id: \.self) { uid in
                        NavigationLink(destination: MessageCollectionView(currentUserID: currentUserID ?? "", toUid: uid)) {
                            HStack {
                                if let profileImageURL = viewModel.contactInfo[uid]?.profileImageURL {
                                    AsyncImage(url: URL(string: profileImageURL)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .padding(.trailing, 10)
                                    } placeholder: {
                                        Circle()
                                            .foregroundColor(.blue)
                                            .frame(width: 50, height: 50)
                                            .padding(.trailing, 10)
                                    }
                                } else {
                                    Circle()
                                        .foregroundColor(.blue)
                                        .frame(width: 50, height: 50)
                                        .padding(.trailing, 10)
                                }
                                
                                VStack(alignment: .leading) {
                                    if let contactName = viewModel.contactInfo[uid]?.username {
                                        Text(contactName)
                                            .font(.headline)
                                    } else {
                                        Text("Loading...")
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                    }
                                    if let lastTimestamp = viewModel.lastMessageTimestamps[uid] {
                                        Text(lastTimestamp)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    } else {
                                        Text("Loading...")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    if let lastMessage = viewModel.lastMessages[uid] {
                                        Text(lastMessage)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    } else {
                                        Text("Loading...")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } .padding(.top, 5)
                }
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
        .onAppear {
            viewModel.fetchFollowing { followingUIDs in
                // Handle the fetched following UIDs here
                print("Following UIDs: \(followingUIDs)")
            }
        }
        .navigationBarItems(trailing: Button(action: {
            showingCreateMessageView = true
        }) {
            Image(systemName: "square.and.pencil")
                .foregroundColor(Color.black)
        }
            .navigationTitle("Messages")
            .fullScreenCover(isPresented: $showingCreateMessageView) {
                NavigationView {
                    CreateMessageView()
                    
                        .navigationBarItems(leading: Button(action: {
                            showingCreateMessageView = false
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color.black)
                        })
                    Spacer()
                }
                
            })
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
        
        let toMessageID: [String: Any] = [
            "fromUid": currentUserID,
            "toUid": toUid
        ]
        
        let fromMessageID: [String: Any] = [
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
        
        let toMessagesRefID = toUserRef.document(toUid).collection("Messages").document(currentUserID)
        
        let fromMessagesRefID = fromUserRef.document(currentUserID).collection("Messages").document(toUid)
        
        // Add message to the toMessagesRef collection
        toMessagesRefID.setData(toMessageID, merge: true) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                print("Document updated successfully!")
            }
        }
        
        // Add message ID to the fromMessagesRef document
        fromMessagesRefID.setData(fromMessageID, merge: true) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                print("Document updated successfully!")
            }
        }
    }
}

struct DirectMessageView_Previews: PreviewProvider {
    static var previews: some View {
        DirectMessageView()
    }
}
