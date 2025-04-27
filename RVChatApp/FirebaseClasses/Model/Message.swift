//
//  Message.swift
//  RVChatApp
//
//  Created by RV on 24/04/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var text: String
    var senderId: String
    var timestamp: Date
}
