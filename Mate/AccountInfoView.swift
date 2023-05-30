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
        }.navigationBarHidden(true)
        .padding()
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
                .onDisappear {
                    showSaveAlert = true
                }
        }
    }
    
    private var settingsButton: some View {
        Button(action: {
            showImagePicker = true
        }) {
            Image(systemName: "gear")
                .font(.system(size:25))
                .foregroundColor(Color.black)
        }.alert(isPresented: $showSaveAlert) {
            Alert(
                title: Text("Save Image"),
                message: Text("Do you want to save the selected image?"),
                primaryButton: .default(Text("Save")) {
                    self.persistImageToStorage()
                },
                secondaryButton: .cancel(Text("Cancel"))
            )
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
    
    private func persistImageToStorage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
            
        }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.selectedImage?.jpegData(compressionQuality: 1.0)
        else {return}
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                print(err)
                return
            }
            ref.downloadURL { url, err in
                if let err = err {
                    print(err)
                    return
                }
                print("Success")
                self.storeUserInformation(profileImage: url!)
            }
        }
    }
    
    private func storeUserInformation(profileImage: URL) {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        guard let email = FirebaseManager.shared.auth.currentUser?.email else {
            return
        }
        //        guard let username = FirebaseManager.shared.auth.currentUser?.username else {
        //                return
        //            }
        let userData = ["email": email, "uid": uid, "profileImageURL": profileImage.absoluteString]
        FirebaseManager.shared.firestore.collection("Users").document(uid).setData(userData, merge: true) { err in
            if let err = err {
                print(err)
                return
            }
            print("success")
        }
    }
}
