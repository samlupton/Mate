//
//  OtherUserProfileView.swift
//  Mate
//
//  Created by Samuel Lupton on 5/30/23.
//
import Firebase
import SwiftUI
import SDWebImageSwiftUI

struct OtherUserProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    var username: String
    var profileImage: String
    
    var body: some View {
        VStack {
            HStack (spacing: 16) {
                VStack{
                    Text("Followers")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("10k")
                        .font(.headline)
                }.padding()
                VStack {
                    //                Text("Profile of \(username)")
                    //                    .navigationBarTitle(Text(username.lowercased()), displayMode: .inline).textCase(.lowercase)
                    //                    .navigationBarItems(leading: backButton)
                    //                    .accentColor(.black)
                    WebImage(url: URL(string: profileImage))
                        .resizable()
                        .frame(width: 82, height: 84)
                        .clipShape(Circle())
                        .foregroundColor(Color.black)
                        .clipped()
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        .padding()
                        .foregroundColor(Color.black)
                }
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
        .navigationBarTitle(Text(username.lowercased()), displayMode: .inline)
        .textCase(.lowercase)
        .navigationBarItems(leading: backButton)
        .accentColor(.black)
        .navigationBarBackButtonHidden(true)
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .imageScale(.large)
        }
    }
}


struct OtherUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        @State var username: String = ""
        @State var profileImage: String = ""

        OtherUserProfileView(username: username, profileImage: profileImage)
    }
}
