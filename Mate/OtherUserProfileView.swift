//
//  OtherUserProfileView.swift
//  Mate
//
//  Created by Samuel Lupton on 5/30/23.
//
import Firebase
import SwiftUI

struct OtherUserProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    var username: String
    
    var body: some View {
        Text("Profile of \(username)")
            .navigationBarTitle(Text(username), displayMode: .inline)
            .navigationBarItems(leading: backButton) // Apply custom appearance to the back button
            .accentColor(.black) // Set the accent color to blue
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
        OtherUserProfileView(username: username)
    }
}
