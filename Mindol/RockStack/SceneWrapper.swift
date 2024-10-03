//
//  SceneWrapper.swift
//  Mindol
//
//  Created by dopamint on 10/3/24.
//

import SwiftUI
import RealmSwift

class SceneWrapper: ObservableObject {
    @Published var currentMonth: Date
    @Published var selectedDiaryId: ObjectId?
    private var scene: RockStackScene?
    let diaryRepository: DiaryRepository
    
    init(diaryRepository: DiaryRepository) {
        self.diaryRepository = diaryRepository
        self.currentMonth = Date()
        updateScene()
    }
    
    func moveMonth(by offset: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: offset, to: currentMonth) {
            currentMonth = newDate
            updateScene()
        }
    }
    
    func getScene() -> RockStackScene {
        if let scene = scene {
            return scene
        }
        let newScene = RockStackScene()
        newScene.size = CGSize(width: 350, height: 450)
        newScene.scaleMode = .aspectFill
        newScene.onRockTapped = { [weak self] diaryId in
            self?.selectedDiaryId = diaryId
        }
        self.scene = newScene
        updateScene()
        return newScene
    }
    
    func addSingleRock(_ diary: DiaryTable) {
        if Calendar.current.isDate(diary.date, equalTo: currentMonth, toGranularity: .month) {
            scene?.addNewRock(diary)
            objectWillChange.send()
        }
    }
    
    private func updateScene() {
        let diaries = diaryRepository.getDiariesForCurrentMonth(date: currentMonth)
        scene?.setupRocksFromDiaries(diaries, for: currentMonth)
    }
    
//    func addSingleRock(_ diary: DiaryTable) {
//            if Calendar.current.isDate(diary.date, equalTo: currentMonth, toGranularity: .month) {
//                scene?.addRock(for: diary)
//                objectWillChange.send()  // SwiftUI에게 뷰를 업데이트하도록 알림
//            }
//        }
}
