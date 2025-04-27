//
//  SignUpViewModel.swift
//  RVChatApp
//
//  Created by RV on 26/04/25.
//

import Foundation
import Combine

class SignUpViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var errorMessage: String?
    @Published var isSignedUp: Bool = false // trigger navigation or success actions
    
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
            errorMessage = "Please fill all fields correctly."
            return
        }
        checkIfUserAlreadyExists { status in
            if !status {
                self.signUpUser { message in
                    completion(message)
                }
            } else {
                completion(ErrorMessages.alreadyRegistered)
            }
        }
       
    }
    
    /*
     
     // Simulate sign-up logic (normally call an API)
     print("Signing up with Email: \(email), Username: \(username)")
     
     // After success
     isSignedUp = true
     
    */
    
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
                completion(ErrorMessages.accountCreatedVerifyYourAccount)
            } else {
                print(message)
                completion(ErrorMessages.responseErrorTryAgain)
            }
        }
    }
}
