//
//  ShareableDetailView.swift
//  swifty-protein
//
//  Created by Léa Lescure on 12/10/2023.
//

import Foundation
import SwiftUI

struct ShareableDetailView: UIViewRepresentable {
    // MARK: - Properties
    let searchText: String
    let onError: () -> Void
    var captureView: ((UIView) -> Void)?
    
    // MARK: - Body
    func makeUIView(context: Context) -> UIView {
        let hostingController = UIHostingController(rootView: DetailView(searchText: searchText, onError: { onError() }))
        DispatchQueue.main.async {
            self.captureView?(hostingController.view)
        }
        return hostingController.view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
