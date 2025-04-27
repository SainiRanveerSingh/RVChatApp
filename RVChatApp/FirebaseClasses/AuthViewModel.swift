//
//  AuthViewModel.swift
//  RVChatApp
//
//  Created by RV on 24/04/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    @Published var user: User?
    static let db = Firestore.firestore()
    
    private var authListener: AuthStateDidChangeListenerHandle?
    
    init() {
        authListener = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }
    
    static func doesUsernameExists(username: String, completionHandler: @escaping ((Bool) -> Void)) {
        db.collection("Account").document(username).getDocument { (document, _) in
            if let document = document, document.exists {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let user = result?.user {
                completion(.success(user))
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let user = result?.user {
                completion(.success(user))
            }
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
    }
}

