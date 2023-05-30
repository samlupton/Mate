//
//  SearchView.swift
//  Mate
//
//  Created by Samuel Lupton on 5/29/23.
//

import SwiftUI
import Firebase

//struct SearchView : View {
//
//    @State private var text: String = ""
//    @State private var searchText: String = ""
//
//    var body : some View{
//
//        VStack(alignment: .leading, spacing: 10) {
//
//            HStack(spacing: 5) {
//                TextField("Search", text: $text)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                Spacer(minLength: 5)
//                Button(action: {
//                    let generator = UIImpactFeedbackGenerator(style: .heavy)
//                    generator.prepare()
//                    generator.impactOccurred()
//                }) {
//                    Image(systemName: "magnifyingglass")
//                        .font(.body)
//                        .frame(width: 2, height: 2)
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.gray)
//                        .cornerRadius(30)
//                }
//            }.padding(.horizontal, 15)
//            Spacer()
//        }
//    }
//}

import SwiftUI
import Firebase

struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults: [String] = [] // List of search results
    
    var body: some View {
        VStack {
            TextField("Search users", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Search", action: searchUsers)
                .padding()
            
            List(searchResults, id: \.self) { user in
                Text(user)
            }
        }
    }
    
    private func searchUsers() {
        guard !searchText.isEmpty else {
            return
        }
        
        // Search for users in Firebase based on the entered text
        let usersRef = Firestore.firestore().collection("Users")
        
        usersRef.whereField("username", isGreaterThanOrEqualTo: searchText)
            .whereField("username", isLessThan: searchText + "z")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error searching for users: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No user documents found.")
                    return
                }
                
                let foundUsers = documents.map { $0.documentID }
                self.searchResults = foundUsers
            }
    }
}



struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
