//
//  AccountInfoView.swift
//  Mate
//
//  Created by Samuel Lupton on 5/29/23.
//

import Foundation
import SwiftUI

struct AccountInfoView: View {
    
    @State var selectedImage: UIImage? = nil
    @State private var showImagePicker: Bool = false
    @State private var showSaveAlert: Bool = false
    @State private var username: String = ""
    @State private var showAlert = false
    @Binding var isLoggedIn: Bool

    
    var body: some View {
        
        VStack {
            settingsButton
            TextField("Type here", text: $username)
            usernameButton
            Button(action: {
                isLoggedIn = false
            }) {
                Text("Sign out")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }.padding()
            Spacer()
        }.padding()
    }
    
    private var settingsButton: some View {
        Button(action: {
            showImagePicker = true
        }) {
            Image(systemName: "gear")
                .font(.system(size:25))
                .foregroundColor(Color.black)
        }
    }
    
    private var usernameButton: some View {
        Button("Set Username") {
            showAlert = true
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Set Username"),
                message: nil,
                primaryButton: .default(Text("Save"), action: {
                    guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
                        return
                    }
                    let userData = ["username": username]
                    FirebaseManager.shared.firestore.collection("Users").document(uid).setData(userData, merge: true) { err in
                        if let err = err {
                            print(err)
                            return
                        }
                        print("Username saved successfully.")
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
}
