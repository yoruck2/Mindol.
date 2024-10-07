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
    @State private var selectedMonth: Int? = nil
    @State private var showYearPicker = false
    
    var filteredDiaries: [DiaryTable] {
        let descendingDateList = diaryList.sorted(byKeyPath: "date", ascending: false)
        return descendingDateList.filter { diary in
            let components = Calendar.current.dateComponents([.year, .month], from: diary.date)
            let yearMatches = components.year == selectedYear
            let monthMatches = selectedMonth == nil || components.month == selectedMonth
            return yearMatches && monthMatches
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Group {
                    if filteredDiaries.isEmpty {
                        
                        VStack(spacing: 20) {
                            Image(.sad)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 65, height: 65)
                            if let selectedMonth {
                                Text("\(selectedYear.description)년 \(selectedMonth)월에 기억할 일기가 없습니다")
                            } else {
                                Text("\(selectedYear.description)년에 기억할 일기가 없습니다")
                            }
                        }
                        
                    } else {
                        ScrollView {
                            ForEach(filteredDiaries) { diary in
                                NavigationLink(destination: ReadDiaryView(diary: diary, sceneWrapper: _sceneWrapper).globalBackground(.background1)) {
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
                            Text(toolbarTitle)
                                .capsuleBackground()
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
                
                .navigationBarTitleDisplayMode(.inline)
                
                if showYearPicker {
                    DatePickerView(selectedYear: $selectedYear, selectedMonth: $selectedMonth, isPresented: $showYearPicker)
                        .customFont(type: .Geurimilgi, size: 20)
                }
            }
            .globalBackground(.background1)
        }
        var toolbarTitle: String {
            if let month = selectedMonth {
                return "\(selectedYear)년 \(month)월"
            } else {
                return "\(selectedYear)년"
            }
        }
    }
}


struct CapsuleBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color.orange.opacity(0.3)))
            .foregroundColor(.primary)
            .shadow(radius: 10)
    }
}

extension View {
    func capsuleBackground() -> some View {
        self.modifier(CapsuleBackgroundModifier())
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


//struct YearPickerView1: View {
//    @Binding var selectedYear: Int
//    @Binding var isPresented: Bool
//    @State private var opacity: Double = 0
//    @State private var tempSelectedYear: Int
//
//    private let currentYear = Calendar.current.component(.year, from: Date())
//    private let yearRange: [Int]
//
//    init(selectedYear: Binding<Int>, isPresented: Binding<Bool>) {
//        self._selectedYear = selectedYear
//        self._isPresented = isPresented
//        let currentYear = Calendar.current.component(.year, from: Date())
//        self.yearRange = Array(1900...currentYear).reversed()
//        self._tempSelectedYear = State(initialValue: selectedYear.wrappedValue)
//    }
//
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.4)
//                .edgesIgnoringSafeArea(.all)
//                .onTapGesture {
//                    dismissView()
//                }
//
//            VStack {
//                Text("연도 선택")
//                    .font(.headline)
//                    .padding()
//
//                ScrollView {
//                    LazyVStack {
//                        ForEach(yearRange, id: \.self) { year in
//                            Button(action: {
//                                tempSelectedYear = year
//                            }) {
//                                Text(String(year))
//                                    .foregroundColor(tempSelectedYear == year ? .blue : .primary)
//                                    .padding(.vertical, 8)
//                            }
//                        }
//                    }
//                }
//                .frame(height: 200)
//
//                Button("선택") {
//                    selectedYear = tempSelectedYear
//                    dismissView()
//                }
//                .padding()
//            }
//            .frame(width: 250, height: 300)
//            .background(Color.white)
//            .cornerRadius(20)
//            .shadow(radius: 10)
//        }
//        .opacity(opacity)
//        .onAppear {
//            withAnimation(.easeIn(duration: 0.2)) {
//                opacity = 1
//            }
//        }
//    }
//
//    private func dismissView() {
//        withAnimation(.easeOut(duration: 0.2)) {
//            opacity = 0
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            isPresented = false
//        }
//    }
//}
