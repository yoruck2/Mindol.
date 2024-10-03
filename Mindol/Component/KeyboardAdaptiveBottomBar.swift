//
//  KeyboardAdaptiveBottomBar.swift
//  Mindol
//
//  Created by dopamint on 10/3/24.
//

import SwiftUI
import Combine

struct KeyboardAdaptiveBottomBar: View {
    @State private var keyboardHeight: CGFloat = 0
    
    var content: () -> AnyView
    
    init(@ViewBuilder content: @escaping () -> AnyView) {
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            content()
                .frame(height: 40) // Toolbar의 일반적인 높이
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemBackground))
                .position(x: geometry.size.width / 2, y: geometry.size.height - keyboardHeight)
        }
        .ignoresSafeArea(.keyboard)
        .onReceive(keyboardPublisher) { newHeight in
            withAnimation(.easeInOut(duration: 0.25)) {
                self.keyboardHeight = newHeight
            }
        }
    }
    
    private var keyboardPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { notification in
                    notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                }
                .map { $0.height },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
        )
        .eraseToAnyPublisher()
    }
}
