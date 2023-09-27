//
//  swifty_proteinApp.swift
//  swifty-protein
//
//  Created by Léa Lescure on 26/09/2023.
//

import SwiftUI

@main
struct swifty_proteinApp: App {
    var body: some Scene {
        WindowGroup {
            LoginView(viewModel: .init())
        }
    }
}
