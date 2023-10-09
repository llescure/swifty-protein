//
//  CornerRadiusModifier.swift
//  swifty-protein
//
//  Created by Léa Lescure on 07/10/2023.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: Radius) -> some View {
        self.cornerRadius(radius.rawValue)
    }
}
