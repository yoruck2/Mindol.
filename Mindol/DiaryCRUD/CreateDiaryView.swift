//
//  CreateDiaryView.swift
//  Mindol
//
//  Created by dopamint on 9/29/24.
//
import SwiftUI
import RealmSwift
import Combine

struct CreateDiaryView: View {
    var realm = DiaryRepository.shared
    var selectedRock: String
    @State private var diaryText: String
    private let placeholder: String
    var date: Date
    @Environment(\.dismiss) private var dismiss
    @State private var showingCancelAlert = false
    
    var editingDiary: DiaryTable?
    
    @ObservedRealmObject var diary: DiaryTable = DiaryTable()
    
    init(selectedRock: String,
         date: Date,
         diaryText: String = "",
         editingDiary: DiaryTable? = nil) {
        self.selectedRock = selectedRock
        self.date = date
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
                    
                    Text("\(date.formattedDate)")
                        .font(.headline)
                    
                    Text(date.koreanDayOfWeek)
                        .font(.subheadline)
                    
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
                    AdjustableTextEditor(text: $diaryText, placeholder: placeholder)
                        .frame(height: 450)
                    
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("취소") {
                            showingCancelAlert = true
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("저장") {
                            saveDiary()
                        }
                    }
                }
                
                
                KeyboardAdaptiveBottomBar {
                    AnyView(
                        HStack {
                            Button("First") {
                                print("tap first button")
                            }
                            Spacer()
                            Button("Second") {
                                print("tap second button")
                            }
                        }
                            .padding(.horizontal)
                    )
                }
            }
            
            .alert("일기 작성을 그만둘까요?", isPresented: $showingCancelAlert) {
                Button("나가기", role: .destructive) {
                    dismiss()
                }
                Button("계속 작성", role: .cancel) {}
            } message: {
                Text("작성하던 내용은 사라집니다.")
            }
        }
    }
    
    private func saveDiary() {
        let contents = Contents()
        contents.text = diaryText
        contents.photo = ""
        print(editingDiary)
        if let diary = editingDiary {
            try? realm.realm.write {
                diary.thaw()?.contents = contents
                
                $diary.wrappedValue.feeling = selectedRock
                $diary.wrappedValue.contents = contents
            }
        } else {
            let diary = DiaryTable(feeling: selectedRock, date: date, contents: contents)
            realm.createDiary(diary)
        }
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
                .frame(height: max(260, textEditorHeight - keyboardHeight))
                .padding(15)
                .background(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .lineSpacing(10)
                            .padding(20)
                            .padding(.top, 2)
                            .font(.system(size: 14))
                            .foregroundColor(Color(UIColor.systemGray2))
                    }
                }
                .autocorrectionDisabled()
                .background(Color(UIColor.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .scrollContentBackground(.hidden)
                .font(.system(size: 14))
                .overlay(alignment: .bottomTrailing) {
                    Text("\(text.count)")
                        .font(.system(size: 12))
                        .foregroundColor(Color(UIColor.systemGray2))
                        .padding(.trailing, 15)
                        .padding(.bottom, 15)
                }
                .onAppear {
                    self.textEditorHeight = geometry.size.height
                }
        }
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
struct KeyboardAdaptiveBottomBar: View {
    @State private var keyboardHeight: CGFloat = 0
    
    var content: () -> AnyView
    
    init(@ViewBuilder content: @escaping () -> AnyView) {
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            content()
                .frame(height: 40) // Toolbar의 일반적인 높이
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemBackground))
                .position(x: geometry.size.width / 2, y: geometry.size.height - keyboardHeight)
        }
        .ignoresSafeArea(.keyboard)
        .onReceive(keyboardPublisher) { newHeight in
            withAnimation(.easeInOut(duration: 0.25)) {
                self.keyboardHeight = newHeight
            }
        }
    }
    
    private var keyboardPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { notification in
                    notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                }
                .map { $0.height },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
        )
        .eraseToAnyPublisher()
    }
}


//struct ContextMenuPrac: View {
//
//    @State var backgroundColor = Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10.0) {
//            Image(systemName: "apple.logo")
//                .font(.title)
//            Text("SwiftUI")
//                .font(.headline)
//            Text("Better apps. Less code.")
//                .font(.subheadline)
//        }
//        .foregroundColor(.white)
//        .padding()
//        .background(backgroundColor.cornerRadius(10))
//        .contextMenu {
//            Button {
//                backgroundColor = .green
//            } label: {
//                Label("airtag", systemImage: "airtag.fill")
//            }
//
//            Button {
//                backgroundColor = .cyan
//            } label: {
//                Label("applewatch", systemImage: "applewatch.watchface")
//            }
//
//            Button {
//                backgroundColor = .pink
//            } label: {
//                HStack {
//                    Text("airpods")
//                    Image(systemName: "airpods.gen3")
//                }
//            }
//        }
//    }
//}
