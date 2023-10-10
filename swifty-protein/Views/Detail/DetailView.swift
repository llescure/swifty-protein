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
    @State var toggleHydrogen: Bool
    @State var alternativeForm: Bool
    @State var isLoading: Bool

    var body: some View {
        VStack {
            HStack {
                // add toggle hydrogen switch
                Toggle(isOn: $toggleHydrogen) {
                    Text("Hydro.")
                }
                .padding()
                // add toggle alternative form switch
                Toggle(isOn: $alternativeForm) {
                    Text("Alt.")
                }
                .padding()
            }
            ZStack {
                SceneKitView(searchText: $searchText, toggleHydrogen: $toggleHydrogen, alternativeForm: $alternativeForm)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(2)
                }
            }
        }
    }
}
