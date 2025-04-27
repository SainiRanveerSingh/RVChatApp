//
//  ActivityIndicatorView.swift
//  RVChatApp
//
//  Created by RV on 27/04/25.
//

import SwiftUI


struct ActivityIndicatorView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        return spinner
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        
    }
}

#Preview {
    ActivityIndicatorView()
}
