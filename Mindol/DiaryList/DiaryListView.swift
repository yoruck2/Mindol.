//
//  ContentView.swift
//  Mindol
//
//  Created by dopamint on 9/29/24.
//

import SwiftUI
import RealmSwift

struct DiaryListView: View {
    @StateObject private var realm = DiaryRepository.shared
    @EnvironmentObject var sceneWrapper: SceneWrapper
    
    @ObservedResults(DiaryTable.self) var diaryList
    
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showYearPicker = false
    
    var filteredDiaries: [DiaryTable] {
        let descendingDateList = diaryList.sorted(byKeyPath: "date", ascending: false)
        return descendingDateList.filter { diary in
            Calendar.current.component(.year, from: diary.date) == selectedYear
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Group {
                    if filteredDiaries.isEmpty {
                        VStack {
                            
                            VStack(spacing: 20) {
                                Image(.sad)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 65, height: 65)
                                Text("\(selectedYear)년에 기억할 일기가 없습니다")
                            }
                        }
                    } else {
                        ScrollView {
                            ForEach(filteredDiaries) { diary in
                                NavigationLink(destination: ReadDiaryView(diary: diary, sceneWrapper: _sceneWrapper)) {
                                    RowStackView(diary: diary)
                                }
                                .tint(.black)
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Button(action: {
                            showYearPicker = true
                        }) {
                            Text("\(selectedYear.description)")
                                .foregroundColor(.primary)
                        }
                    }
                    //                    ToolbarItem(placement: .topBarTrailing) {
                    //                        Button {
                    //                            // 검색 기능 구현
                    //                        } label: {
                    //                            Image(systemName: "magnifyingglass")
                    //                        }
                    //                    }
                }
                .navigationTitle("일기 목록")
                .navigationBarTitleDisplayMode(.inline)
                
                if showYearPicker {
                    YearPickerView(selectedYear: $selectedYear, isPresented: $showYearPicker)
                }
            }
        }
    }
}



//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("새 일기") {
//                        showingEmotionSelection = true
//                    }
//                }
//            }
//            .fullScreenCover(isPresented: $showingEmotionSelection) {
//                EmotionSelectionView(selectedRock: $selectedRock)
//            }
//            .fullScreenCover(item: $selectedRock) { rock in
//                CreateDiaryView(selectedRock: rock.rawValue, date: Date(), sceneWrapper: sceneWrapper)
//                    .onAppear(perform : UIApplication.shared.hideKeyboard)
//            }
//        }
//    }
//}


