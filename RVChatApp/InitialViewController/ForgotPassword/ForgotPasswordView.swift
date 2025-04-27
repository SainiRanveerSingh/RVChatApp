//
//  ForgotPasswordView.swift
//  RVChatApp
//
//  Created by RV on 26/04/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss // to programmatically go back
    @State private var email: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false // Track if password reset was successful
    @StateObject private var viewModel = ForgotPasswordViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Forgot Password")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Enter your registered email address to reset your password.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("Email Address", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                Button(action: {
                    if viewModel.isValidEmail(email) {
                        alertMessage = "An email has been sent to \(email) with instructions to reset your password."
                        email = ""
                        isSuccess = true
                    } else {
                        alertMessage = "Please enter a valid email address."
                        isSuccess = false
                    }
                    showAlert = true
                }) {
                    Text("Reset Password")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(email.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(email.isEmpty)
                .padding(.top)
                
                Spacer()
            }
            .padding()
            .alert("Password Reset", isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) {
                    if isSuccess {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            dismiss() // Go back after 2 seconds
                        }
                    }
                }
            }, message: {
                Text(alertMessage)
            })
        }
    }
    
    
}

#Preview {
    ForgotPasswordView()
}
