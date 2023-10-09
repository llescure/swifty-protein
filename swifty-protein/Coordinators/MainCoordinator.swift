//
//  MainCoordinator.swift
//  swifty-protein
//
//  Created by Léa Lescure on 27/09/2023.
//

import SwiftUI

struct MainCoordinator: View {
    @State private var path: [PushableView] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            contentView
                .navigationDestination(for: PushableView.self, destination: pushableView)
        }
    }
}

private extension MainCoordinator {
    enum PushableView: Hashable {
        case search
        case detail(Ligand)
    }
    
    @ViewBuilder
    func pushableView(_ view: PushableView) -> some View {
        switch view {
        case .search:
            SearchView { ligand in
                path.append(.detail(ligand))
            }
        case let .detail(ligand):
            DetailView(id: ligand.id)
                .navigationTitle(ligand.id)
                .navigationBarTitleDisplayMode(.large)
        }
    }
    
    var contentView: some View {
        LoginView(viewModel: .init()) {
            path.append(.search)
        }
    }
}
