//
//  RockStackView.swift
//  Mindol
//
//  Created by dopamint on 10/2/24.
//

import SwiftUI
import SpriteKit

struct RockStackView: View {
    @StateObject private var diaryRepository = DiaryRepository.shared
    @StateObject private var sceneWrapper: SceneWrapper
    @StateObject private var flipCardPresenter = FlipCardPresenter()
    @State private var navigationPath = NavigationPath()
    @State private var selectedDate = Date()
    // let months: [Date] = [] // 사용하지 않으므로 제거하거나 필요 시 수정
    @State private var currentIndex: Int = 1
    
    init() {
        _sceneWrapper = StateObject(wrappedValue: SceneWrapper(diaryRepository: DiaryRepository.shared))
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                monthSelector
                
                FlipCardView(presenter: flipCardPresenter, sceneWrapper: sceneWrapper, selectedDate: $selectedDate)
                    .padding(.vertical, 20)
                
                Spacer(minLength: 60)
                
                Button(action: {
                    checkAndProceedToNewDiary()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .navigationDestination(for: String.self) { route in
                if route == "rockSelection" {
                    RockSelectionView(diaryRepository: diaryRepository, sceneWrapper: sceneWrapper, navigationPath: $navigationPath)
                        .navigationBarHidden(false)
                }
            }
            .navigationDestination(for: Rock.self) { rock in
                DiaryEditView(selectedRock: rock, date: selectedDate, diaryRepository: diaryRepository, sceneWrapper: sceneWrapper, navigationPath: $navigationPath)
                    .navigationBarHidden(false)
            }
        }
        .onAppear {
            preloadScenes()
        }
    }
    
    private var monthSelector: some View {
        HStack {
            Button(action: { sceneWrapper.moveMonth(by: -1) }) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(formattedMonth)
            Spacer()
            Button(action: { sceneWrapper.moveMonth(by: 1) }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
    }
    
    private var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMMM"
        return formatter.string(from: sceneWrapper.currentMonth)
    }
    
    private func moveMonth(by offset: Int) {
        sceneWrapper.moveMonth(by: offset)
    }
    
    private func updateCurrentMonth() {
        currentIndex = sceneWrapper.currentMonthIndex // months 배열과 관련 없이 현재 인덱스로 수정
    }
    
    private func preloadScenes() {
        // 현재 월을 기준으로 이전, 현재, 다음 월을 미리 로드
        _ = sceneWrapper.getScene(for: sceneWrapper.currentMonthIndex)
    }
    
    private func checkAndProceedToNewDiary() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if diaryRepository.hasDiaryForDate(today) {
            flipCardPresenter.flipButtonTapped()
        } else {
            selectedDate = today
            navigationPath.append("rockSelection")
        }
    }
}
class SceneWrapper: ObservableObject {
    @Published var currentMonthIndex: Int = 0
    private var scenes: [Int: RockStackScene] = [:]
    let diaryRepository: DiaryRepository
    
    var currentMonth: Date {
        return monthFor(index: currentMonthIndex)
    }
    
    init(diaryRepository: DiaryRepository) {
        self.diaryRepository = diaryRepository
        _ = getScene(for: currentMonthIndex)
    }
    
    func getScene(for index: Int) -> RockStackScene {
        if let scene = scenes[index] {
            return scene
        } else {
            let newScene = RockStackScene()
            newScene.size = CGSize(width: 350, height: 450)
            newScene.scaleMode = .aspectFill
            updateRocksForMonth(monthFor(index: index), scene: newScene)
            scenes[index] = newScene
            return newScene
        }
    }
    
    func moveMonth(by offset: Int) {
        currentMonthIndex += offset
        _ = getScene(for: currentMonthIndex)
    }
    
    func updateRocksForMonth(_ month: Date, scene: RockStackScene) {
        //
        let diaries = diaryRepository.getDiariesForMonth(month)
        scene.setupRocksFromDiaries(diaries, for: month)
    }
    
    func addSingleRock(_ diary: DiaryTable) {
        if Calendar.current.isDate(diary.date, equalTo: currentMonth, toGranularity: .month) {
            scenes[currentMonthIndex]?.addNewRock(diary)
        }
    }
    
    func monthFor(index: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: index, to: Date()) ?? Date()
    }
}
struct CarouselView<Content: View>: View {
    @Binding var currentIndex: Int
    let itemCount: Int
    let content: (Int) -> Content
    
    @GestureState private var translation: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            content(currentIndex)
                .frame(width: geometry.size.width)
                .frame(width: geometry.size.width, alignment: .leading)
        }
    }
}

class FlipCardPresenter: ObservableObject {
    @Published var isFlipped: Bool = false
    
    func flipButtonTapped() {
        withAnimation {
            isFlipped.toggle()
        }
    }
}
struct FlipCardView: View {
    @ObservedObject var presenter: FlipCardPresenter
    @ObservedObject var sceneWrapper: SceneWrapper
    @Binding var selectedDate: Date
    
    var body: some View {
        CarouselView(currentIndex: $sceneWrapper.currentMonthIndex, itemCount: 3) { index in
            ZStack {
                // 앞면 (RockStackScene)
                SpriteView(scene: sceneWrapper.getScene(for: index))
                    .frame(width: 350, height: 450)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .opacity(presenter.isFlipped ? 0 : 1)
                
                // 뒷면 (Calendar)
                CalendarView(selectedDate: $selectedDate, currentMonth: .constant(sceneWrapper.monthFor(index: index)))
                    .frame(width: 350, height: 450)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .opacity(presenter.isFlipped ? 1 : 0)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
            .rotation3DEffect(.degrees(presenter.isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .animation(.default, value: presenter.isFlipped)
        }
    }
}
