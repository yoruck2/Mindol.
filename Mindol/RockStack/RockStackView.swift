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
    @State private var showingEmotionSelection = false
    @State private var selectedRock: Rock?
    @State private var showCreateDiary = false
    @State private var showReadDiary = false
    @State private var selectedDiary: DiaryTable?
    @State private var calendarReference: FSCalendar?
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                monthSelector
                
                FlipCardView(presenter: flipCardPresenter,
                                             sceneWrapper: sceneWrapper,
                             selectedDate: $selectedDate, currentMonth: $currentMonth,
                                             showCreateDiary: $showCreateDiary,
                                             showReadDiary: $showReadDiary,
                                             selectedDiary: $selectedDiary,
                                             calendarReference: $calendarReference)
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
        }
        .onChange(of: currentMonth) { newValue in
            sceneWrapper.currentMonth = newValue
        }
        .fullScreenCover(isPresented: $showingEmotionSelection) {
            EmotionSelectionView(selectedRock: $selectedRock)
        }
        .fullScreenCover(item: $selectedRock) { rock in
            CreateDiaryView(selectedRock: rock.rawValue, date: selectedDate, sceneWrapper: sceneWrapper)
        }
        .sheet(isPresented: $showCreateDiary) {
            CreateDiaryView(selectedRock: selectedRock?.rawValue ?? "", date: selectedDate, sceneWrapper: sceneWrapper)
        }
        .sheet(isPresented: $showReadDiary) {
            if let diary = selectedDiary {
                ReadDiaryView(diary: diary)
            }
        }
        .onChange(of: sceneWrapper.currentMonth) { newValue in
            updateScene(for: newValue)
        }
    }
    
    private func checkAndProceedToNewDiary() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if diaryRepository.hasDiaryForDate(today) {
            flipCardPresenter.flipButtonTapped()
        } else {
            selectedDate = today
            showingEmotionSelection = true
        }
    }
    
    private var monthSelector: some View {
        HStack {
            Button(action: { moveMonth(by: -1) }) {
                Image(systemName: "chevron.left")
            }
            .disabled(!canMoveMonth(by: -1))
            
            Spacer()
            Text(formattedMonth)
            Spacer()
            
            Button(action: { moveMonth(by: 1) }) {
                Image(systemName: "chevron.right")
            }
            .disabled(!canMoveMonth(by: 1))
        }
        .padding()
    }
    
    private func moveMonth(by offset: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: offset, to: sceneWrapper.currentMonth),
           canMoveMonth(by: offset) {
            sceneWrapper.currentMonth = newDate
            updateScene(for: newDate)
            calendarReference?.setCurrentPage(newDate, animated: true)
        }
    }
    
    private func canMoveMonth(by offset: Int) -> Bool {
        guard let newDate = Calendar.current.date(byAdding: .month, value: offset, to: sceneWrapper.currentMonth) else {
            return false
        }
        let currentMonth = Calendar.current.startOfMonth(for: Date())
        return newDate <= currentMonth
    }
    
    private func updateScene(for date: Date) {
        sceneWrapper.updateScene(for: date)
    }
    
    private var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMMM"
        return formatter.string(from: sceneWrapper.currentMonth)
    }
    
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
