//
//  LoginViewModel.swift
//  RVChatApp
//
//  Created by RV on 26/04/25.
//

import Foundation
import SwiftUI
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoggedIn = false
    @Published var isInvalidUser = false
    @Published var isLoading: Bool = false

    // MARK: - Validation Computed Properties
    var isEmailValid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    
    func login(completion: @escaping ((String?) -> Void)) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = ErrorMessages.requiredError
            self.isInvalidUser = true
            return
        }
        
        guard isEmailValid else {
            errorMessage = ErrorMessages.validMail
            self.isInvalidUser = true
            return
        }
        
        isLoading = true
        FirebaseHelper.login(email: email, password: password) { resultData in
            switch resultData {
            case .success(let value):
                print(value)
                self.isLoggedIn = true
                self.email = ""
                self.password = ""
                self.isLoading = false
                
                Task {
                    await FirebaseHelper.getAllUserList { status, messsage in
                        print(messsage)
                    }
                }
                completion("success")
            case .failure(let error):
                print(error.localizedDescription)
                self.isInvalidUser = true
                self.isLoading = false
                completion(error.localizedDescription)
            }
        }
    }
}
