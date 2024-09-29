//
//  ContentView.swift
//  Mindol
//
//  Created by dopamint on 9/29/24.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = DiaryViewModel()
    @State private var showingEmotionSelection = false
    @State private var selectedRock: Rock?
    
    var body: some View {
        NavigationStack {
            List(viewModel.diaries) { diary in
                DiaryRowView(diary: diary)
            }
            .navigationTitle("감정 일기")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("새 일기") {
                        showingEmotionSelection = true
                    }
                }
            }
            .sheet(isPresented: $showingEmotionSelection) {
                EmotionSelectionView(selectedRock: $selectedRock)
            }
            .fullScreenCover(item: $selectedRock) { rock in
                CreateDiaryView(viewModel: viewModel, selectedRock: $selectedRock)
            }
        }
    }
}

struct DiaryRowView: View {
    let diary: DiaryTable
    
    var body: some View {
        HStack {
            Image(diary.feeling)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(diary.date, style: .date)
                Text(diary.contents?.text ?? "")
                    .lineLimit(1)
            }
        }
    }
}


#Preview {
    MainView()
}
