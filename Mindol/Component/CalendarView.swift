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

    
    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.appearance.headerDateFormat = "MMMM yyyy"
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 20)
        calendar.swipeToChooseGesture.isEnabled = false
        calendar.scrollEnabled = false
        
        // 이전/이후 달의 날짜 숨기기
        calendar.placeholderType = .none
        
        // 오늘 날짜와 선택한 날짜의 강조 표시 제거
        calendar.appearance.todayColor = .clear
        calendar.appearance.selectionColor = .clear
        
        // 날짜 셀 커스터마이즈
        calendar.register(CustomCalendarCell.self, forCellReuseIdentifier: "cell")
        
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        uiView.setCurrentPage(currentMonth, animated: true)
        uiView.reloadData()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        var parent: CalendarView

        init(_ parent: CalendarView) {
            self.parent = parent
        }
        // 날짜를 선택했을 때 할일을 지정
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
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

        func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
            
            cell.contentView.frame = cell.bounds.insetBy(dx: 1, dy: 1)
        }
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            if parent.diaryRepository.getDiaryForDate(date) != nil {
                return .clear  // 일기가 있는 날짜의 텍스트 색상을 투명하게 설정
            }
            return nil
        }
    }
}

class CustomCalendarCell: FSCalendarCell {
    var rockImageView: UIImageView!

    override init!(frame: CGRect) {
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
