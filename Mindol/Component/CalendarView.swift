//
//  CalendarView.swift
//  Mindol
//
//  Created by dopamint on 10/3/24.
//

import SwiftUI
import FSCalendar
import RealmSwift

struct CalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
//    @EnvironmentObject var sceneWrapper: SceneWrapper
    @EnvironmentObject var diaryRepository: DiaryRepository
    @Binding var showingEmotionSelection: Bool
    @Binding var showCreateDiary: Bool
    @Binding var showReadDiary: Bool
    @Binding var selectedDiary: DiaryTable?
    @Binding var calendarReference: FSCalendar?
    
    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.appearance.headerDateFormat = ""
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.titleSelectionColor = .black
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 20)
        calendar.appearance.eventOffset = CGPoint(x: 0, y: -7)
        calendar.swipeToChooseGesture.isEnabled = false
        calendar.scrollEnabled = false
        calendar.scrollDirection = .horizontal
        calendar.headerHeight = 0
        calendar.rowHeight = 20
        calendarReference = calendar
        
        // 이전/이후 달의 날짜 숨기기
        calendar.placeholderType = .none
        
        // 오늘 날짜와 선택한 날짜의 강조 표시 제거
        calendar.appearance.selectionColor = .clear
        if diaryRepository.hasDiaryForDate(Date()) {
            calendar.appearance.todayColor = .clear
        }
        calendar.appearance.todayColor = .orange
        
        // 날짜 셀 커스터마이즈
        calendar.register(CustomCalendarCell.self, forCellReuseIdentifier: "cell")
        return calendar
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
        if !Calendar.current.isDate(uiView.currentPage, equalTo: currentMonth, toGranularity: .month) {
            uiView.setCurrentPage(currentMonth, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        var parent: CalendarView
        
        init(_ parent: CalendarView) {
            self.parent = parent
        }
        func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
            let newDate = calendar.currentPage
            parent.currentMonth = newDate
        }
        
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            if date <= Date() {
                parent.selectedDate = date
                if let diary = parent.diaryRepository.getDiaryForDate(date) {
                    parent.selectedDiary = diary
                    
                    parent.showReadDiary = true
                } else {
                    parent.selectedDate = date
                    parent.showingEmotionSelection = true
                }
            } else {
                calendar.deselect(date)
            }
        }
        
        func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
            let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! CustomCalendarCell
            
            if let diary = parent.diaryRepository.getDiaryForDate(date) {
                cell.rockImageView.image = UIImage(named: diary.feeling)
                cell.rockImageView.isHidden = false
                cell.titleLabel.isHidden = true
            } else {
                cell.rockImageView.isHidden = true
                cell.titleLabel.isHidden = false
                cell.titleLabel.text = "\(Calendar.current.component(.day, from: date))"
            }
            
            return cell
        }
        
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            if date > Date() {
                return .lightGray
            }
            return nil
        }
        
        func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
            return date <= Date()
        }
    }
}

class CustomCalendarCell: FSCalendarCell {
    var rockImageView: UIImageView!
    
    override init?(frame: CGRect) {
        super.init(frame: frame)
        
        rockImageView = UIImageView()
        rockImageView.contentMode = .scaleAspectFit
        contentView.addSubview(rockImageView)
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rockImageView.frame = contentView.bounds.insetBy(dx: 5, dy: 5)
    }
}
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        return self.date(from: self.dateComponents([.year, .month], from: date))!
    }
}

struct CustomCalendarView: View {
    @EnvironmentObject var sceneWrapper: SceneWrapper
        @EnvironmentObject var diaryRepository: DiaryRepository
        @Binding var selectedDate: Date
        @Binding var currentMonth: Date
        @State private var calendar = Calendar.current
        @Binding var showingEmotionSelection: Bool
        @Binding var showReadDiary: Bool
        @Binding var selectedDiary: DiaryTable?
        
        @State private var forceUpdate: Bool = false

        var body: some View {
            VStack {
                dayOfWeekHeader
                calendarGrid
            }
            .onChange(of: sceneWrapper.calendarNeedsUpdate) { needsUpdate in
                if needsUpdate {
                    forceUpdate.toggle()  // 이 상태 변경으로 뷰를 강제로 다시 그립니다.
                    sceneWrapper.calendarNeedsUpdate = false
                }
            }
        }

        private var dayOfWeekHeader: some View {
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                }
            }
        }

    private var calendarGrid: some View {
            let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)!.count
            let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
            let startingSpaces = calendar.component(.weekday, from: firstOfMonth) - 1

            return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7), spacing: 15) { // spacing 값을 조정
                ForEach(0..<42) { index in
                    if index < startingSpaces || index >= startingSpaces + daysInMonth {
                        Color.clear
                    } else {
                        let date = calendar.date(byAdding: .day, value: index - startingSpaces, to: firstOfMonth)!
                        DayCell(date: date, selectedDate: $selectedDate, diaryRepository: diaryRepository, showingEmotionSelection: $showingEmotionSelection, showReadDiary: $showReadDiary, selectedDiary: $selectedDiary)
                    }
                }
            }
            .id(forceUpdate)
        }
}

struct DayCell: View {
    let date: Date
    @Binding var selectedDate: Date
    let diaryRepository: DiaryRepository
    @Binding var showingEmotionSelection: Bool
    @Binding var showReadDiary: Bool
    @Binding var selectedDiary: DiaryTable?

    var body: some View {
            VStack {
                if let diary = diaryRepository.getDiaryForDate(date) {
                    Image(diary.feeling)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                } else {
                    Text(String(Calendar.current.component(.day, from: date)))
                        .foregroundColor(date > Date() ? .gray : .primary)
                }
            }
            .frame(height: 40) // 높이를 증가
            .opacity(date > Date() ? 0.3 : 1.0)
            .onTapGesture {
                if date <= Date() {
                    selectedDate = date
                    if let diary = diaryRepository.getDiaryForDate(date) {
                        selectedDiary = diary
                        showReadDiary = true
                    } else {
                        showingEmotionSelection = true
                    }
                }
            }
        }
    }
