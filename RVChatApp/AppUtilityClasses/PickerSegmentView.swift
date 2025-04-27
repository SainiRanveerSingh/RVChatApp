//
//  PickerSegmentView.swift
//  RVChatApp
//
//  Created by RV on 27/04/25.
//

import SwiftUI

struct PickerSegmentView: View {
    var text: String
    var isSelected: Bool
    
    var body: some View {
        Text(text)
            .foregroundColor(isSelected ? .white : .black)
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .background(isSelected ? Color.red: Color.clear)
            
    }
}

#Preview {
    PickerSegmentView(text: "Recent Chat", isSelected: true)
}
