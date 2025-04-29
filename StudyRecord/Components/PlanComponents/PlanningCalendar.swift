import SwiftUI

struct PlanningCalendar: View {
    @Binding var currentMonth: Date
    @Binding var isTapDate: Bool
    @Binding var showPopup: Bool
    
    var body: some View {
        ZStack{
            ScrollView {
                VStack(spacing: 0) {
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
                }
            }
            
            VStack {
                Spacer()
                moveButton
                    .padding(.horizontal)
                    .padding(.bottom, 16)
            }
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
                        .foregroundColor(.mainColor0)
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
        Button(action: {showPopup = true}){
            HStack(alignment: .bottom){
                Text(CalendarUtils.yearString(from: currentMonth))
                    .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
                    .font(.system(size: 16))
                    .padding(.leading, 28)
                
                Text(CalendarUtils.monthString(from: currentMonth))
                    .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
                    .font(.system(size: 48))
                    .padding(.leading, 8)
                Spacer()
                    .frame(width: 8)
                Image(systemName: "chevron.down")
                    .font(.system(size: 16))
                    .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
            }
            .frame(maxWidth: .infinity, alignment:
                    .leading)
            .foregroundColor(.black)
        }
    }
        private var moveButton: some View {
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


