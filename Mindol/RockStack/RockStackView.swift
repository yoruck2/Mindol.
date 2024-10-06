//
//  RockStackView.swift
//  Mindol
//
//  Created by dopamint on 10/2/24.
//

import SwiftUI
import SpriteKit
import RealmSwift
import FSCalendar

struct RockStackView: View {
    @EnvironmentObject var sceneWrapper: SceneWrapper
       @EnvironmentObject var diaryRepository: DiaryRepository
       @StateObject private var flipCardPresenter = FlipCardPresenter()
       @State private var navigationPath = NavigationPath()
       @State private var selectedDate = Date()
       @State private var currentMonth = Date()
       @State private var selectedRock: Rock?
       @State private var showingEmotionSelection = false
       @State private var showCreateDiary = false
       @State private var showReadDiary = false
       @State private var selectedDiary: DiaryTable?
    @Binding var currentTab: Int
    var body: some View {
            NavigationStack(path: $navigationPath) {
                ZStack {
                    VStack(spacing: 0) {
                        monthSelector
                            .padding(.top, 10)
                        
                        FlipCardView(presenter: flipCardPresenter,
                                     sceneWrapper: sceneWrapper,
                                     selectedDate: $selectedDate,
                                     currentMonth: $currentMonth,
                                     showCreateDiary: $showCreateDiary,
                                     showReadDiary: $showReadDiary,
                                     showingEmotionSelection: $showingEmotionSelection,
                                     selectedDiary: $selectedDiary)
                        .padding(.vertical, 20)
                        Spacer(minLength: 60)
                    }
                    
                    VStack {
                        Spacer()
                        if !isCurrentMonthAndYear() {
                            Button {
                                moveToCurrentDate()
                            } label: {
                                Text("오늘")
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(Color.orange))
                                    .foregroundColor(.white)
                                    .padding(.leading, 3)
                            }
                            .transition(.opacity)
                            .animation(.easeInOut, value: isCurrentMonthAndYear())
                        }
                    HStack {
                        NavigationLink(destination: SettingsView()) {
                            Image("setup")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35, height: 35)
                                .foregroundColor(.black)
                        }
                        .padding(.leading, 30)
                        .padding(.bottom, 20)
                        
                        Spacer()
                        
                        Button {
                            checkAndProceedToNewDiary()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 65, height: 65)
                                .foregroundColor(.black)
                        }
                        .rotationEffect(.degrees(flipCardPresenter.isFlipped ? 45 : 0))
                        .animation(.bouncy(), value: flipCardPresenter.isFlipped)
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 0))
                        Spacer()
                        Button {
                                                    withAnimation(.spring()) {
                                                        withAnimation(.spring(duration: 0.4)) {
                                                                                        currentTab = 1
                                                                                    }
                                                    }
                                                } label: {
                                                    Image("menu2")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 30, height: 30)
                                                        .foregroundColor(.black)
                                                }
                                                .padding(.trailing, 40)
                                                .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onChange(of: currentMonth) { newValue in
            sceneWrapper.currentMonth = newValue
        }
        // + 버튼으로 일기 추가
        //        .fullScreenCover(isPresented: $showingEmotionSelection) {
        //            EmotionSelectionView(selectedRock: $selectedRock, date: $selectedDate)
        //        }
//        .sheet(isPresented: $showingEmotionSelection) {
//            EmotionSelectionView(selectedRock: $selectedRock, date: $selectedDate)
//        }
//        .fullScreenCover(item: $selectedRock) { rock in
//            CreateDiaryView(selectedRock: rock.rawValue, date: selectedDate, sceneWrapper: sceneWrapper)
//        }
        // scene에서 일기 선택
        .sheet(item: $sceneWrapper.selectedDiaryId) { diaryId in
            if let diary = diaryRepository.getDiary(by: diaryId) {
                ReadDiaryView(diary: diary)
            }
        }
        .sheet(isPresented: $showingEmotionSelection) {
                    EmotionSelectionView(selectedRock: $selectedRock, date: $selectedDate)
                }
                .fullScreenCover(item: $selectedRock) { rock in
                    CreateDiaryView(selectedRock: rock.rawValue, date: $selectedDate, sceneWrapper: sceneWrapper)
                }
                .sheet(item: $selectedDiary) { diary in
                    ReadDiaryView(diary: diary)
                }
        
        .onChange(of: sceneWrapper.currentMonth) { newValue in
//            updateScene(for: newValue)
        }
    }
    private func isCurrentMonthAndYear() -> Bool {
            let calendar = Calendar.current
            let now = Date()
            let currentComponents = calendar.dateComponents([.year, .month], from: now)
            let selectedComponents = calendar.dateComponents([.year, .month], from: sceneWrapper.currentMonth)
            return currentComponents.year == selectedComponents.year && currentComponents.month == selectedComponents.month
        }
        
        private func moveToCurrentDate() {
            let now = Date()
            sceneWrapper.currentMonth = now
            selectedDate = now
            currentMonth = now
            sceneWrapper.updateSceneForCurrentMonth()
        }
        

    
    // 오늘일기가 이미 있는지 확인
    private func checkAndProceedToNewDiary() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if diaryRepository.hasDiaryForDate(today) {
            flipCardPresenter.flipButtonTapped()
        } else {
            if flipCardPresenter.isFlipped == false {
                selectedDate = today
                showingEmotionSelection = true
            } else {
                flipCardPresenter.flipButtonTapped()
            }
        }
    }
    
    private var monthSelector: some View {
        HStack {
            Button(action: { moveMonth(by: -1) }) {
                Image(systemName: "chevron.left")
            }
            .disabled(!canMoveMonth(by: -1))
            
            Spacer()
            Text(sceneWrapper.currentMonth.formattedMonth)
                .multilineTextAlignment(.center)
                .onTapGesture {
                    flipCardPresenter.flipButtonTapped()
                }
            Spacer()
            
            Button(action: { moveMonth(by: 1) }) {
                Image(systemName: "chevron.right")
            }
            .disabled(!canMoveMonth(by: 1))
        }
        .padding()
    }
    
    private func moveMonth(by offset: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, 
                                               value: offset,
                                               to: sceneWrapper.currentMonth),
           canMoveMonth(by: offset) {
            sceneWrapper.currentMonth = newDate
//            updateScene(for: newDate)
//            calendarReference?.setCurrentPage(newDate, animated: true)
        }
    }
    
    private func canMoveMonth(by offset: Int) -> Bool {
        guard let newDate = Calendar.current.date(byAdding: .month, 
                                                  value: offset,
                                                  to: sceneWrapper.currentMonth)
        else {
            return false
        }
        let currentMonth = Date()
        return newDate <= currentMonth
    }
    //    private func canMoveYear(by offset: Int) -> Bool {
    //        guard let newDate = Calendar.current.date(byAdding: .month, value: offset, to: sceneWrapper.currentMonth) else {
    //            return false
    //        }
    //        let currentMonth = Date().year
    //        return 1900...currentMonth ~= newDate.year
    //    }
    
//    private func updateScene(for date: Date) {
//        sceneWrapper.updateScene(for: date)
//        sceneWrapper.refreshCalendar()
//    }
    
    //       private func moveMonth(by offset: Int) {
    //           if let newDate = Calendar.current.date(byAdding: .month, value: offset, to: sceneWrapper.currentMonth) {
    //               sceneWrapper.currentMonth = newDate
    //               updateScene(for: newDate)
    //           }
    //       }
    //
    //       private func updateScene(for date: Date) {
    //           sceneWrapper.updateScene()
    //       }
}
