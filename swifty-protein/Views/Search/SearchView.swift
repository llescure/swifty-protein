//
//  SearchView.swift
//  swifty-protein
//
//  Created by Léa Lescure on 26/09/2023.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    private let onChooseLigand: (Ligand) -> Void
    
    init(onChooseLigand: @escaping (Ligand) -> Void) {
        _viewModel = StateObject(wrappedValue: .init())
        self.onChooseLigand = onChooseLigand
    }
    
    var body: some View {
        contentView
    }
}

private extension SearchView {
    var contentView: some View {
        listView
            .overlay {
                if viewModel.searchResults.isEmpty {
                    emptySearch
                }
            }
    }
    
    var listView: some View {
        List {
            ForEach(viewModel.searchResults) { ligand in
                Button(action: {
                    onChooseLigand(ligand) }, label: {
                    Text(ligand.id)
                })
            }
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchLigand, placement: .navigationBarDrawer(displayMode: .always))
    }
    
    var emptySearch: some View {
        VStack(spacing: Spacing.medium.rawValue) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
            Text("No result were found for \(viewModel.searchLigand)")
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(onChooseLigand: {_ in })
    }
}
