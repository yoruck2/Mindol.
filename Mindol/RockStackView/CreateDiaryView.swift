//
//  CreateDiaryView.swift
//  Mindol
//
//  Created by dopamint on 9/29/24.
//
import SwiftUI

struct CreateDiaryView: View {
    @ObservedObject var viewModel: DiaryViewModel
    @Binding var selectedRock: Rock?
    @State private var diaryText = ""
    private let placeholder: String = "오늘의 기억을 새겨주세요"
    @Environment(\.dismiss) private var dismiss
    @State private var showingCancelAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    selectedRock?.image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                    
                    
                    Text("\(Date().formatted(date: .long, time: .omitted))")
                        .font(.headline)
                    
                    Text(Date().formatted(.dateTime.weekday(.wide)))
                        .font(.subheadline)
                    
                        TextEditor(text: $diaryText)
                            .customStyleEditor(placeholder: placeholder, userInput: $diaryText)
                            .frame(minHeight: 200)
                            .background(Color(UIColor.systemBackground))

                }
                .padding()
            }
            .navigationTitle("일기 작성")
            .navigationBarTitleDisplayMode(.inline)
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
        guard let rock = selectedRock else { return }
        let contents = Contents()
        contents.text = diaryText
        
        let diary = DiaryTable(feeling: rock, date: Date(), contents: contents)
        
        viewModel.createDiary(diary)
        dismiss()
    }
}
