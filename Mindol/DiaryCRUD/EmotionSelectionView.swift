//
//  EmotionSelectionView.swift
//  Mindol
//
//  Created by dopamint on 9/29/24.
//

import SwiftUI

struct EmotionSelectionView: View {
    @Binding var selectedRock: Rock?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                    ForEach(Rock.allCases) { rock in
                        rock.image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .onTapGesture {
                                selectedRock = rock
                                dismiss()
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("감정 선택")
        }
    }
}
