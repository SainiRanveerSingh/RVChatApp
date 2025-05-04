//
//  ChatView.swift
//  RVChatApp
//
//  Created by RV on 25/04/25.
//

import SwiftUI

struct ChatView: View {
    @Environment(\.presentationMode) var presentation
    @StateObject var chatViewModel = ChatViewModel()
    @State private var messageText = ""
    @Binding var receiverId: String
    @Binding var userName: String
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(chatViewModel.messages) { message in
                        HStack {
                            if message.senderId == receiverId {
                                Spacer()
                                Text(message.text)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .padding(.trailing, 10)
                            } else {
                                Text(message.text)
                                    .padding()
                                    .background(Color.gray)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .padding(.leading, 10)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding()
            
            HStack {
                TextField("Type a message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    chatViewModel.sendMessage(text: messageText, receiverId: receiverId, userName: userName)
                    messageText = ""
                }
            }
            .padding()
        }
        .onAppear() {
            chatViewModel.receiverId = self.receiverId
            if receiverId != "" {
                chatViewModel.fetchMessagesForConversation()
            }
        }
        //.navigationBarBackButtonHidden(true)
        /*
        .navigationBarItems(trailing: Button("Logout") {
            // handle logout logic
            FirebaseHelper.signOutUser()
            self.presentation.wrappedValue.dismiss()
        })
        */
    }
}

#Preview {
    //ChatView(receiverId: "01", userName: "User")
}
