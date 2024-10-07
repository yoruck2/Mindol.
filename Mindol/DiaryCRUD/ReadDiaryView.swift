//
//  ReadDiaryView.swift
//  Mindol
//
//  Created by dopamint on 9/30/24.
//

import SwiftUI
import RealmSwift

// Read, Update, Delete
struct ReadDiaryView: View {
    @ObservedRealmObject var diary: DiaryTable
    @ObservedObject var realm = DiaryRepository.shared
    @EnvironmentObject var sceneWrapper: SceneWrapper
    @State private var showingEditView = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingDeleteAlert = false
    @State private var isAnimating = true
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    
                    Image(diary.feeling)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 70)
                    Text(diary.date.formattedKoreanDate)
                    Text(diary.date.koreanDayOfWeek)
                        .opacity(0.7)
                        .padding(.top, -10)
                    Text(diary.contents?.text ?? "")
                        .frame(minWidth: 300, minHeight: 100)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .customFont(type: .Geurimilgi, size: 20)
                }
                .padding()
            }
            //        .ignoresSafeArea()
            //        .background(.background1)
            .scrollIndicators(.hidden)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .padding(.trailing, 40)
                            .frame(width: 80, height: 80)
                            .bold()
                    }
                }
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
                            .bold()
                    }
                    .alert("정말로 일기를 삭제할까요?", isPresented: $showingDeleteAlert) {
                        Button("삭제", role: .destructive) {
                            realm.deleteDiary(diary)
                            sceneWrapper.updateSceneForCurrentMonth()
                            sceneWrapper.updateCalendar()
                            dismiss()
                        }
                        Button("취소", role: .cancel) {}
                    } message: {
                        Text("삭제된 일기는 되돌릴 수 없습니다")
                    }
                }
            }
            .tint(.orange)
            .fullScreenCover(isPresented: $showingEditView) {
                CreateDiaryView(selectedRock: diary.feeling,
                                date: .constant(diary.date),
                                diaryText: diary.contents?.text ?? "",
                                editingDiary: diary, sceneWrapper: sceneWrapper)
                .onAppear(perform : UIApplication.shared.hideKeyboard)
            }
            if isAnimating {
                Color.clear
                    .contentShape(Rectangle())
                    .allowsHitTesting(true)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                isAnimating = false
            }
        }
        .onDisappear {
            isAnimating = true
        }
    }
}
struct GlobalBackgroundColor: ViewModifier {
    var color: Color
    
    func body(content: Content) -> some View {
        ZStack {
            color.edgesIgnoringSafeArea(.all)
            content
        }
    }
}

extension View {
    func globalBackground(_ color: Color) -> some View {
        self.modifier(GlobalBackgroundColor(color: color))
    }
}
