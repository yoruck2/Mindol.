//
//  ContentView.swift
//  Mindol
//
//  Created by dopamint on 9/29/24.
//

import SwiftUI
import RealmSwift

struct DirayListView: View {
    @StateObject private var realm = DiaryRepository.shared
    @EnvironmentObject var sceneWrapper: SceneWrapper
    
    @State private var showingEmotionSelection = false
    @State private var selectedRock: Rock?
    @ObservedResults(DiaryTable.self)
    var diaryList
    
    var body: some View {
        NavigationStack {
            if diaryList.isEmpty {
                VStack {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(.sad)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 65, height: 65)
                        Text("기억할 일기가 없습니다")
                    }
                }
            }
            ScrollView {
                if !diaryList.isEmpty {
                    let decendingDateList = diaryList.sorted(byKeyPath: "date", ascending: false)
                    ForEach(decendingDateList) { diary in
                        NavigationLink(destination: ReadDiaryView(diary: diary, sceneWrapper: _sceneWrapper)) {
                            RowStackView(diary: diary)
                        }
                        .tint(.black)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("새 일기") {
                        showingEmotionSelection = true
                    }
                }
            }
            .fullScreenCover(isPresented: $showingEmotionSelection) {
                EmotionSelectionView(selectedRock: $selectedRock)
            }
            .fullScreenCover(item: $selectedRock) { rock in
                CreateDiaryView(selectedRock: rock.rawValue, date: Date(), sceneWrapper: sceneWrapper)
            }
        }
    }
}


