//
//  LoginView.swift
//  swifty-protein
//
//  Created by Léa Lescure on 26/09/2023.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    
    @State private var login: String = ""
    @State private var password: String = ""
    @State private var isBiometryAvailable: Bool
    
    @FocusState private var isFocused: Bool
    
    @Environment(\.scenePhase) var scenePhase
    
    private let onUserAuthenticated: () -> Void
    
    init(viewModel: LoginViewModel, onUserAuthenticated: @escaping () -> Void) {
        self.onUserAuthenticated = onUserAuthenticated
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._isBiometryAvailable = State(wrappedValue: viewModel.checkBiometry())
    }
    
    var body: some View {
        contentView
            .background(.gray.opacity(0.2))
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
    }
}

private extension LoginView {
    var contentView: some View {
        VStack(spacing: .zero) {
            Text("Swifty Protein")
                .font(.largeTitle)
            LottieView(name: "loginAnimation", loopMode: .loop)
            loginMethod()
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding(.vertical, Spacing.xxLarge.rawValue)
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
        })
        .buttonStyle(ButtonBouncyStyle())
    }
    
    var textfieldLogin: some View {
        VStack {
            TextField("Login", text: $login, prompt: Text("Enter a login"))
                .padding(.all, Spacing.small.rawValue)
                .border(.gray)
                .cornerRadius(Radius.medium.rawValue)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .submitLabel(.next)
            SecureField("Password", text: $password, prompt: Text("Enter a password"))
                .padding(.all, Spacing.small.rawValue)
                .border(.gray)
                .cornerRadius(Radius.medium.rawValue)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .submitLabel(.continue)
        }
        .padding(.horizontal, Spacing.xxLarge.rawValue)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: .init(), onUserAuthenticated: {})
    }
}
