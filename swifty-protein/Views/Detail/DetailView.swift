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
    @State var toggleHydrogen: Bool = false
    @State var alternativeForm: Bool = false
    @State var isLoading: Bool = true
    @Binding var isError: Bool
    
    // MARK: - Body
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

struct ShareableDetailView: UIViewRepresentable {
    // MARK: - Properties
    @Binding var isError: Bool
    let searchText: String
    var captureView: ((UIView) -> Void)?
    
    // MARK: - Body
    func makeUIView(context: Context) -> UIView {
        let hostingController = UIHostingController(rootView: DetailView(searchText: searchText, isError: $isError))
        DispatchQueue.main.async {
            self.captureView?(hostingController.view)
        }
        return hostingController.view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
