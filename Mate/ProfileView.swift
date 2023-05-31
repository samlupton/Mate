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
    @State private var showingFollowersView = false


    var body: some View {
        VStack {
            HStack {
                Text("\(vm.user?.username ?? "User")")
                    .font(.title)
                    .bold()
                    .textCase(.lowercase)
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
                Button(action: {
                    showingFollowersView = true
                }) {
                    VStack {
                        Text("Followers")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("10k")
                            .font(.headline)
                    }
                }.sheet(isPresented: $showingFollowersView) {
                    FollowingListView()
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
                }
                .padding()
            }
            Spacer()
        }
        .padding()
        .navigationBarHidden(true)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isLoggedIn: Bool = true
        ProfileView(isLoggedIn: $isLoggedIn)
    }
}


