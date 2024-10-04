//
//  ReadDiaryView.swift
//  Mindol
//
//  Created by dopamint on 9/30/24.
//

import SwiftUI
import RealmSwift

struct ReadDiaryView: View {
    @ObservedRealmObject var diary: DiaryTable
    @ObservedObject var realm = DiaryRepository.shared
    @EnvironmentObject var sceneWrapper: SceneWrapper
    @State private var showingEditView = false
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                Image(diary.feeling)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 70)
                Text(diary.date.formattedKoreanDate)
                    .font(.headline)
                Text(diary.date.koreanDayOfWeek)
                    .font(.subheadline)
                Text(diary.contents?.text ?? "")
                    .frame(minWidth: 300, minHeight: 100)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("수정", systemImage: "square.and.pencil") {
                        showingEditView = true
                    }
                    Button("삭제", systemImage: "trash", role: .destructive) {
                        showingDeleteAlert = true
                        
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .alert("정말로 일기를 삭제할까요?", isPresented: $showingDeleteAlert) {
                    Button("삭제", role: .destructive) {
                        realm.deleteDiary(diary)
//                        $diaryList.remove(diary)
                        dismiss()
                    }
                    Button("취소", role: .cancel) {}
                } message: {
                    Text("삭제된 일기는 되돌릴 수 없습니다")
                }
            }
        }
        .fullScreenCover(isPresented: $showingEditView) {
            CreateDiaryView(selectedRock: diary.feeling,
                            date: diary.date,
                            diaryText: diary.contents?.text ?? "",
                            editingDiary: diary, sceneWrapper: sceneWrapper)
            .onAppear(perform : UIApplication.shared.hideKeyboard)
        }
    }
}
