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
    @Published var login: String = ""
    @Published var password: String = ""
    @Published var isTextFieldIsIncorrect: Bool = false
    @Published var shouldCheckTextField: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let userDefaultsKey: String = "users"
    private var users: [User] = []
    
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
    
    init() {
        if let users = userDefaults.data(forKey: userDefaultsKey) {
            if let decoded = try? JSONDecoder().decode([User].self, from: users) {
                self.users = decoded
                return
            }
        }
    }
}

// MARK: - Biometry management
extension LoginViewModel {
    func checkBiometry() -> Bool {
        var error: NSError?
        let context = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            checkBiometryType(context)
            return true
        } else {
            print("Biometry is not available")
            return false
        }
    }
    
    func checkBiometryType(_ context: LAContext) {
        switch context.biometryType {
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
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
            Task { @MainActor in
                if success {
                    self.userAuthenticationStatus = .success
                    self.didAuthenticationFail = false
                } else {
                    self.userAuthenticationStatus = .failure
                    self.didAuthenticationFail = true
                }
            }
        }
    }
}

// MARK: - Textfield management
extension LoginViewModel {
    func checkField() {
        if login.isEmpty || password.isEmpty && shouldCheckTextField {
            self.isTextFieldIsIncorrect = true
            return
        }
        self.isTextFieldIsIncorrect = false
    }
    
    func authenticateManuallyUser(action: () -> Void) {
        if users.contains { $0.login == self.login && $0.password == self.password } {
            print("User already exists")
            action()
        } else {
            users.append(User(login: login, password: password))
            print("User created")
            save()
            action()
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(users) {
            userDefaults.set(encoded, forKey: userDefaultsKey)
        }
    }
}
