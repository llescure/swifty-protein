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
    @State var isError: Bool = false
    @Binding var path: [MainCoordinator.PushableView]
    
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
                    .alert(isPresented: $isError) {
                        Alert(title: Text("Error"), message: Text("An error occured while loading the molecule"), dismissButton: .default(Text("OK")) {
                            isError = false
                            path.removeLast()
                        })
                    }

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .scaleEffect(2)
                }
            }
        }
    }
}
