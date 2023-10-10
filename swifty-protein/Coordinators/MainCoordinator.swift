//
//  MainCoordinator.swift
//  swifty-protein
//
//  Created by Léa Lescure on 27/09/2023.
//

import SwiftUI

struct MainCoordinator: View {
    @State private var path: [PushableView] = []
    @State private var isError: Bool = false
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        NavigationStack(path: $path) {
            contentView
                .navigationDestination(for: PushableView.self, destination: pushableView)
        }
        .onChange(of: scenePhase) { _ in
            if scenePhase == .background {
                path.removeAll()
            }
        }
    }
}

internal extension MainCoordinator {
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
            DetailView(searchText: ligand.id, isError: $isError)
                .navigationTitle(ligand.id)
                .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.large)
                .alert(isPresented: $isError) {
                    Alert(title: Text("Error"), message: Text("⚠️ An error occured while loading the molecule"), dismissButton: .default(Text("OK")) {
                        isError = false
                        path.removeLast()
                    })
                }
        }
    }
    
    var contentView: some View {
        LoginView(viewModel: .init()) {
            path.append(.search)
        }
    }
}
