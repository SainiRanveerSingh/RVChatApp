//
//  LoginView.swift
//  RVChatApp
//
//  Created by RV on 25/04/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSecure: Bool = true
    @State private var showSignUpView = false
    @State private var showForgetPasswordView = false
    @State private var showChatView = false
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("RV Chat App")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                TextField("Email Address", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
            }
            
            Button(action: {
                print("Forgot Password Tapped")
                showForgetPasswordView = true
            }) {
                Text("Forgot Password?")
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            Button(action: {
                print("Sign In Tapped with email: \(viewModel.email), password: \(viewModel.password)")
                viewModel.login { status in
                    print(status ?? "User Login Status")
                }
                //showChatView = true
            }) {
                Text("Sign In")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top)
            
            
            
            HStack {
                Text("Don't have an account?")
                Button(action: {
                    print("Sign Up Tapped")
                    showSignUpView = true
                }) {
                    Text("Sign Up")
                        .foregroundColor(.blue)
                }
            }
            .font(.footnote)
            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        // Navigation trigger
        .navigationDestination(isPresented: $viewModel.isLoggedIn) {
            
            ChatView(userId: SessionManager.currentUserId)
                .navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $showSignUpView) {
            SignUpView()
        }
        .navigationDestination(isPresented: $showForgetPasswordView) {
            ForgotPasswordView()
        }
        .alert(isPresented: $viewModel.isInvalidUser) {
            Alert(
                title: Text("Invalid Credentials!"),
                message: Text(self.viewModel.errorMessage ?? ErrorMessages.checkUserNameEmail),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    LoginView()
}
