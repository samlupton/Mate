//
//  ProfileView.swift
//  Mate
//
//  Created by Samuel Lupton on 5/28/23.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import SDWebImageSwiftUI

struct ProfileView: View {

    @Binding var isLoggedIn: Bool
    @State var selectedImage: UIImage? = nil
    @State private var showImagePicker: Bool = false
    @State private var showSaveAlert: Bool = false
    @State private var username: String = ""
    @State private var showAlert = false
    @State private var showAccountInfo = false
    @ObservedObject private var vm = MainViewModel()

    var body: some View {
        
        VStack {
            HStack {
                Text("\(vm.user?.username ?? "User")")
                    .font(.title)
                    .bold()
                Spacer()
                Button(action: {
                    showAccountInfo = true
                }) {
                    Image(systemName: "gear")
                        .font(.system(size:25))
                        .foregroundColor(Color.black)
                }
                .sheet(isPresented: $showAccountInfo) {
                    AccountInfoView(isLoggedIn: $isLoggedIn)
                }
            }
            HStack(spacing: 16) {
                VStack{
                    Text("Followers")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("10k")
                        .font(.headline)
                }
                .padding()
                WebImage(url: URL(string: vm.user?.profileImageUrl  ?? ""))
                    .resizable()
                    .frame(width: 82, height: 84)
                    .clipShape(Circle())
                    .foregroundColor(Color.black)
                    .clipped()
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    .padding()
                    .foregroundColor(Color.black)
                
                VStack {
                    Text("Following")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("5k")
                        .font(.headline)
                }.padding()
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
            .padding()
            Spacer()
            
        }
        .padding()
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
                .onDisappear {
                    showSaveAlert = true
                }
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isLoggedIn: Bool = true
        ProfileView(isLoggedIn: $isLoggedIn)
    }
}


