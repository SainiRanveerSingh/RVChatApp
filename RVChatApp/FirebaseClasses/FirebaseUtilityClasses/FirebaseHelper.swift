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
    //static var appUsers :[(userId:String,strUserName:String)] = []
    static var allAppUsers = [AllAppUsers]()
    
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
    
    class func getUserNameFromDB(userId: String, completion: @escaping (Bool, String) -> Swift.Void) async {
        do {
            let dbData = try await db.collection("users").document(userId).getDocument()
            print(dbData)
            guard let name = dbData.data()?["username"] as? String else {
                completion(false, "Error")
                return
            }
            completion(true, name)
        }
        catch(let error) {
            print(error.localizedDescription)
            completion(false, "Error")
        }
    }
    
    class func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = authResult?.user {
                currentFBUser = authResult
                Task {
                    await SessionManager.shared.storeUser(currentFBUser.user)
                }
                self.checkLoggedInUserExists(userId: currentFBUser.user.uid) { status in
                    if status {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            completion(.success(user.uid))
                        }
                    } else {
                        self.addLoggedInUserDetails { errorMessage in
                            if errorMessage != nil {
                                print(errorMessage ?? "Some error in adding Logged In user Data")
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                completion(.success(user.uid))
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func checkLoggedInUserExists(userId: String, completionHandler: @escaping ((Bool) -> Void)) {
        db.collection("users").document(userId).getDocument { (document, _) in
            if let document = document, document.exists {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
    
    static func addLoggedInUserDetails(completionHandler: @escaping ((String?) -> Void)) {
        var username = currentFBUser.user.email ?? ""
        if username != "" {
            let stringValue = username.split(separator: "@")
            if stringValue.count > 1 {
                username = String(stringValue[0])
            }
        }
        
        let data = ["username": currentFBUser.user.displayName ?? username, "email": currentFBUser.user.email ?? "", "id": currentFBUser.user.uid, "profileImageUrl": currentFBUser.user.photoURL ?? ""] as [String : Any]
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
    
    class func getAllUserList(completion: @escaping (Bool, String) -> Void) async {
        print(db.collection("users"))
       
        db.collection("users").getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot, error == nil else {return}
            let documentIDs = snapshot.documents.map({$0.documentID})
            print(documentIDs)
            documentIDs.forEach { strUserId in
                Task {
                    await self.getUserNameFromDB(userId: strUserId) { status, nameValue in
                        //self.appUsers.append((userId:strUserId,strUserName:nameValue))
                        let seconds = (Double.random(in: 1.0...9.0)/100)
                        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                            // Put your code which should be executed with a delay here
                            self.allAppUsers.append(AllAppUsers(userId: strUserId, strUserName: nameValue))
                        }
                        
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                completion(true, "Success")
            }
        }
        
    }
    
    class func checkUserChatExists(chatId: String, senderId: String, receiverId: String, completionHandler: @escaping ((_ status:Bool, _ chatId: String) -> Void)) {
        let chatId01 = String(format: "%@:%@", senderId, receiverId)
        let chatId02 = String(format: "%@:%@", receiverId, senderId)
        var chatExists = false
        db.collection("conversations").getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot, error == nil else {return}
            let documentIDs = snapshot.documents.map({$0.documentID})
            print(documentIDs)
            if let documentIds = documentIDs as? [String] {
                if documentIds.contains(where: {$0 == chatId01} ) {
                    chatExists = true
                    completionHandler(chatExists, chatId01)
                } else if documentIds.contains(where: {$0 == chatId02} ) {
                    chatExists = true
                    completionHandler(chatExists, chatId02)
                } else if documentIds.contains(where: {$0 == chatId} ) {
                    chatExists = true
                    completionHandler(chatExists, chatId)
                } else {
                    completionHandler(chatExists, "")
                }
            } else {
                completionHandler(chatExists, "")
            }
        }
        
        
    }
    
    
    
    
}
