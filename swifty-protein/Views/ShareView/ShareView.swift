//
//  ShareView.swift
//  swifty-protein
//
//  Created by Léa Lescure on 12/10/2023.
//

import SwiftUI

struct ShareView: View {
    private let searchText: String
    private let onError: () -> Void
    
    @StateObject private var viewModel: ShareViewModel
    
    @State private var capturedView: UIView?
    
    init(seachText: String, onError: @escaping () -> Void, viewModel: ShareViewModel) {
        self.searchText = seachText
        self.onError = onError
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ShareableDetailView(searchText: searchText, onError: { onError() }, captureView: { view in
            self.capturedView = view
        })
        .navigationTitle(searchText)
        .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.large)
        Button(action: {
            if let view = capturedView {
                if let image = viewModel.captureScreen(view: view) {
                    viewModel.shareImage(image)
                }
            }
        }, label: {
            Image(systemName: "square.and.arrow.up")
                .padding()
        })
    }
}

#Preview {
    ShareView(seachText: "OT6", onError: { }, viewModel: .init())
}
