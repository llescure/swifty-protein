//
//  TextFieldModifier.swift
//  swifty-protein
//
//  Created by Léa Lescure on 05/10/2023.
//

import SwiftUI

struct TextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.all, Spacing.small.rawValue)
            .border(.gray)
            .cornerRadius(Radius.medium.rawValue)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .tint(.gray)
    }
}

extension View {
    func textFieldModifier() -> some View {
        self.modifier(TextFieldModifier())
    }
}
