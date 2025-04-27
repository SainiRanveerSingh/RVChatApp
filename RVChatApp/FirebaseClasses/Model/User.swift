//
//  User.swift
//  RVChatApp
//
//  Created by RV on 24/04/25.
//

import Foundation

public struct FBUser: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let avatarURL: URL?
    public let isCurrentUser: Bool

    public init(id: String, name: String, avatarURL: URL?, isCurrentUser: Bool) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.isCurrentUser = isCurrentUser
    }
}

