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
