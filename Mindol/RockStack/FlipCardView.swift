//
//  FlipCardView.swift
//  Mindol
//
//  Created by dopamint on 10/3/24.
//

import SwiftUI
import SpriteKit

class FlipCardPresenter: ObservableObject {
    @Published var isFlipped: Bool = false
    
    func flipButtonTapped() {
        withAnimation {
            isFlipped.toggle()
        }
    }
}
struct FlipCardView: View {
    @ObservedObject var presenter: FlipCardPresenter
    @ObservedObject var sceneWrapper: SceneWrapper
    @Binding var selectedDate: Date
    
    var body: some View {
        ZStack {
            // 앞면 (RockStackScene)
            SpriteView(scene: sceneWrapper.getScene())
                .frame(width: 350, height: 450)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .opacity(presenter.isFlipped ? 0 : 1)
            
            // 뒷면 (Calendar)
            CalendarView(selectedDate: $selectedDate, currentMonth: $sceneWrapper.currentMonth)
                .frame(width: 350, height: 450)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .opacity(presenter.isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .rotation3DEffect(.degrees(presenter.isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.default, value: presenter.isFlipped)
    }
}