//
//  HighlightsView.swift
//  Mate
//
//  Created by Samuel Lupton on 6/24/23.
//

import Foundation
import SwiftUI

struct HighlightsView: View {
    var body: some View {
        VStack {
                    Text("Highlights View")
                }
                .background(Color.white) // Optional: Add a background color
                .edgesIgnoringSafeArea(.all)
    }
}

struct Highlights_Previews: PreviewProvider {
    static var previews: some View {
        HighlightsView()
    }
}

