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
    @State var selectedTabType: String = "All User"
    
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
            VStack {
                //--
                Spacer()
                HStack(spacing: 10) {
                    ForEach(viewModel.tabTypes, id: \.self) { tabType in
                        if(selectedTabType == tabType) {
                            PickerSegmentView(text: tabType, isSelected: true)
                                .clipShape(Capsule())
                                .frame(maxWidth: .infinity)
                        } else {
                            PickerSegmentView(text: tabType, isSelected: false)
                                .clipShape(Capsule())
                                .onTapGesture {
                                    withAnimation {
                                        selectedTabType = tabType
                                    }
                                }
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(5)
                //.background(Capsule())
                .background(Color.white)
                //--
                .onChange(of: selectedTabType) { newValue in
                    print("Selected tab: \(newValue)")
                    DispatchQueue.main.async {
                        //self.callAPI(strType: newValue)
                    }
                }
                
                //--
                
                List(FirebaseHelper.allAppUsers, id: \.id) { userValue in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(userValue.strUserName)
                        NavigationLink(destination: ChatView(userId: userValue.id) ) {
                                
                            }
                    }
                    //VStack ended
                }
                .listStyle(SidebarListStyle())
                
                //--
            }//VStack ended
            .navigationTitle(SessionManager.currentUser?.name ?? "")            
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(trailing: Button("Logout") {
                // handle logout logic
                FirebaseHelper.signOutUser()
                self.presentation.wrappedValue.dismiss()
            })
        }
        
    }
    
        
}

#Preview {
    HomeScreenView()
}
