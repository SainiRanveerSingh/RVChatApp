//
//  ContentView.swift
//  RVChatApp
//
//  Created by RV on 23/04/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @State private var navigateToLogin = false
    var body: some View {
        NavigationStack {
            VStack {
                Text("RV Chat App")
                    .font(.largeTitle)
                    .padding()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    navigateToLogin = true
                }
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
            }
        }
        
    }
    /*
     func callAfterDelay() {
     DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
     performAction()
     }
     }
     
     func performAction() {
     print("This runs after 5 seconds!")
     // Place your delayed logic here
     LoginView()
     }
     */
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
