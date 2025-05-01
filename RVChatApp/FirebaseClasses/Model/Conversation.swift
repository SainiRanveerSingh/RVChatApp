//
//  Conversation.swift
//  RVChatApp
//
//  Created by RV on 24/04/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

//import FirebaseFirestoreSwift

public struct Conversation: Identifiable, Hashable {
    public let id: String
    public let users: [User]
    public let usersUnreadCountInfo: [String: Int]
    public let isGroup: Bool
    public let pictureURL: URL?
    public let title: String

    public let latestMessage: LatestMessageInChat?

    init(id: String, users: [User], usersUnreadCountInfo: [String: Int]? = nil, isGroup: Bool, pictureURL: URL? = nil, title: String = "", latestMessage: LatestMessageInChat? = nil) {
        self.id = id
        self.users = users
        self.usersUnreadCountInfo = usersUnreadCountInfo ?? Dictionary(uniqueKeysWithValues: users.map { ($0.uid, 0) } )
        self.isGroup = isGroup
        self.pictureURL = pictureURL
        self.title = title
        self.latestMessage = latestMessage
    }

    var notMeUsers: [User] {
        users.filter { $0.uid != SessionManager.currentUserId }
    }

    var displayTitle: String {
        if !isGroup, let user = notMeUsers.first {
            return user.displayName ?? "Name"
        }
        return title
    }
}

public struct LatestMessageInChat: Hashable {
    public var senderName: String
    public var createdAt: Date?
    public var text: String?
    public var subtext: String?

    var isMyMessage: Bool {
        SessionManager.currentUser?.name == senderName
    }
}



/*
public struct FirestoreConversation: Codable, Identifiable, Hashable {
    @DocumentID public var id: String?
    public let users: [String]
    public let usersUnreadCountInfo: [String: Int]?
    public let isGroup: Bool
    public let pictureURL: String?
    public let title: String
    public let latestMessage: FirestoreMessage?
}
*/
