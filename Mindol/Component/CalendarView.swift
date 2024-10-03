//
//  CalendarView.swift
//  Mindol
//
//  Created by dopamint on 10/3/24.
//

import SwiftUI
import FSCalendar

struct CalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    
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
        return calendar
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
        uiView.setCurrentPage(currentMonth, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        var parent: CalendarView
        
        init(_ parent: CalendarView) {
            self.parent = parent
        }
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
        }
    }
}
