//
//  PaddingModifier.swift
//  swifty-protein
//
//  Created by Léa Lescure on 07/10/2023.
//

import SwiftUI

extension View {
    func padding(_ edges: Edge.Set, _ length: Spacing) -> some View {
        self.padding(edges, length.rawValue)
    }
}
