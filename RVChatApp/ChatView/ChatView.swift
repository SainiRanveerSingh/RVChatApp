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
            //----
            ScrollViewReader { proxy in
                List(chatViewModel.chatMessages, id: \.timestamp) { message in
                    HStack {
                        
                        if message.senderId == SessionManager.currentUserId {
                            Spacer()
                            Text(message.text)
                            //Text(" Message: \(message.text)\n SenderId: \(message.senderId)\n receiverId: \(receiverId)")
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .padding(.trailing, -20)
                        } else {
                            Text(message.text)
                            //Text(" Message: \(message.text)\n SenderId: \(message.senderId)\n receiverId: \(receiverId)")
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .padding(.leading, -20)
                            Spacer()
                        }
                        
                    }
                    .background(Color.clear)
                }
                .padding()
                .refreshable {
                    chatViewModel.receiverId = self.receiverId
                    if receiverId != "" {
                        chatViewModel.fetchMessagesForConversation()
                    }
                }
                .onChange(of: chatViewModel.chatMessages.count) {
                    if let lastId = chatViewModel.chatMessages.last?.timestamp {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listStyle(PlainListStyle())
                .scrollIndicators(.hidden)
                //----
                
                //--
                /*
                 ScrollView {
                 VStack(alignment: .leading) {
                 ForEach(chatViewModel.chatMessages, id: \.timestamp) { message in
                 HStack {
                 /*
                  Spacer()
                  Text(" Message: \(message.text)\n SenderId: \(message.senderId)\n receiverId: \(receiverId)")
                  .padding()
                  .background(Color.blue)
                  .cornerRadius(10)
                  .foregroundColor(.white)
                  .padding(.trailing, 10)
                  Spacer()
                  */
                 
                 if message.senderId == SessionManager.currentUserId {
                 Spacer()
                 Text(" Message: \(message.text)\n SenderId: \(message.senderId)\n receiverId: \(receiverId)")
                 .padding()
                 .background(Color.blue)
                 .cornerRadius(10)
                 .foregroundColor(.white)
                 .padding(.trailing, 10)
                 } else {
                 Text(" Message: \(message.text)\n SenderId: \(message.senderId)\n receiverId: \(receiverId)")
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
                 */
                //--
                HStack {
                    TextField("Type a message...", text: $messageText)
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
            .background(Color.clear)
            
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
    
    private func formattedDate(_ date: Date) -> String {
           let formatter = DateFormatter()
           formatter.dateStyle = .medium
           formatter.timeStyle = .short
           return formatter.string(from: date)
       }
}

#Preview {
    //ChatView(receiverId: "01", userName: "User")
}
