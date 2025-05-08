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
    @Published var chatMessages: [InChatMessage] = []
    //InChatMessage
    private var db = Firestore.firestore()
    
    var receiverId: String = ""
    var userName: String = ""
    var currentChatID = ""
    
    init() {
        fetchMessages()
        fetchMessagesForConversation()
    }
    
    func sendMessage(text: String, receiverId: String, userName: String) {
        var ConversatonId = ""
        if currentChatID != "" {
            ConversatonId = currentChatID
        } else {
            ConversatonId = String(format: "%@:%@", SessionManager.currentUserId, receiverId)
        }
        let newMessage = Message(id: ConversatonId,text: text, senderId: SessionManager.currentUserId, timestamp: Date(), userName: userName, receiverId: receiverId, messageType: .text)
        
        let listChatMessage = InChatMessage.init(id: ConversatonId, text: text, senderId: SessionManager.currentUserId, timestamp: Date(), receiverId: receiverId, messageType: .text)
        chatMessages.append(listChatMessage)
        
        self.addMessageToConversation(chatId: ConversatonId, receiverId: receiverId, newMessage: newMessage)
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
    
    func addMessageToConversation(chatId: String, receiverId: String, newMessage: Message) {
        FirebaseHelper.checkUserChatExists(chatId: chatId, senderId: SessionManager.currentUserId, receiverId: receiverId) { status, chatId in
            let ConversatonId = String(format: "%@:%@", SessionManager.currentUserId, receiverId)
            if status {
                //Conversation Exists! Use the same Converation ID
                //print("addMessageToConversation: \nStatus:\(status)\nChatId Found:\(chatId)")
                if chatId == "" {
                    print("addMessageToConversation: else condition \nStatus:\(status)\nChatId Found:\(chatId)")
                    self.updateChatOnFirebase(chatId: ConversatonId, messageData: newMessage)
                } else {
                    print("addMessageToConversation: if condition \nStatus:\(status)\nChatId Found:\(chatId)")
                    self.updateChatOnFirebase(chatId: chatId, messageData: newMessage)
                }
            } else {
                //Create new Conversation to Start the Chat
                print("addMessageToConversation: \nCreating new Conversation to Start the Chat\nStatus:\(status)\nChatId Found:\(chatId)")
                self.updateChatOnFirebase(chatId: ConversatonId, messageData: newMessage)
                
            }
        }
        
    }
    
    
    func updateChatOnFirebase(chatId: String, messageData: Message) {
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
        messageWithTimestamptID.updateValue(messageDataToSendSA, forKey: "\(currentTimestamp)")
        
        
        refChatDB.updateData(messageWithTimestamptID) { responseStatus in
            if responseStatus == nil {
                print("Data Added Successfully !!!")
                //self.updateConversationChat(chatId: chatId, messageData: messageData)
                self.updateChatDetailsInUserProfiles(chatId: chatId, messageData: messageData)
            } else {
                print(responseStatus.debugDescription.contains("Code=5"))
                if (responseStatus.debugDescription.contains("Code=5")) {
                    self.updateConversationChat(chatId: chatId, messageData: messageData)
                }
            }
        }
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
        
    }
    
    func loadConversationData(chatId: String) {
        db.collection("conversations").document(chatId).getDocument(completion: { allConversation, error in
            if error == nil {
                if let conversations = allConversation?.data(){
                    if conversations.count > 0 {
                        let sortedDict = conversations.sorted(by: { $0.key > $1.key })
                        if let data = conversations as? [String:[String:Message]] {
                            print(data)
                        } else if let data = conversations as? [String:[String:Any]] {
                            print(data)
                        }
                        //--
                        var allChatMessages = [Message]()
                        var allInChatMessage = [InChatMessage]()
                        for dict in sortedDict {
                            print(dict.value)
                            if let docValue = (dict.value) as? Message {
                                /*
                                if let docValueMessageId = docValue.id {
                                    print(docValueMessageId)
                                }
                                */
                            }
                            
                            
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
                                let documentIDWrapper = DocumentID<String>(wrappedValue: chatDict["id"])
                                var chatId = ""
                                /*
                                if let documentID = documentIDWrapper.wrappedValue {
                                    print("Document ID: \(documentID)")
                                    chatId = String(format: "%@", documentID)
                                }
                                */
                                if let dataDict = dict.value as? [String: String] {
                                    print(dataDict)
                                    print(dataDict["id"] ?? "")
                                    if let userChatId = dataDict["id"] {
                                        chatId = userChatId
                                        self.currentChatID = userChatId
                                    }
                                }
                                //--
                                let chatMessage = Message(id: chatId,
                                                          text: chatDict["text"] ?? "",
                                                          senderId: chatDict["senderId"] ?? "",
                                                          timestamp: chatDate,
                                                          userName: chatDict["userName"] ?? "",
                                                          receiverId: chatDict["receiverId"] ?? "",
                                                          messageType: MessageType(rawValue: chatDict["messageType"]!) ?? .text)
                                
                                allChatMessages.append(chatMessage)
                                
                                
                                
                                let inChatMsg = InChatMessage(id: chatId,
                                                              text: chatDict["text"] ?? "",
                                                              senderId: chatDict["senderId"] ?? "",
                                                              timestamp: chatDate,
                                                              receiverId: chatDict["receiverId"] ?? "",
                                                              messageType: MessageType(rawValue: chatDict["messageType"]!) ?? .text)
                                
                                allInChatMessage.append(inChatMsg)
                            }
                        }
                        
                        self.messages = allChatMessages
                        self.chatMessages = allInChatMessage
                        
                    }
                    print(conversations)
                }
            } else {
                print("Error in loading mesasges: \(error?.localizedDescription)")
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
