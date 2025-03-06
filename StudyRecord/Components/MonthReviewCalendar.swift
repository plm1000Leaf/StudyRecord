import SwiftUI

struct MonthReviewCalendar: View {
    @State private var currentMonth: Date = Date()

    var body: some View {
        VStack {
            header
            
            let days = CalendarUtils.generateCalendarDays(for: currentMonth)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                    Text(day)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                
                ForEach(days, id: \.self) { date in
                    VStack {
                        Text(date > 0 ? "\(date)" : "")
                            .font(.system(size: 16))
                            .padding(.leading, 16)
                            .cornerRadius(5)
                        checkMark
                    }
                }
            }
            .padding()
            

        }
    }
}

extension MonthReviewCalendar {
    private var checkMark: some View {
        Circle()
            .frame(width: 30)
            .padding(.bottom, 8)
    }
    
    private var header: some View {
        Text(CalendarUtils.monthYearString(from: currentMonth))
            .font(.title)
    }
}

#Preview {
    MonthReviewCalendar()
}

