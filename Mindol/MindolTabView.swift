//
//  MindolTabView.swift
//  Mindol
//
//  Created by dopamint on 10/3/24.
//

import SwiftUI

struct MindolTabView: View {
    @State private var currentTab = 0
    @State private var offset: CGFloat = 0
    @State private var isDragging = false
    private let animationDuration: Double = 0.4
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                HStack(spacing: 0) {
                    RockStackView(currentTab: $currentTab)
                        .frame(width: geometry.size.width)
                    
                    DiaryListView()
                        .frame(width: geometry.size.width)
                }
                .offset(x: -CGFloat(currentTab) * geometry.size.width)
                .offset(x: limitedOffset(for: offset, in: geometry))
                .animation(.spring(duration: animationDuration), value: currentTab)
                .animation(.spring(duration: animationDuration), value: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDragging = true
                            offset = value.translation.width
                        }
                        .onEnded { value in
                            isDragging = false
                            let threshold = geometry.size.width * 0.3
                            if value.translation.width > threshold && currentTab > 0 {
                                withAnimation(.spring(duration: animationDuration)) {
                                    currentTab -= 1
                                }
                            } else if value.translation.width < -threshold && currentTab < 1 {
                                withAnimation(.spring(duration: animationDuration)) {
                                    currentTab += 1
                                }
                            }
                            offset = 0
                        }
                )
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func limitedOffset(for offset: CGFloat, in geometry: GeometryProxy) -> CGFloat {
        let _ = geometry.size.width
        if currentTab == 0 {
            return min(offset, 0)
        } else if currentTab == 1 {
            return max(offset, 0)
        }
        return offset
    }
}

