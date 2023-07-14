//
//  OpenBetsView.swift
//  Mate
//
//  Created by Samuel Lupton on 6/24/23.
//

import Foundation
import SwiftUI

struct OpenBetsView: View {
    var body: some View {
        VStack {
            Color.purple
                            .ignoresSafeArea()
                    Text("Open Bets View")
                }
                .foregroundColor(Color.green) // Optional: Add a background color
                .edgesIgnoringSafeArea(.all)
    }
}

struct OpenbetsView_Previews: PreviewProvider {
    static var previews: some View {
        OpenBetsView()
    }
}

