//
//  PostView.swift
//  Mate
//
//  Created by Samuel Lupton on 5/28/23.
//

import SwiftUI
import SwiftyJSON
import SDWebImageSwiftUI
import WebKit

struct PostView: View {
    @State private var postTitle = ""
    @State private var postCaption = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Title", text: $postTitle)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.title)
                    .padding()
                TextField("Caption", text: $postCaption)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .navigationBarItems(
                        leading: draftsButton,
                        trailing: buttonBar
                    )
                Spacer()
            }
        }
    }
    var downloadButton: some View {
        Button(action: {
        }) {
            Image(systemName: "square.and.arrow.down")
                .foregroundColor(.blue)
        }
    }
    
    var draftsButton: some View {
        Button(action: {
        }) {
            Image(systemName: "arrow.up.bin")
                .foregroundColor(.blue)
        }
    }
    
    
    var addButton: some View {
        Button(action: {
        }) {
            Image(systemName: "plus")
                .foregroundColor(.blue)
        }
    }
    
    var buttonBar: some View {
        HStack {
            Spacer()
            downloadButton
            addButton
        }
    }
}
