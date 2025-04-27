//
//  SignUpView.swift
//  RVChatApp
//
//  Created by RV on 26/04/25.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
        
        var body: some View {
            NavigationStack {
                VStack(spacing: 20) {
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Group {
                        TextField("Email Address", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        TextField("Username", text: $viewModel.username)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $viewModel.password)
                        
                        SecureField("Confirm Password", text: $viewModel.confirmPassword)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                    
                    Button(action: {
                        viewModel.signUp { message in
                            print(message ?? "User Created")
                        }
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isFormValid ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!viewModel.isFormValid)
                    .padding(.top)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Sign Up")
                .navigationBarTitleDisplayMode(.inline)
                .alert(isPresented: $viewModel.isSignedUp) {
                    Alert(
                        title: Text("Account created successfully!"),
                        message: Text(ErrorMessages.accountCreatedVerifyYourAccount),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
}
#Preview {
    SignUpView()
}
