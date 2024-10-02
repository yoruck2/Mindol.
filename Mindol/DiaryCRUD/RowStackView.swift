//
//  RowStackView.swift
//  Mindol
//
//  Created by dopamint on 9/30/24.
//

import SwiftUI

struct RowStackView: View {
    var diary: DiaryTable
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(diary.feeling)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading) {
                    Text(diary.date.formattedDate)
                    Text(diary.date.koreanDayOfWeek)
                }
                Spacer()
            }
            .padding()
            if let photo = diary.contents?.photo {
                Image(photo)
                    .padding(.horizontal)
            }
            if let text = diary.contents?.text {
                Text(text)
                    .lineLimit(5)
                    .padding(.horizontal)
            }
            
            Rectangle()
                .border(Color.divider)
                .frame(height: 1)
                .padding(.horizontal)
        }
    }
}
//struct DiaryTable1 {
//    var feeling: String
//    var date: Date
//    var contents: Contents1?
//}
//
//struct Contents1 {
//    var text: String?
//    var photo: String?
//}
//
//var diaryList = [
//    DiaryTable1(feeling: "star", date: Date()),
//    DiaryTable1(feeling: "star", date: Date(),contents: Contents1(text: "Sdf")),
//    DiaryTable1(feeling: "person", date: Date())
//]
//
