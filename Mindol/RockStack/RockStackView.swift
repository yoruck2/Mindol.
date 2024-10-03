//
//  RockStackView.swift
//  Mindol
//
//  Created by dopamint on 10/2/24.
//

import SwiftUI
import SpriteKit
import RealmSwift

struct RockStackView: View {
    @StateObject private var diaryRepository = DiaryRepository.shared
    @EnvironmentObject var sceneWrapper: SceneWrapper
    @StateObject private var flipCardPresenter = FlipCardPresenter()
    @State private var navigationPath = NavigationPath()
    @State private var selectedDate = Date()
    @State private var showingEmotionSelection = false
    @State private var selectedRock: Rock?
    
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
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showingEmotionSelection) {
                    EmotionSelectionView(selectedRock: $selectedRock)
                }
                .fullScreenCover(item: $selectedRock) { rock in
                    CreateDiaryView(selectedRock: rock.rawValue, date: selectedDate, sceneWrapper: sceneWrapper)
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
    
}
