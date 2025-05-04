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
    
    var receiverId: String = ""
    var userName: String = ""
    
    init() {
        fetchMessages()
        fetchMessagesForConversation()
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
        var refChatDB = self.db.collection("conversations").document(chatId)//document(chatId).chi//getDocument()//.addDocument(from: newMessage)
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
        let refChatDB = self.db.collection("conversations").document(chatId)
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
                self.updateChatDetailsInUserProfiles(chatId: chatId, messageData: messageData)
                print("Data Added Successfully !!!")
            } else {
                print(responseStatus.debugDescription.contains("Code=5"))
            }
        }
    }
    
    func updateChatDetailsInUserProfiles(chatId: String, messageData: Message) {
        let senderReceiverID = chatId.split(separator: ":")
        let refChatDBSender = self.db.collection("users").document(SessionManager.currentUserId)
        let refChatDBReceiver = self.db.collection("users").document(String(senderReceiverID[1]))
        
        let messageDataForSender = getProfileLastChatMessageDict(userName: messageData.userName, messageData: messageData)
        
        var userChatData : [String : Any] = [String : Any]()
        var messageWithTimestamptID : [String : Any] = [String : Any]()
        messageWithTimestamptID.updateValue(messageDataForSender, forKey: chatId)
        userChatData.updateValue(messageWithTimestamptID, forKey: "Recent Chat")
        refChatDBSender.setData(userChatData, merge: true) { responseStatus in
            if responseStatus == nil {
                print("Data Added Successfully For Sender!!!")
            } else {
                print(responseStatus.debugDescription.contains("Code=5"))
            }
        }
        
        let messageDataForReceiver = getProfileLastChatMessageDict(userName: SessionManager.currentUser?.name ?? "", messageData: messageData)
        
        var userChatDataForReceiver : [String : Any] = [String : Any]()
        var messageWithTimestamptIDForReceiver : [String : Any] = [String : Any]()
        messageWithTimestamptIDForReceiver.updateValue(messageDataForReceiver, forKey: chatId)
        userChatDataForReceiver.updateValue(messageWithTimestamptIDForReceiver, forKey: "Recent Chat")

        refChatDBReceiver.setData(userChatDataForReceiver, merge: true) { responseStatus in
            if responseStatus == nil {
                print("Data Added Successfully For Receiver!!!")
            } else {
                print(responseStatus.debugDescription.contains("Code=5"))
            }
        }
        
    }
    
    func getProfileLastChatMessageDict(userName: String, messageData: Message) -> [String : Any] {
        var messageDataForUserProfile : [String : Any] = [String : Any]()
        messageDataForUserProfile.updateValue(messageData.id ?? "", forKey: "id")
        messageDataForUserProfile.updateValue(messageData.text, forKey: "text")
        messageDataForUserProfile.updateValue(messageData.senderId, forKey: "senderId")
        messageDataForUserProfile.updateValue("\(messageData.timestamp)", forKey: "timestamp")
        messageDataForUserProfile.updateValue(userName, forKey: "userName")
        messageDataForUserProfile.updateValue(messageData.receiverId, forKey: "receiverId")
        messageDataForUserProfile.updateValue(messageData.messageType.rawValue, forKey: "messageType")
        return messageDataForUserProfile
    }
    
    func fetchMessagesForConversation() {
        if receiverId != "" {
        let ConversatonId = String(format: "%@:%@", SessionManager.currentUserId, receiverId)
        FirebaseHelper.checkUserChatExists(chatId: ConversatonId, senderId: SessionManager.currentUserId, receiverId: receiverId) { status, chatId in
            if status {
                self.loadConversationData(chatId: chatId)
            } else {
                if chatId != "" {
                    self.loadConversationData(chatId: chatId)
                }
            }
        }
    }
        

        /*
        .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching messages: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.messages = documents.compactMap { doc in
                    try? doc.data(as: Message.self)
                }
            }
        */
    }
    
    func loadConversationData(chatId: String) {
        db.collection("conversations").document(chatId).getDocument(completion: { allConversation, error in
            if error == nil {
                if let conversations = allConversation?.data(){
                    if conversations.count > 0 {
                        let sortedDict = conversations.sorted(by: { $0.key < $1.key })
                        
                        //--
                        var allChatMessages = [Message]()
                        for dict in sortedDict {
                            print(dict.value)
                            if let chatDict = dict.value as? Dictionary<String, String> {
                                //--
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                                formatter.locale = Locale(identifier: "en_US_POSIX") // Recommended for fixed format
                                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                                var chatDate = Date()
                                if let date = formatter.date(from: chatDict["timestamp"] ?? "\(Date())") {
                                    print("Converted Date: \(date)")
                                    chatDate = date
                                }
                                //--
                                let chatMessage = Message(id: chatDict["id"],
                                                          text: chatDict["text"] ?? "",
                                                          senderId: chatDict["senderId"] ?? "",
                                                          timestamp: chatDate,
                                                          userName: chatDict["userName"] ?? "",
                                                          receiverId: chatDict["receiverId"] ?? "",
                                                          messageType: MessageType(rawValue: chatDict["messageType"]!) ?? .text)
                                
                                allChatMessages.append(chatMessage)
                            }
                            
                            /*
                            if let FBDict = dict.value as? Dictionary<String, String> {
                                print(FBDict)
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: FBDict)
                                //let chatMessage = try JSONDecoder().decode(Message.self, from: jsonData)
                                let dbRef = Firestore.firestore().collection("conversations")
                                let docRef = dbRef.document(chatId)
                                let chatMessage = try Firestore.Decoder().decode(Message.self, from: FBDict, in: docRef)
                                
                                print("Name: \(chatMessage.text), Age: \(chatMessage.userName)")
                                allChatMessages.append(chatMessage)
                            } catch {
                                print("Error decoding JSON: \(error)")
                            }
                        }
                            */
                        }
                        
                        self.messages = allChatMessages
                        //--
                        /*
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: sortedDict)
                            let chatMessages = try JSONDecoder().decode([Message].self, from: jsonData)
                            
                            for chatMessage in chatMessages {
                                print("Name: \(chatMessage.text), Age: \(chatMessage.userName)")
                            }
                            self.messages = chatMessages
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                        */
                        //--
                        
                    }
                    print(conversations)
                }
            } else {
                
            }
        })
    }
    
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
