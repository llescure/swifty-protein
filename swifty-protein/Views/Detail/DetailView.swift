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
    @State var showShareLink: Bool = false
    @Binding var isError: Bool
    
    var body: some View {
        contentView
    }
}

// MARK: - UI Management
private extension DetailView {
    var contentView: some View {
        VStack {
            toggle
            ZStack {
                SceneKitView(searchText: searchText, toggleHydrogen: toggleHydrogen, alternativeForm: alternativeForm, isLoading: $isLoading, isError: $isError, showShareLink: showShareLink)
                
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
                }
                // add toggle alternative form switch
                Toggle(isOn: $alternativeForm) {
                    Text("Alt.")
                }
                Button(action: {
                    self.showShareLink = true
                }, label: {
                    Image(systemName: "square.and.arrow.up")
                })
            }
            .padding()
        }
    }
}
