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
    
    func sendMessage(text: String, senderId: String) {
        let newMessage = Message(text: text, senderId: senderId, timestamp: Date())
        
        do {
            _ = try db.collection("messages").addDocument(from: newMessage)
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
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
}
