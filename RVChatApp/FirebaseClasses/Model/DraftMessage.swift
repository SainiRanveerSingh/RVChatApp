//
//  DraftMessage.swift
//  RVChatApp
//
//  Created by RV on 25/04/25.
//

import Foundation
import ExyteMediaPicker

public struct DraftMessage {
    public var id: String?
    public let text: String
    public let medias: [Media]
    //public let recording: Recording?
    //public let replyMessage: ReplyMessage?
    public let createdAt: Date
}
