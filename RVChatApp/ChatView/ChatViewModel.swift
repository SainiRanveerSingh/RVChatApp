//
//  ChatViewModel.swift
//  RVChatApp
//
//  Created by RV on 25/04/25.
//

import Foundation
import FirebaseFirestore
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    private var db = Firestore.firestore()
    
    init() {
        fetchMessages()
    }
    
    func sendMessage(text: String, receiverId: String, userName: String) {
        let ConversatonId = String(format: "%@:%@", SessionManager.currentUserId, receiverId)
        let newMessage = Message(id: ConversatonId,text: text, senderId: SessionManager.currentUserId, timestamp: Date(), userName: userName, receiverId: receiverId, messageType: .text)
        self.addMessageToConversation(receiverId: receiverId, newMessage: newMessage)
        /*
        do {
            _ = try db.collection("messages").addDocument(from: newMessage)
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
        */
    }
    
    func fetchMessages() {
        db.collection("messages").order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching messages: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.messages = documents.compactMap { doc in
                    try? doc.data(as: Message.self)
                }
            }
    }
    
    func addMessageToConversation(receiverId: String, newMessage: Message) {
        FirebaseHelper.checkUserChatExists(chatId: "", senderId: SessionManager.currentUserId, receiverId: receiverId) { status, chatId in
            let ConversatonId = String(format: "%@:%@", SessionManager.currentUserId, receiverId)
            if status {
                //Conversation Exists! Use the same Converation ID
                if chatId == "" {
                    self.updateChatOnFirebase(chatId: chatId, messageData: newMessage)
                } else {
                    self.updateChatOnFirebase(chatId: ConversatonId, messageData: newMessage)
                }
            } else {
                //Create new Conversation to Start the Chat
                //let ConversatonId = String(format: "%@:%@", SessionManager.currentUserId, receiverId)
                //FIRDatabase.database().reference().child("posts").child(imageName)
                self.updateChatOnFirebase(chatId: ConversatonId, messageData: newMessage)
                
            }
        }
        
    }
    
    
    func updateChatOnFirebase(chatId: String, messageData: Message) {
        //do {
        //_ = try db.collection("messages").addDocument(from: newMessage)
        var refChatDB = self.db.collection("converstaions").document(chatId)//document(chatId).chi//getDocument()//.addDocument(from: newMessage)
        let currentTimestamp = getDateInMilliSeconds()
        var messageDataToSend : [AnyHashable : String] = [AnyHashable : String]()
        messageDataToSend.updateValue(messageData.id ?? "", forKey: "id")
        messageDataToSend.updateValue(messageData.text, forKey: "text")
        messageDataToSend.updateValue(messageData.senderId, forKey: "senderId")
        messageDataToSend.updateValue("\(messageData.timestamp)", forKey: "timestamp")
        messageDataToSend.updateValue(messageData.userName, forKey: "userName")
        messageDataToSend.updateValue(messageData.receiverId, forKey: "receiverId")
        messageDataToSend.updateValue(messageData.messageType.rawValue, forKey: "messageType")
        
        var messageDataToSendSA : [String : Any] = [String : Any]()
        messageDataToSendSA.updateValue(messageData.id ?? "", forKey: "id")
        messageDataToSendSA.updateValue(messageData.text, forKey: "text")
        messageDataToSendSA.updateValue(messageData.senderId, forKey: "senderId")
        messageDataToSendSA.updateValue("\(messageData.timestamp)", forKey: "timestamp")
        messageDataToSendSA.updateValue(messageData.userName, forKey: "userName")
        messageDataToSendSA.updateValue(messageData.receiverId, forKey: "receiverId")
        messageDataToSendSA.updateValue(messageData.messageType.rawValue, forKey: "messageType")
        
        var messageWithTimestamptID : [String : Any] = [String : Any]()
        messageWithTimestamptID.updateValue(messageDataToSendSA, forKey: "\(currentTimestamp)")
        
        refChatDB.updateData(messageDataToSend) { responseStatus in
            if responseStatus == nil {
                print("Data Added Successfully !!!")
                self.updateConversationChat(chatId: chatId, messageData: messageData)
            } else {
                print(responseStatus.debugDescription.contains("Code=5"))
                if (responseStatus.debugDescription.contains("Code=5")) {
                    self.updateConversationChat(chatId: chatId, messageData: messageData)
                    /*
                     refChatDB.setData(messageDataToSendSA, merge: true) { responseStatus in
                     if responseStatus == nil {
                     print("Data Added Successfully !!!")
                     } else {
                     print(responseStatus.debugDescription.contains("Code=5"))
                     }
                     }
                     */
                }
            }
        }//addDocument(data: messageData)//updateData(currentTimestamp: messageData)
        /*
         } catch {
         print("Error sending message: \(error.localizedDescription)")
         }
         */
    }
    
    func updateConversationChat(chatId: String, messageData: Message) {
        var refChatDB = self.db.collection("converstaions").document(chatId)
        let currentTimestamp = getDateInMilliSeconds()
        
        var messageDataToSendSA : [String : Any] = [String : Any]()
        messageDataToSendSA.updateValue(messageData.id ?? "", forKey: "id")
        messageDataToSendSA.updateValue(messageData.text, forKey: "text")
        messageDataToSendSA.updateValue(messageData.senderId, forKey: "senderId")
        messageDataToSendSA.updateValue("\(messageData.timestamp)", forKey: "timestamp")
        messageDataToSendSA.updateValue(messageData.userName, forKey: "userName")
        messageDataToSendSA.updateValue(messageData.receiverId, forKey: "receiverId")
        messageDataToSendSA.updateValue(messageData.messageType.rawValue, forKey: "messageType")
        
        var messageWithTimestamptID : [String : Any] = [String : Any]()
        messageWithTimestamptID.updateValue(messageDataToSendSA, forKey: currentTimestamp)
        print(currentTimestamp)
        
        refChatDB.setData(messageWithTimestamptID, merge: true) { responseStatus in
            if responseStatus == nil {
                print("Data Added Successfully !!!")
            } else {
                print(responseStatus.debugDescription.contains("Code=5"))
            }
        }
    }
    
    /*
    func getDateFromUTC(RFC3339: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: RFC3339)
    }
    */
    
    func getDateInMilliSeconds() -> String {
        let date = Date()
        let milliseconds = Int64(date.timeIntervalSince1970 * 1000)
        print(milliseconds)
        return String(format: "%d", milliseconds * -1)
    }
    
    func dateFromMilliseconds(timeStamp: Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(timeStamp)/1000)
    }
}
