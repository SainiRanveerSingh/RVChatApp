//
//  HomeScreenViewModel.swift
//  RVChatApp
//
//  Created by RV on 27/04/25.
//

import Foundation
import SwiftUI
final class HomeScreenViewModel: ObservableObject {
    @Published var users: [AllAppUsers] = []
    
    let tabTypes = ["Recent Chat", "All User"]
    @Published var isLoading: Bool = false
    
    func fetchUsers() {
        print("Fetching users...")
        self.isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.users = FirebaseHelper.allAppUsers
            self.isLoading = false
        }
    }
}

