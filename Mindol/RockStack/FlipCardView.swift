//
//  FlipCardView.swift
//  Mindol
//
//  Created by dopamint on 10/3/24.
//

import SwiftUI
import SpriteKit
import FSCalendar

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
    @Binding var currentMonth: Date
    @Binding var showCreateDiary: Bool
    @Binding var showReadDiary: Bool
    @Binding var showingEmotionSelection: Bool
    @Binding var selectedDiary: DiaryTable?
//    @Binding var calendarReference: FSCalendar?
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                // 앞면 (RockStackScene)
                SpriteView(scene: sceneWrapper.getScene())
                
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.6)
                    .multilineTextAlignment(.center)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .opacity(presenter.isFlipped ? 0 : 1)
                
                // 뒷면 (Calendar)
                CustomCalendarView(selectedDate: $selectedDate,
                                   currentMonth: $sceneWrapper.currentMonth,
                                   showingEmotionSelection: $showingEmotionSelection,
                                   showReadDiary: $showReadDiary,
                                   selectedDiary: $selectedDiary)
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.6)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .opacity(presenter.isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
            .frame(width: UIScreen.main.bounds.width)
            .rotation3DEffect(.degrees(presenter.isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .animation(.default, value: presenter.isFlipped)
        }
    }
}
