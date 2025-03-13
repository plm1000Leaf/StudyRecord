//
//  CalendarViewModels.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/03/06.
//
//
//  CalendarUtils.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/21.
//

import Foundation

struct CalendarUtils {
    static func changeMonth(currentMonth: Date, by offset: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: offset, to: currentMonth) ?? currentMonth
    }
    

    static func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    static func yearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    static func generateCalendarDays(for date: Date) -> [Int] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        let firstWeekday = calendar.component(.weekday, from: date.startOfMonth()) - 1
        return Array(repeating: 0, count: firstWeekday) + Array(1...range.count)
    }
}

extension Date {
    func startOfMonth() -> Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
}
