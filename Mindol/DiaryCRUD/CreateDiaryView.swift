//
//  CreateDiaryView.swift
//  Mindol
//
//  Created by dopamint on 9/29/24.
//
import SwiftUI
import RealmSwift
import Combine

// Create
struct CreateDiaryView: View {
    var realm = DiaryRepository.shared
    var selectedRock: String
    @State private var diaryText: String
    private let placeholder: String
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var sceneWrapper: SceneWrapper
    @State private var showingCancelAlert = false
    
    @Binding var date: Date
    var editingDiary: DiaryTable?
    @ObservedRealmObject var diary: DiaryTable = DiaryTable()
    
    init(selectedRock: String,
         date: Binding<Date>,
         diaryText: String = "",
         editingDiary: DiaryTable? = nil,
         sceneWrapper: SceneWrapper) {
        self.selectedRock = selectedRock
        self._date = date
        self._diaryText = State(initialValue: diaryText)
        self.placeholder = "오늘의 기억을 새겨주세요"
        self.editingDiary = editingDiary
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .center, spacing: 20) {
                    
                    Image(selectedRock)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 70)
                    
                    Text("\(date.formattedKoreanDate)")
                    Text(date.koreanDayOfWeek)
                        .padding(.top, -10)
                        .opacity(0.7)
                    AdjustableTextEditor(text: $diaryText, placeholder: placeholder)
                        .frame(height: 450)
                        .customFont(type: .Geurimilgi,size: 20)
                    
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showingCancelAlert = true
                        } label: {
                            Image(systemName: "xmark")
                                .tint(.black)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            saveDiary()
                        } label: {
                            Image(systemName: "checkmark")
                                .tint(.black)
                        }

                    }
                }
                
                // TODO: 사진추가 기능 들어갈 곳
                //                KeyboardAdaptiveBottomBar {
                //                    AnyView(
                //                        HStack {
                //                            Button("First") {
                //                                print("tap first button")
                //                            }
                //                            Spacer()
                //                            Button("Second") {
                //                                print("tap second button")
                //                            }
                //                        }
                //                            .padding(.horizontal)
                //                    )
                //                }
            }
            
            .alert("일기 작성을 그만둘까요?", isPresented: $showingCancelAlert) {
                Button("나가기", role: .destructive) {
                    dismiss()
                }
                Button("계속 작성", role: .cancel) {}
            } message: {
                Text("작성하던 내용은 사라집니다.")
            }
            .globalBackground(.background1)
        }
    }
    
    private func saveDiary() {
        let contents = Contents()
        contents.text = diaryText
        contents.photo = ""
        
        if let diary = editingDiary {
            try? realm.realm.write {
                diary.thaw()?.contents = contents
                
                $diary.wrappedValue.feeling = selectedRock
                $diary.wrappedValue.contents = contents
            }
        } else {
            let newDiary = DiaryTable(feeling: selectedRock, date: date, contents: contents)
            realm.createDiary(newDiary)
            sceneWrapper.addSingleRock(newDiary)
        }
//        sceneWrapper.updateSceneForCurrentMonth()
        sceneWrapper.updateCalendar()
        dismiss()
    }
}
struct AdjustableTextEditor: View {
    @Binding var text: String
    var placeholder: String
    @State private var textEditorHeight: CGFloat = 200 // 초기 높이
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            TextEditor(text: $text)
                .customFont(type: .Geurimilgi, size: 20)
                .frame(height: max(260, textEditorHeight - keyboardHeight))
                .padding(15)
                .background(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .customFont(type: .Geurimilgi, size: 20)
                            .lineSpacing(10)
                            .padding(20)
                            .padding(.top, 2)
                            .foregroundColor(Color(UIColor.systemGray2))
                    }
                }
                .autocorrectionDisabled()
                .background(Color(UIColor.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .scrollContentBackground(.hidden)
                .customFont(type: .Geurimilgi, size: 20)
                .overlay(alignment: .bottomTrailing) {
                    Text("\(text.count)")
                        .foregroundColor(Color(UIColor.systemGray2))
                        .padding(.trailing, 15)
                        .padding(.bottom, 15)
                }
                .onAppear {
                    self.textEditorHeight = geometry.size.height * 0.8
                }
        }
        .customFont(type: .Geurimilgi, size: 20)
        .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
    }
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

// 내용에 따라 늘어나는 TextEditor

//                    TextEditor(text: $diaryText)
//                        .padding(15)
//                        .background(alignment: .topLeading) {
//                            if diaryText.isEmpty {
//                                Text(placeholder)
//                                    .lineSpacing(10)
//                                    .padding(20)
//                                    .padding(.top, 2)
//                                    .font(.system(size: 14))
//                                    .foregroundColor(Color(UIColor.systemGray2))
//                            }
//                        }
//                        .autocorrectionDisabled()
//                        .background(Color(UIColor.systemGray6))
//                        .clipShape(RoundedRectangle(cornerRadius: 20))
//                        .scrollContentBackground(.hidden)
//                        .font(.system(size: 14))
//                        .overlay(alignment: .bottomTrailing) {
//                            Text("\(diaryText.count)")
//                                .font(.system(size: 12))
//                                .foregroundColor(Color(UIColor.systemGray2))
//                                .padding(.trailing, 15)
//                                .padding(.bottom, 15)
//                                .onChange(of: diaryText) { newValue in
//                                    diaryText = String(newValue)
//                                }
//                        }
