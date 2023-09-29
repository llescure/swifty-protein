//
//  LoginViewModel.swift
//  swifty-protein
//
//  Created by Léa Lescure on 26/09/2023.
//

import Foundation
import LocalAuthentication

final class LoginViewModel: ObservableObject {
    @Published var userAuthenticationStatus: UserAuthenticationStatus = .loading
    @Published var didAuthenticationFail: Bool = false
    @Published var biometryType: BiometricType = .none
    @Published var isBiometryAvailable = false
    
    enum UserAuthenticationStatus {
        case loading
        case success
        case failure
    }
    
    enum BiometricType {
        case none
        case touch
        case face
    }
    
    init() {}
}

extension LoginViewModel {
    func checkBiometry() -> Bool {
        var error: NSError?
        let context = LAContext()
        
        didAuthenticationFail = false
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            checkBiometryType(context)
            return true
        } else {
            print("Biometry is not available")
            return false
        }
    }
    
    func checkBiometryType(_ context: LAContext) {
        switch(context.biometryType) {
        case .touchID:
            biometryType = .touch
        case .faceID:
            biometryType = .face
        default:
            biometryType = .none
        }
    }
    
    func authenticate() {
        let reason = "We need to unlock your data 😈"
        let context = LAContext()
        self.userAuthenticationStatus = .loading

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
            Task { @MainActor in
                if success {
                    self.userAuthenticationStatus = .success
                    self.didAuthenticationFail = false
                    print("You are authenticated")
                } else {
                    self.userAuthenticationStatus = .failure
                    self.didAuthenticationFail = true
                    print("We could not authenticate you")
                }
            }
        }
    }
}
