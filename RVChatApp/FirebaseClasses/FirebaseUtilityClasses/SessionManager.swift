//
//  SessionManager.swift
//  RVChatApp
//
//  Created by RV on 25/04/25.
//

import Foundation
import UIKit
import FirebaseAuth

let hasCurrentSessionKey = "hasCurrentSession"
let currentUserKey = "currentUser"

class SessionManager {

    static let shared = SessionManager()
    
    static var currentUserId: String {
        shared.currentFBUser?.id ?? ""
    }

    static var currentUser: FBUser? {
        shared.currentFBUser
    }

    var deviceId: String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    //@Published private var currentUser: User?
    @Published private var currentFBUser : FBUser?// = FBUser(id: "", name: "", avatarURL: nil, isCurrentUser: false)

    func storeUser(_ user: User) async {
        var userDBName = "User"
        if user.displayName == nil {
            await FirebaseHelper.getUserNameFromDB(userId: user.uid) { status, name in
                if status {
                    print(name)
                    userDBName = name
                    let FBUser = FBUser.init(id: user.uid, name: userDBName, avatarURL: user.photoURL, isCurrentUser: true)
                    self.saveUserDataToUserDefauld(FBUserVal: FBUser)
                } else {
                    let FBUser = FBUser.init(id: user.uid, name: user.displayName ?? "Name", avatarURL: user.photoURL, isCurrentUser: true)
                    self.saveUserDataToUserDefauld(FBUserVal: FBUser)
                }
            }
        } else {
            let FBUser = FBUser.init(id: user.uid, name: user.displayName ?? "Name", avatarURL: user.photoURL, isCurrentUser: true)
            self.saveUserDataToUserDefauld(FBUserVal: FBUser)
        }
    }
    
    func saveUserDataToUserDefauld(FBUserVal: FBUser) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(FBUserVal) {
            UserDefaults.standard.set(encoded, forKey: currentUserKey)
        }
        UserDefaults.standard.set(true, forKey: hasCurrentSessionKey)
        currentFBUser = FBUserVal
    }

    func loadUser() -> (Bool){
        if let data = UserDefaults.standard.data(forKey: "currentUser") {
            currentFBUser = try? JSONDecoder().decode(FBUser.self, from: data)
            Task {
                await FirebaseHelper.getAllUserList { status, message in
                    print(message)
                    //print(FirebaseHelper.appUsers)
                }
            }
            return true
        }
        return false
    }

    func logout() {
        currentFBUser = nil
        UserDefaults.standard.set(false, forKey: hasCurrentSessionKey)
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }
}
