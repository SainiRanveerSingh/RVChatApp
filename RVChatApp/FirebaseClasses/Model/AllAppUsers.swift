//
//  AllAppUsers.swift
//  RVChatApp
//
//  Created by RV on 28/04/25.
//

import Foundation

struct AllAppUsers: Identifiable, Codable {
    
    var id: String
    var strUserName: String
    
    // Custom decoder to handle add 'isLiked' key
    enum CodingKeys: String, CodingKey {
        case id, strUserName
    }
    
    init(userId: String, strUserName:String) {
        self.id = userId
        self.strUserName = strUserName
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.strUserName = try container.decode(String.self, forKey: .strUserName)
    }

}
