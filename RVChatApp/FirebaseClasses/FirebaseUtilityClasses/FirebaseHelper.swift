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
    
    static func loginUser(username: String, password: String, completionHandler: @escaping ((String?) -> Void)) {
        db.collection("Account").document(username).getDocument { (document, _) in
            if let document = document, document.exists {
                let userData = document.data()
                print(userData ?? "No Data Found")
            }
        }
    }
    
    //To register user on firebase using Auth
    class func registerUserByAuth(username: String, email:String, password:String, completion: @escaping (Bool, String, User?) -> Swift.Void) {
        Auth.auth().createUser(withEmail: email, password: password) {(authResult, error) in
            if let user = authResult?.user {
                currentFBUser = authResult
                sendEmailVerifiationMail { (status, message) in
                    //let data = ["password": password, "email": email, "status": 1] as [String : Any]
                    let data = ["username": username, "email": email, "id": user.uid, "profileImageUrl": user.photoURL ?? ""] as [String : Any]
                    db.collection("users").document(user.uid).setData(data) { (errorCloudStore) in
                        if let err = errorCloudStore {
                            completion(false, err.localizedDescription, nil)
                        } else {
                            FirebaseHelper.signOutUser()
                            completion(true, message, user)
                        }
                    }
                    
                    /*
                    db.collection("Account").document(username).setData(data) { (errorCloudStore) in
                        if let err = errorCloudStore {
                            completion(false, err.localizedDescription, nil)
                        } else {
                            FirebaseHelper.signOutUser()
                            completion(true, message, user)
                        }
                    }
                    */
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
                completion(.success(user.uid))
            }
        }
    }
    
    static func addUserDetails(userName: String, data: [String: Any], completionHandler: @escaping ((String?) -> Void)) {
        db.collection("Account").document(userName).setData(data, merge: true) { (err) in
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
