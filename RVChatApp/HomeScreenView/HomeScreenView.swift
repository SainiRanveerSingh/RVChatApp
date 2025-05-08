//
//  HomeScreenView.swift
//  RVChatApp
//
//  Created by RV on 27/04/25.
//

import SwiftUI

struct HomeScreenView: View {
    @StateObject private var viewModel = HomeScreenViewModel()
    @Environment(\.presentationMode) var presentation
    //@State var selectedTabType: String = "All User"
    
    //--
    @State var selectedUser: AllAppUsers = AllAppUsers(userId: "", strUserName: "")
    @State var navigateToChat = false
    //--
    init() {
        let largeTitleFont: UIFont = .systemFont(ofSize: 30, weight: .bold)
        let inlineTitleFont: UIFont = .systemFont(ofSize: 18, weight: .medium)
        
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [.font: largeTitleFont, .foregroundColor: UIColor.red] // Large title
        appearance.titleTextAttributes = [.font: inlineTitleFont, .foregroundColor: UIColor.red] // Inline title
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        //--
        ZStack {
            backgroundTopLine()
                        
            VStack {
                //--
                Spacer()
                //--
                tabPicker()
                //--
                /*
                List(viewModel.users) { userValue in
                    NavigationLink(destination: ChatView(receiverId: userValue.id, userName: userValue.strUserName)) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(userValue.strUserName)
                        }
                    }
                }
                .listStyle(SidebarListStyle())
                */
                
                List(viewModel.users, id: \.id) { userValue in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            if userValue.id == SessionManager.currentUserId {
                                Text(String(format: "%@ (You)", userValue.strUserName))
                            } else {
                                Text(userValue.strUserName)
                            }
                            Spacer()
                            Button(action: {
                                selectedUser = userValue
                                navigateToChat = true
                            }) {
                                Text("Chat")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(10)
                        
                        
                        /*
                        NavigationLink(destination: ChatView(userId: userValue.id, userName: userValue.strUserName)) {
                            Text("Chat")
                        }
                        */
                    }
                }
                .listStyle(SidebarListStyle())
                .background(
                    NavigationLink(
                        destination: ChatView(receiverId: $selectedUser.id, userName: $selectedUser.strUserName)
                            .navigationTitle(selectedUser.strUserName),
                        isActive: $navigateToChat,
                        label: { EmptyView() }
                    )
                    //.navigationTitle("Back")
                    .hidden()
                )
                
                
                //--
            }//VStack ended
            .navigationTitle(SessionManager.currentUser?.name ?? "")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(trailing: Button("Logout") {
                // handle logout logic
                FirebaseHelper.signOutUser()
                self.presentation.wrappedValue.dismiss()
            })
            .onAppear {
                viewModel.selectedTabType = "Recent Chat"
                viewModel.loadRecentChat()
                viewModel.fetchUsers()
            }
            
            // Show Progress HUD
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                    VStack {
                        ActivityIndicatorView()
                        Text("Loading...")
                            .padding(.top, 8)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                }
            }
            
        }//Outer Zstack ended
        
    }// View Body Ended
       
    @ViewBuilder
        private func backgroundTopLine() -> some View {
            ZStack(alignment: .top) {
                VStack {
                    Rectangle()
                        .fill(Color.red)
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                        .offset(y: 0)
                    Spacer()
                }
            }
            .padding(.bottom, 10)
        } //line code ended
    
    @ViewBuilder
       private func tabPicker() -> some View {
           HStack(spacing: 10) {
               ForEach(viewModel.tabTypes, id: \.self) { tabType in
                   tabButton(for: tabType)
               }
           }
           .padding(5)
           .background(Color.white)
           .onChange(of: viewModel.selectedTabType) { newValue in
               print("Selected tab: \(newValue)")
               DispatchQueue.main.async {
                   // Optional: Call API here
                   if viewModel.selectedTabType == "All User" {
                       viewModel.fetchUsers()
                   } else {
                       viewModel.loadRecentChat()
                   }
               }
           }
       } //tab picker code ended
    
    @ViewBuilder
        private func tabButton(for tabType: String) -> some View {
            if viewModel.selectedTabType == tabType {
                PickerSegmentView(text: tabType, isSelected: true)
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity)
            } else {
                PickerSegmentView(text: tabType, isSelected: false)
                    .clipShape(Capsule())
                    .onTapGesture {
                        withAnimation {
                            viewModel.selectedTabType = tabType
                        }
                    }
                    .frame(maxWidth: .infinity)
            }
        } // tab button ended
    
} //Home View Ended

#Preview {
    HomeScreenView()
}
