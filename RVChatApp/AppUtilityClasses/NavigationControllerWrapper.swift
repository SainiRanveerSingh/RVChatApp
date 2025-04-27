//
//  NavigationControllerWrapper.swift
//  RVChatApp
//
//  Created by RV on 26/04/25.
//

import SwiftUI

struct CustomNavigationController<Content: View>: UIViewControllerRepresentable {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let hostingController = UIHostingController(rootView: content)
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        navigationController.delegate = context.coordinator
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        if let hostingController = uiViewController.viewControllers.first as? UIHostingController<Content> {
            hostingController.rootView = content
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, UINavigationControllerDelegate {
        func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
            navigationController.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
}
