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


class MessageListViewModel: ObservableObject {
    @Published var followingUIDs: [String] = [] // New property to hold following UIDs
    
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
                let uid = document.data()["uid"] as? String ?? ""
                group.enter()
                
                print(uid)
                followingUIDs.append(uid)
                group.leave()
            }
            
            group.notify(queue: .main) {
                self.followingUIDs = followingUIDs // Update the following UIDs property
                completion(followingUIDs)
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
                ForEach(viewModel.followingUIDs, id: \.self) { uid in
                    Text(uid)
                }
            }
            .onAppear {
                viewModel.fetchFollowing { followingUIDs in
                    // Handle the fetched following UIDs here
                    print("Following UIDs: \(followingUIDs)")
                }
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

struct DirectMessageView_Previews: PreviewProvider {
    static var previews: some View {
        DirectMessageView()
    }
}
