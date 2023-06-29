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
    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var imagePlaceHolder: String = ""
    @State private var showAlert = false
    @State private var showBioAlert = false
    @State private var showNameAlert = false
    @Binding var isLoggedIn: Bool
    let characterLimit = 50
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                                .foregroundColor(Color.black)
                            TextField("Select Profile Image", text: $imagePlaceHolder)
                                .disabled(true)
                                .foregroundColor(.secondary)
                            Spacer()
                            imagePickerButton
                        }
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
                    
                    Button(action: {
                    }) {
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(Color.black)
                            TextField("Set Username", text: $username)
                                .foregroundColor(Color.black)
                            Spacer()
                            usernameButton
                        }
                    }
                    
                    Button(action: {
                    }) {
                        HStack {
                            Image(systemName: "character.cursor.ibeam")
                                .foregroundColor(Color.black)
                            TextField("Set Bio", text: $bio)
                                .foregroundColor(Color.black)
                            Spacer()
                            bioButton
                        }
                    }
                    
                    Button(action: {
                    }) {
                        HStack {
                            Image(systemName: "textformat.alt")
                                .foregroundColor(Color.black)
                            TextField("Set Name", text: $name)                                    .foregroundColor(Color.black)
                            Spacer()
                            nameButton
                        }
                    }
                }
                Section {
                    Button(action: {
                        isLoggedIn = false
                        persistLogin()
                    }) {
                        HStack {
                            Text("Log Out")
                                .foregroundColor(Color.red)
                        }
                    }
                }
            }.navigationBarTitle("Settings")
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
                .onDisappear {
                    showSaveAlert = true
                }
        }
    }
    
    func persistLogin() {
        UserDefaults.standard.set(self.isLoggedIn, forKey: "isLoggedIn")
    }
    
    private var imagePickerButton: some View {
        Button(action: {
            showImagePicker = true
        }) {
            Image(systemName: "checkmark.circle.fill")
                .font(.body)
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
        Button(action: {
            showAlert = true
        }) {
            Image(systemName: "checkmark.circle.fill")
                .font(.body)
                .foregroundColor(.black)
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
    
    private var nameButton: some View {
        Button(action: {
            showNameAlert = true
        }) {
            Image(systemName: "checkmark.circle.fill")
                .font(.body)
                .foregroundColor(Color.black)
        }
        .alert(isPresented: $showNameAlert) {
            Alert(
                title: Text("Set Name"),
                message: nil,
                primaryButton: .default(Text("Save"), action: {
                    guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
                        return
                    }
                    let userData = ["name": name]
                    FirebaseManager.shared.firestore.collection("Users").document(uid).setData(userData, merge: true) { err in
                        if let err = err {
                            print(err)
                            return
                        }
                        print("Name saved successfully.")
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
    
    private var bioButton: some View {
        Button(action: {
            showBioAlert = true
        }) {
            Image(systemName: "checkmark.circle.fill")
                .font(.body)
                .foregroundColor(Color.black)
                .onChange(of: bio) { newValue in
                    if newValue.count > characterLimit {
                        bio = String(newValue.prefix(characterLimit))
                    }
                }
        }
        .alert(isPresented: $showBioAlert) {
            Alert(
                title: Text("Set Bio"),
                message: nil,
                primaryButton: .default(Text("Save"), action: {
                    guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
                        return
                    }
                    let userData = ["bio": bio]
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

struct AccountInfoView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isLoggedIn: Bool = true
        AccountInfoView(isLoggedIn: $isLoggedIn)
    }
}
