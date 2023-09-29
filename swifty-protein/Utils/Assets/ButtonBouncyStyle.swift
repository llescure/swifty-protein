//
//  ButtonBouncyStyle.swift
//  swifty-protein
//
//  Created by Léa Lescure on 28/09/2023.
//

import SwiftUI

struct ButtonBouncyStyle: ButtonStyle {
    
    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
    }
}
