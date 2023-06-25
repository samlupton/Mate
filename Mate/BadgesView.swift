//
//  BadgesView.swift
//  Mate
//
//  Created by Samuel Lupton on 6/24/23.
//

import Foundation
import SwiftUI

struct BadgesView: View {
    var body: some View {
        VStack {
                    Text("Badges View")
                }
                .background(Color.white) // Optional: Add a background color
                .edgesIgnoringSafeArea(.all)
    }
}

struct BadgesView_Previews: PreviewProvider {
    static var previews: some View {
        BadgesView()
    }
}

