//
//  Message.swift
//  RVChatApp
//
//  Created by RV on 24/04/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct Message: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var text: String
    var senderId: String
    var timestamp: Date
    var userName: String
    var receiverId: String
    var messageType: MessageType
}

struct AllChat : Identifiable, Codable, Hashable {
    var senderId: String
    var receiverId: String
    // Computed property
    var id: String {
        return String(format: "%@:%@", senderId, receiverId)
    }
}

enum MessageType: String, Codable, Hashable {
    case text = "text"
    case image = "image"
    case video = "video"
}
