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
    //@DocumentID
    var id: String
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

//------

struct InChatMessage: Identifiable, Codable {
    var id: String
    var text: String
    var senderId: String
    var timestamp: Date
    var receiverId: String
    var messageType: MessageType

    // MARK: - Custom init for manual initialization (optional)
    init(
        id: String,
        text: String,
        senderId: String,
        timestamp: Date,
        receiverId: String,
        messageType: MessageType
    ) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.timestamp = timestamp
        self.receiverId = receiverId
        self.messageType = messageType
    }

    // MARK: - Optional: Custom Decoder (if needed for mapping or transformations)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.senderId = try container.decode(String.self, forKey: .senderId)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.receiverId = try container.decode(String.self, forKey: .receiverId)
        self.messageType = try container.decode(MessageType.self, forKey: .messageType)
    }
}


