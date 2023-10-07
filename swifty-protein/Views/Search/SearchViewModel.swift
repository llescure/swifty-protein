//
//  SearchViewModel.swift
//  swifty-protein
//
//  Created by Léa Lescure on 26/09/2023.
//

import Foundation

final class SearchViewModel: ObservableObject {
    @Published var searchLigand: String = ""

    var ligands: [Ligand] = []
    
    init() {
        ligands = createLigands()
    }
}

// MARK: - Create ligands struct
extension SearchViewModel {
    private func createLigands() -> [Ligand] {
        var ligands: [Ligand] = []
        if let path = Bundle.main.path(forResource: "ligands", ofType: "txt") {
            do {
                let file = try String(contentsOfFile: path)
                let lines: [String] = file.components(separatedBy: "\n")
                _ = lines.map({ ligands.append(.init(id: $0)) })
            } catch let error {
                print("Fatal Error: \(error.localizedDescription)")
            }
        }
        return ligands
    }
    
    var searchResults: [Ligand] {
        if searchLigand.isEmpty {
            return ligands
        } else {
            return ligands.filter { $0.id.contains(searchLigand) }
        }
    }
}
