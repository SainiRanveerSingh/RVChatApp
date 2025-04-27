//
//  SignUpViewModel.swift
//  RVChatApp
//
//  Created by RV on 26/04/25.
//

import Foundation
import Combine

final class SignUpViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var errorMessage: String = ""
    @Published var isSignedUp: Bool = false // trigger navigation or success actions
    @Published var isSignUpInfoInvalid: Bool = false
    
    @Published var isLoading: Bool = false
    
    // MARK: - Validation Computed Properties
    var isEmailValid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    
    var isPasswordMatching: Bool {
        return password == confirmPassword && !password.isEmpty
    }
    
    var isFormValid: Bool {
        return isEmailValid && !username.isEmpty && isPasswordMatching
    }
    
    // MARK: - Sign Up Action
    func signUp(completion: @escaping ((String?) -> Void)) {
        guard isFormValid else {
            errorMessage = ErrorMessages.correctInformation
            self.isSignUpInfoInvalid = true
            return
        }
        isLoading = true
        self.signUpUser { message in
            self.isLoading = false
            completion(message)
        }
       
    }
    
    func checkIfUserAlreadyExists(completion: @escaping ((Bool) -> Void)) {
        FirebaseHelper.doesUsernameExists(username: username) { (exists) in
            if exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    
    func signUpUser(completion: @escaping ((String) -> Void)) {
        let username = username
        let password = password
        let mail = email
        
        FirebaseHelper.registerUserByAuth(username: username, email: mail, password: password) { (status, message, user) in
            if status {
                print(ErrorMessages.verificationMailSent)
                self.isSignedUp = true
                
                self.email = ""
                self.username = ""
                self.password = ""
                self.confirmPassword = ""
                self.errorMessage = ""
                completion(ErrorMessages.accountCreatedVerifyYourAccount)
            } else {
                print(message)
                self.isSignedUp = false
                self.isSignUpInfoInvalid = true
                self.errorMessage = message
                completion(message)
            }
        }
    }
}
