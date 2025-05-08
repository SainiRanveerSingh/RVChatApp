//
//  HomeScreenViewModel.swift
//  RVChatApp
//
//  Created by RV on 27/04/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

final class HomeScreenViewModel: ObservableObject {
    @Published var users: [AllAppUsers] = []
    @Published var chatMessages: [InChatMessage] = []
    
    let tabTypes = ["Recent Chat", "All User"]
    @Published var isLoading: Bool = false
    
    @Published var selectedTabType: String = "All User"
    
    private var db = Firestore.firestore()
    
    func fetchUsers() {
        print("Fetching users...")
        self.isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.selectedTabType == "All User" {
                self.users = FirebaseHelper.allAppUsers
            }
            self.isLoading = false
        }
    }
    
    func loadRecentChat() {
       
        self.isLoading = true
        db.collection("users").document(SessionManager.currentUserId).getDocument { documentSnap, error in
            if error == nil {
                if let doc = documentSnap?.data() {
                    if doc.count > 0 {
                        print(doc)
                        self.refactorRecentChat(data: doc)
                    }
                }
            }
        }
    }
    
    func refactorRecentChat(data:[String : Any]) {
        if let recentData = data["Recent Chat"] as? [String : Any] {
            if recentData.count > 0 {
                
                let arrayAllChat = recentData.values
                print(arrayAllChat)
                var allRecentMessage = [InChatMessage]()
                var recentChatUser = [AllAppUsers]()
                for dictData in arrayAllChat {
                    if let messageDict = dictData as? [String : Any] {
                        let msg = Message.init(id:  messageDict["id"] as? String ?? "",
                                               text: messageDict["text"] as? String ?? "",
                                               senderId: messageDict["senderId"] as? String ?? "",
                                               timestamp: messageDict["date"] as? Date ?? Date(),
                                               userName: messageDict["userName"] as? String ?? "",
                                               receiverId: messageDict["receiverId"] as? String ?? "",
                                               messageType: MessageType(rawValue: messageDict["messsageType"] as? String ?? "") ?? .text)
                        
                        let messageData = InChatMessage.init(id: messageDict["id"] as? String ?? "",
                                                             text: messageDict["text"] as? String ?? "",
                                                             senderId: messageDict["senderId"] as? String ?? "",
                                                             timestamp: messageDict["date"] as? Date ?? Date(),
                                                             receiverId: messageDict["receiverId"] as? String ?? "",
                                                             messageType: MessageType(rawValue: messageDict["messsageType"] as? String ?? "") ?? .text)
                        allRecentMessage.append(messageData)
                        
                        //Adding User details
                        let userDetail = AllAppUsers.init(userId: messageDict["receiverId"] as? String ?? "",
                                                          strUserName:messageDict["userName"] as? String ?? "")
                        recentChatUser.append(userDetail)
                    }
                    
                }
                print(allRecentMessage)
                if self.selectedTabType == "Recent Chat" {
                    self.users = recentChatUser
                }
            }
        }
        self.isLoading = false
    }
    
    /*
     if let recentChats = doc?.values as [InChatMessage] {
         print("Got the data... \(recentChats)")
     } else {
         print("Need to handle in different way")
     }
    */
}

