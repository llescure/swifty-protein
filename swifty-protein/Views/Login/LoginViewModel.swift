//
//  LoginViewModel.swift
//  swifty-protein
//
//  Created by Léa Lescure on 26/09/2023.
//

import Foundation
import LocalAuthentication

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var isBiometryAvailable: Bool = false
    @Published var isUserLoggedIn: Bool = false

    init() { }
}

extension LoginViewModel {
    @MainActor
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            self.isBiometryAvailable = true
            let reason = "We need to unlock your data."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                if success {
                    self.isUserLoggedIn = true
                    print("You are authenticated")
                } else {
                    self.isUserLoggedIn = false
                    print("We could not authenticate you")
                }
            }
        } else {
            self.isBiometryAvailable = false
            print("Biometry is not available")
        }
    }
}
