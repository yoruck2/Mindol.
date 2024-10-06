//
//  SceneWrapper.swift
//  Mindol
//
//  Created by dopamint on 10/3/24.
//

import SwiftUI
import RealmSwift
import Combine
import FSCalendar
class SceneWrapper: ObservableObject {
    @Published var currentMonth: Date
       @Published var selectedDiaryId: ObjectId?
       private var scene: RockStackScene?
       let diaryRepository: DiaryRepository
    var calendarReference: FSCalendar?
       init(diaryRepository: DiaryRepository) {
           self.diaryRepository = diaryRepository
           self.currentMonth = Date()
           updateScene(for: currentMonth)
       }
    func refreshCalendar() {
            calendarReference?.reloadData()
            objectWillChange.send()
        }
    func refreshViews() {
            updateScene(for: currentMonth)
            calendarReference?.reloadData()
            objectWillChange.send()
        }
        
        func setCalendarReference(_ calendar: FSCalendar?) {
            self.calendarReference = calendar
        }
       func updateScene(for date: Date) {
           currentMonth = date
           let diaries = diaryRepository.getDiariesForCurrentMonth(date: date)
           scene?.setupRocksFromDiaries(diaries, for: date)
           objectWillChange.send()
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
           updateScene(for: currentMonth)
           return newScene
       }
    
    func addSingleRock(_ diary: DiaryTable) {
            if Calendar.current.isDate(diary.date, equalTo: currentMonth, toGranularity: .month) {
                scene?.addNewRock(diary)
                objectWillChange.send()
            }
        }
    
    func updateScene() {
        let diaries = diaryRepository.getDiariesForCurrentMonth(date: currentMonth)
        scene?.setupRocksFromDiaries(diaries, for: currentMonth)
    }
}
