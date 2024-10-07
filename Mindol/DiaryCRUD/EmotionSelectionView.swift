//
//  EmotionSelectionView.swift
//  Mindol
//
//  Created by dopamint on 9/29/24.
//

import SwiftUI

struct EmotionSelectionView: View {
    @Binding var selectedRock: Rock?
    @Binding var date: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text(date.formattedKoreanDate)
                Text("오늘의 감정을 선택해주세요")
                    .padding(.bottom, 40)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                    ForEach(Rock.allCases) { rock in
                        rock.image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .onTapGesture {
                                selectedRock = rock
                                dismiss()
                            }
                    }
                }
            }
            .padding(.bottom, 100)
            .globalBackground(.background1)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .onTapGesture {
                            dismiss()
                        }
                }
            }
        }
    }
}
