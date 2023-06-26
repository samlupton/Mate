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
                let uid = document.data()["toUid"] as? String ?? ""
                group.enter()

                print(uid)
                followingUIDs.append(uid)
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


//    private func fetchLastMessageTimestamps(for uids: [String]) {
//        guard let currentUserID = FirebaseManager.shared.auth.currentUser?.uid else { return }
//
//        let db = Firestore.firestore()
//
//        for uid in uids {
//            let chatLogCollection = db.collection("Users").document(currentUserID).collection("Messages").document(uid).collection("chatLog")
//
//            chatLogCollection.order(by: "timestamp", descending: true).limit(to: 1).getDocuments { snapshot, error in
//                if let error = error {
//                    print("Error fetching chat log: \(error.localizedDescription)")
//                    return
//                }
//
//                guard let document = snapshot?.documents.first else {
//                    return
//                }
//
//                if let timestamp = document.data()["timestamp"] as? Timestamp {
//                    let date = timestamp.dateValue()
//                    let formatter = DateFormatter()
//                    formatter.dateFormat = "MMM d, h:mm a"
//                    let formattedDate = formatter.string(from: date)
//
//                    DispatchQueue.main.async {
//                        self.lastMessageTimestamps[uid] = formattedDate // Store the last message timestamp for the UID
//                    }
//                }
//            }
//        }
//    }
    
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
    @State private var showingCreateMessageView = false

    @StateObject private var viewModel = MessageListViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Text("Following UIDs:")
                List(viewModel.followingUIDs, id: \.self) { uid in
                    Button(action: {
                        // Handle button tap for the specific UID
                        print("Button tapped for UID: \(uid)")
                    }) {
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
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
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
                Image(systemName: "plus")
                    .foregroundColor(Color.black)
            }
            .fullScreenCover(isPresented: $showingCreateMessageView) {
                NavigationView {
                    CreateMessageView()

                    .navigationBarItems(leading: Button(action: {
                        showingCreateMessageView = false
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color.black)
                    }, trailing:
                    Text("Messages"))
                    Spacer()
                }

            }
            )
        }
    }
}

struct DirectMessageView_Previews: PreviewProvider {
    static var previews: some View {
        DirectMessageView()
    }
}
