//
//  DetailView.swift
//  swifty-protein
//
//  Created by Julien Richard on 09/10/2023.
//

import SwiftUI
import SceneKit

struct DetailView: View {
    // MARK: - Properties
    @State var searchText: String
    @State private var toggleHydrogen: Bool = false
    @State private var alternativeForm: Bool = false
    @State private var isLoading: Bool = true
    @State private var isError: Bool = false
    
    let onError: () -> Void
    
    // MARK: - Body
    var body: some View {
        contentView
            .alert(isPresented: $isError) {
                Alert(title: Text("Error"), message: Text("⚠️ An error occured while loading the molecule"), dismissButton: .default(Text("OK")) {
                    onError()
                })}
    }
}

// MARK: - UI Management
private extension DetailView {
    var contentView: some View {
        VStack {
            toggle
            ZStack {
                SceneKitView(searchText: searchText, toggleHydrogen: toggleHydrogen, alternativeForm: alternativeForm, isLoading: $isLoading, isError: $isError)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .scaleEffect(2)
                }
            }
        }
    }
    
    var toggle: some View {
        HStack(alignment: .firstTextBaseline) {
            Group {
                // add toggle hydrogen switch
                Toggle(isOn: $toggleHydrogen) {
                    Text("Hydro.")
                }.padding()
                // add toggle alternative form switch
                Toggle(isOn: $alternativeForm) {
                    Text("Alt.")
                }.padding()
            }
        }
    }
}
