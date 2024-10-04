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
    @EnvironmentObject var diaryRepository: DiaryRepository
    @Binding var showCreateDiary: Bool
    @Binding var showReadDiary: Bool
    @Binding var selectedDiary: DiaryTable?
    @Binding var calendarReference: FSCalendar?
    
    
    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.appearance.headerDateFormat = "MMMM yyyy"
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.titleSelectionColor = .black
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 20)
        calendar.appearance.eventOffset = CGPoint(x: 0, y: -7)
        calendar.swipeToChooseGesture.isEnabled = false
        calendar.scrollEnabled = true
        calendar.scrollDirection = .vertical
        calendarReference = calendar
        
        // 이전/이후 달의 날짜 숨기기
        calendar.placeholderType = .none
        
        // 오늘 날짜와 선택한 날짜의 강조 표시 제거
        calendar.appearance.todayColor = .clear
        calendar.appearance.selectionColor = .clear
        
        // 날짜 셀 커스터마이즈
        calendar.register(CustomCalendarCell.self, forCellReuseIdentifier: "cell")
        calendar.scrollEnabled = true
        // 캘린더 스크롤 방향 지정
        calendar.scrollDirection = .vertical
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
                    parent.showCreateDiary = true
                }
            } else {
                // 미래 날짜 선택 시 선택 취소
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
