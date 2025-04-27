//
//  LoginViewModel.swift
//  RVChatApp
//
//  Created by RV on 26/04/25.
//

import Foundation
import SwiftUI
final class LoginViewModel: ObservableObject {
    //@EnvironmentObject var appViewModel: AppViewModel
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoggedIn = false

    func login(completion: @escaping ((String?) -> Void)) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill all fields."
            return
        }

        FirebaseHelper.login(email: email, password: password) { resultData in
            switch resultData {
            case .success(let value):
                print(value)
                self.isLoggedIn = true
                completion("success")
            case .failure(let error):
                print(error.localizedDescription)
                completion(error.localizedDescription)
            }
        }
    }
}
