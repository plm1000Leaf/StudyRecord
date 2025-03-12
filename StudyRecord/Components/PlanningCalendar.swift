import SwiftUI

struct PlanningCalendar: View {
    @State private var currentMonth: Date = Date()
    @Binding var isTapDate: Bool
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
                        todayStudyPlan
                    }
                }
            }
            .padding()
            
            HStack {
                Button(action: {
                    currentMonth = CalendarUtils.changeMonth(currentMonth: currentMonth, by: -1)
                }) {
                    Image(systemName: "chevron.left")
                }
            
                Spacer()
                
                Button(action: {
                    currentMonth = CalendarUtils.changeMonth(currentMonth: currentMonth, by: 1)
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
        }
    }
}

extension PlanningCalendar {
    private var todayStudyPlan: some View {
        VStack {
            ZStack {
                Button(action: {
                    withAnimation {
                        isTapDate = true
                    }
                }){
                    Rectangle()
                        .frame(width: 40, height: 32)
                }
            }
                
            HStack(spacing: 1) {
                Image(systemName: "clock")
                    .font(.system(size: 8))
                Text("13:00")
                    .font(.system(size: 8))
            }
            .padding(.bottom, 8)
        }
    }
    
    private var header: some View {
        Text(CalendarUtils.monthYearString(from: currentMonth))
            .font(.title)
    }
}

#Preview {
    PlanningCalendar(isTapDate: .constant(true))
}
