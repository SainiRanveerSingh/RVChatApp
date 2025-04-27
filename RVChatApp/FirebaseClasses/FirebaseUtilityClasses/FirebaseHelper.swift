//
//  FirebaseHelper.swift
//  RVChatApp
//
//  Created by RV on 26/04/25.
//

import Foundation
import Firebase
import FirebaseAuth


var currentFBUser : AuthDataResult!
class FirebaseHelper {
    static let db = Firestore.firestore()
    
    static func doesUsernameExists(username: String, completionHandler: @escaping ((Bool) -> Void)) {
        db.collection("users").document(username).getDocument { (document, _) in
            if let document = document, document.exists {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
    
    
    //To register user on firebase using Auth
    class func registerUserByAuth(username: String, email:String, password:String, completion: @escaping (Bool, String, User?) -> Swift.Void) {
        Auth.auth().createUser(withEmail: email, password: password) {(authResult, error) in
            if let user = authResult?.user {
                currentFBUser = authResult

                sendEmailVerifiationMail { (status, message) in
                    let data = ["username": username, "email": email, "id": user.uid, "profileImageUrl": user.photoURL ?? ""] as [String : Any]
                    db.collection("users").document(user.uid).setData(data) { (errorCloudStore) in
                        if let err = errorCloudStore {
                            completion(false, err.localizedDescription, nil)
                        } else {
                            FirebaseHelper.signOutUser()
                            completion(true, message, user)
                        }
                    }
                }
            } else {
                completion(false, error?.localizedDescription.description ?? "Error", nil)
            }
        }
    }
    
    class func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = authResult?.user {
                currentFBUser = authResult
                SessionManager.shared.storeUser(currentFBUser.user)
                self.checkLoggrdInUserExists(userId: currentFBUser.user.uid) { status in
                    if status {
                        completion(.success(user.uid))
                    } else {
                        self.addLoggedInUserDetails { errorMessage in
                            if errorMessage != nil {
                                print(errorMessage ?? "Some error in adding Logged In user Data")
                            }
                            completion(.success(user.uid))
                        }
                    }
                }
            }
        }
    }
    
    static func checkLoggrdInUserExists(userId: String, completionHandler: @escaping ((Bool) -> Void)) {
        db.collection("users").document(userId).getDocument { (document, _) in
            if let document = document, document.exists {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
    
    static func addLoggedInUserDetails(completionHandler: @escaping ((String?) -> Void)) {
        let data = ["username": currentFBUser.user.displayName ?? "", "email": currentFBUser.user.email ?? "", "id": currentFBUser.user.uid, "profileImageUrl": currentFBUser.user.photoURL ?? ""] as [String : Any]
        db.collection("users").document(currentFBUser.user.uid).setData(data) { (err) in
            if err == nil {
                completionHandler(nil)
            } else {
                completionHandler(err?.localizedDescription)
            }
        }
    }
    
    class func signOutUser() {
        do {
            try Auth.auth().signOut()
            SessionManager.shared.logout()
        }
        catch { print("already logged out") }
    }
    
    //To send the verification email on logged in user's email
    class func sendEmailVerifiationMail(completion: @escaping (Bool, String) -> Swift.Void) {
        if currentFBUser != nil {
            currentFBUser.user.sendEmailVerification(completion: { (error) in
                if error != nil
                {
                    print("Error in sending verification mail")
                    completion(false, "Error in sending verification mail")
                }
                else
                {
                    print("Verification mail sent.")
                    completion(true, "Verification mail sent.")
                }
            })
        } else if Auth.auth().currentUser != nil {
            Auth.auth().currentUser!.sendEmailVerification(completion: { (error) in
                if error != nil
                {
                    print("Error in sending verification mail")
                    completion(false, "Error in sending verification mail")
                }
                else
                {
                    print("Verification mail sent.")
                    completion(true, "Verification mail sent.")
                }
            })
        } else {
            completion(false, "Error in sending verification mail")
        }
        
    }
    
}
