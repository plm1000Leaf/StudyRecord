//
//  planningCalendarView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/21.
//

import SwiftUI

struct CustomCalendarView: View {
    @State private var currentMonth: Date = Date()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    changeMonth(by: -1)
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Text(monthYearString(from: currentMonth))
                    .font(.title)
                
                Button(action: {
                    changeMonth(by: 1)
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            let days = generateCalendarDays(for: currentMonth)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                    Text(day)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                
                ForEach(days, id: \.self) { date in
                    Text(date > 0 ? "\(date)" : "")
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(date > 0 ? Color.blue.opacity(0.2) : Color.clear)
                        .cornerRadius(5)
                }
            }
            .padding()
        }
    }
    
    private func changeMonth(by offset: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: offset, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 MM月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    private func generateCalendarDays(for date: Date) -> [Int] {
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

struct CustomCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CustomCalendarView()
    }
}
