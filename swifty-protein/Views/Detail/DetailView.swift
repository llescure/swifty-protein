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
    @State var toggleHydrogen: Bool = false
    @State var alternativeForm: Bool = false
    @State var isLoading: Bool = true
    @Binding var isError: Bool
    
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
                SceneKitView(searchText: $searchText, toggleHydrogen: $toggleHydrogen, alternativeForm: $alternativeForm, isLoading: $isLoading, isError: $isError)
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .scaleEffect(2)
                }
            }
        }
    }
}
