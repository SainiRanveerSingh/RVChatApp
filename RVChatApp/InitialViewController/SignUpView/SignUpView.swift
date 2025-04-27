//
//  SignUpView.swift
//  RVChatApp
//
//  Created by RV on 26/04/25.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) private var dismiss // to programmatically go back
        var body: some View {
            NavigationStack {
                ZStack{
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
                        
                        if viewModel.errorMessage != "" {
                            Text(viewModel.errorMessage)
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
                    
                    .alert(isPresented: $viewModel.isSignUpInfoInvalid) {
                        Alert(
                            title: Text("Error in Sign Up"),
                            message: Text(viewModel.errorMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    //--
                    .alert("Account created successfully!", isPresented: $viewModel.isSignedUp, actions: {
                        Button("OK", role: .cancel) {
                            if self.viewModel.isSignedUp {
                                    dismiss()
                            }
                        }
                    }, message: {
                        Text(ErrorMessages.accountCreatedVerifyYourAccount)
                    })
                    //--
                    // Show Progress HUD
                    if viewModel.isLoading {
                        ZStack {
                            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                            VStack {
                                ActivityIndicatorView()
                                Text("Loading...")
                                    .padding(.top, 8)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                        }
                    }
                }
            }
        }
}
#Preview {
    SignUpView()
}
