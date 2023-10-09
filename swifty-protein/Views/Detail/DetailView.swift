//
//  DetailView.swift
//  swifty-protein
//
//  Created by Julien Richard on 09/10/2023.
//

import SwiftUI
import SceneKit

struct DetailView: View {
    @State var searchText: String

    var body: some View {
        VStack {
            SceneKitView(searchText: $searchText)
        }
    }
}
