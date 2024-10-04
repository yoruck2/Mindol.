//
//  Date+.swift
//  Mindol
//
//  Created by dopamint on 9/30/24.
//

import Foundation

extension Date {
    static let formatter = DateFormatter()
    
    var formattedMonth: String {
        Date.formatter.locale = Locale(identifier: "en_US")
        Date.formatter.dateFormat = "yyyy\nMMMM"
        return Date.formatter.string(from: self)
    }
    
    var formattedKoreanDate: String {
        Date.formatter.dateFormat = "yyyy년 M월 d일"
        return Date.formatter.string(from: self)
    }
    
    var koreanDayOfWeek: String {
        
        Date.formatter.locale = Locale(identifier: "ko_KR")
        Date.formatter.dateFormat = "EEEE"
        return Date.formatter.string(from: self)
    }
    
    var month: Int {
        Date.formatter.dateFormat = "M"
        return Int(Date.formatter.string(from: self)) ?? .zero
    }
}
