//
//  LoginView.swift
//  swifty-protein
//
//  Created by Léa Lescure on 26/09/2023.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    
    @State private var isBiometryAvailable: Bool
    
    @FocusState private var currentFieldFocused: LogInField?
    
    @Environment(\.scenePhase) var scenePhase
    
    private let onUserAuthenticated: () -> Void
    
    init(viewModel: LoginViewModel, onUserAuthenticated: @escaping () -> Void) {
        self.onUserAuthenticated = onUserAuthenticated
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._isBiometryAvailable = State(wrappedValue: viewModel.checkBiometry())
        // To have a clear button in the textfield
        UITextField.appearance().clearButtonMode = .whileEditing
    }
    
    var body: some View {
        contentView
        // Textfield management
            .onSubmit {
                focusNextField()
            }
            .background(.gray.opacity(0.2))
        // Biometry management
            .onAppear {
                self.isBiometryAvailable = viewModel.checkBiometry()
            }
            .onChange(of: viewModel.userAuthenticationStatus, perform: { userAuthenticationStatus in
                if userAuthenticationStatus == .success {
                    onUserAuthenticated()
                }
            })
            .onChange(of: scenePhase) { _ in
                self.isBiometryAvailable = viewModel.checkBiometry()
            }
            .alert("Error", isPresented: $viewModel.didAuthenticationFail, actions: {}, message: {
                Text("⚠️ Authentication failed")
            })
            .alert("Error", isPresented: $viewModel.isTextFieldIsIncorrect, actions: {}, message: {
                Text("⚠️ Login and/or password must not be empty")
            })
    }
}

private extension LoginView {
    var contentView: some View {
        VStack(spacing: .zero) {
            Text("Swifty Protein")
                .font(.largeTitle)
                .frame(maxHeight: .infinity, alignment: .top)
//            LottieView(name: "loginAnimation")
                .scaledToFill()
            loginMethod()
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding(.vertical, .xxLarge)
    }
    
    @ViewBuilder
    func loginMethod() -> some View {
        if isBiometryAvailable {
            biometricLogin
        } else {
            textfieldLogin
        }
    }
    
    var biometricLogin: some View {
        Button(action: {
            viewModel.authenticate()
            isBiometryAvailable = viewModel.checkBiometry()
        }, label: {
            Image(systemName: viewModel.biometryType == .touch ? "touchid" : "faceid")
                .foregroundStyle(viewModel.biometryType == .touch ? .pink : .blue)
                .font(.largeTitle)
        })
        .buttonStyle(ButtonBouncyStyle())
    }
}
 
// MARK: - Textfield management
private extension LoginView {
    var textfieldLogin: some View {
        VStack(spacing: Spacing.large.rawValue) {
            VStack {
                TextField("Login", text: $viewModel.login, prompt: Text("Enter a login"))
                    .textFieldModifier()
                    .submitLabel(.next)
                    .focused($currentFieldFocused, equals: .login)
                SecureField("Password", text: $viewModel.password, prompt: Text("Enter a password"))
                    .textFieldModifier()
                    .submitLabel(.continue)
                    .focused($currentFieldFocused, equals: .password)
            }
            Button(action: {
                viewModel.checkField()
                if !viewModel.isTextFieldIsIncorrect {
                    onUserAuthenticated()
                }
            }, label: {
                Text("Log in")
                    .frame(maxWidth: .infinity)
                    .padding(.all, .small)
                    .background(.gray)
                    .cornerRadius(.medium)
            })
            .buttonStyle(ButtonBouncyStyle())
        }
        .padding(.horizontal, .xxLarge)
    }
    
    func focusNextField() {
        if currentFieldFocused == .login {
            viewModel.checkField()
            currentFieldFocused = .password
        } else {
            viewModel.checkField()
            if !viewModel.isTextFieldIsIncorrect {
                onUserAuthenticated()
            }
        }
    }
    
    enum LogInField: Hashable {
        case login
        case password
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: .init(), onUserAuthenticated: {})
    }
}
