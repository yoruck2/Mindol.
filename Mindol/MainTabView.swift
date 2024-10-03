//
//  MainTabView.swift
//  Mindol
//
//  Created by dopamint on 10/3/24.
//

import SwiftUI

struct MindolTabView: View {
    var body: some View {
        TabView {
            RockStackView()
                .tabItem {
                    Image(systemName: "1.square.fill")
                    Text("First")
                }
            DirayListView()
                .tabItem {
                    Image(systemName: "2.square.fill")
                    Text("Second")
                }
        }
        .font(.headline)
    }
}

#Preview {
    MindolTabView()
}
