//
//  MindolApp.swift
//  Mindol
//
//  Created by dopamint on 9/29/24.
//

import SwiftUI

@main
struct MindolApp: App {
    @StateObject private var diaryRepository = DiaryRepository()
    @StateObject private var sceneWrapper: SceneWrapper
    
    init() {
        let repo = DiaryRepository()
        _sceneWrapper = StateObject(wrappedValue: SceneWrapper(diaryRepository: repo))
    }
    
    var body: some Scene {
        WindowGroup {
            MindolTabView()
                .environmentObject(sceneWrapper)
                .environmentObject(diaryRepository)
                .customFont(type: .Geurimilgi, size: 20)
        }
    }
}

