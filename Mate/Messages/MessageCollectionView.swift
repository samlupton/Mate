//
//  MessageCollectionView.swift
//  Mate
//
//  Created by Samuel Lupton on 6/26/23.
//


import SwiftUI
import Firebase
import FirebaseFirestore

struct Message: Identifiable, Equatable {
    let id = UUID()
    let fromUid: String
    let toUid: String
    let message: String
    let timestamp: Date
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}

struct MessageCollectionView: View {
    let currentUserID: String
    let toUid: String
    @State private var messages: [Message] = []
    private let firestore = Firestore.firestore()
    
    @State private var recipient: String?
    @State private var recipientInfo: (username: String, profileImage: String, uid: String) = ("", "", "")
    @State private var messageToRecipient = ""
    @State private var scrollToBottom = false
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(messages.reversed()) { message in
                                if message.fromUid == currentUserID {
                                    HStack {
                                        Spacer()
                                        Text(message.message)
                                            .padding(.horizontal)
                                            .padding(.vertical, 2)
                                            .background(Color.gray.opacity(0.2))
                                            .foregroundColor(.black)
                                            .cornerRadius(10)
                                    }
                                } else {
                                    HStack {
                                        Text(message.message)
                                            .padding(.horizontal)
                                            .padding(.vertical, 2)
                                            .background(Color.gray.opacity(0.2))
                                            .foregroundColor(.black)
                                            .cornerRadius(10)
                                        Spacer()
                                    }
                                }
                            }
                            .id(messages.last?.id)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onAppear {
                            fetchMessages()
                            DispatchQueue.main.async {
                                scrollToBottom(scrollViewProxy)
                            }
                        }
                        .onChange(of: messages, perform: { _ in

                            DispatchQueue.main.async {
                                scrollToBottom(scrollViewProxy)
                            }
                        })
                    }
                
                
                
        }
        
        HStack {
            TextField("Send a message to \(recipientInfo.username)", text: $messageToRecipient)
                .padding()
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(.gray.opacity(0.5), lineWidth: 2)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 7)
                )
            Button(action: {
                let messageText = messageToRecipient
                let recipientUID = toUid
                sendMessage(to: recipientUID, message: messageText)
                messageToRecipient = ""
                scrollToBottom = true
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(Color.black)
            }
            .padding()
        }
        
    }
    
private func scrollToBottom(_ scrollViewProxy: ScrollViewProxy) {
        withAnimation {
            scrollViewProxy.scrollTo(messages.last?.id, anchor: .bottom)
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
    }
    
    private func fetchMessages() {
        firestore
            .collection("Users")
            .document(toUid)
            .collection("Messages")
            .document(currentUserID)
            .collection("chatLog")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching messages: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                messages = documents.compactMap { document -> Message? in
                    guard
                        let fromUid = document["fromUid"] as? String,
                        let toUid = document["toUid"] as? String,
                        let message = document["message"] as? String,
                        let timestamp = document["timestamp"] as? Timestamp
                    else { return nil }
                    
                    return Message(fromUid: fromUid, toUid: toUid, message: message, timestamp: timestamp.dateValue())
                }
            }
    }
}
