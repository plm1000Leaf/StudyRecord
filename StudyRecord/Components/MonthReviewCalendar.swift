import SwiftUI

struct MonthReviewCalendar: View {
    @State private var currentMonth: Date = Date()
    @Binding var showDateReviewView: Bool
    var body: some View {
        ZStack {

            VStack{

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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

extension MonthReviewCalendar {
    private var checkMark: some View {
        Button(action: {
            withAnimation {
                showDateReviewView = true
            }
        }){
            Circle()
                .frame(width: 30)
                .padding(.bottom, 8)
        }
    }
    
    private var header: some View {
        HStack(alignment: .bottom){
            Text(CalendarUtils.yearString(from: currentMonth))
                .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
                .font(.system(size: 16))
                .padding(.leading, 28)

            Text(CalendarUtils.monthString(from: currentMonth))
                .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
                .font(.system(size: 48))
                .padding(.leading, 8)

            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 24))
                .frame(maxWidth: .infinity, alignment:
                        .trailing)
                .padding(.trailing, 28)
        }

        .padding(.top, 40)

    }
}

#Preview {
    MonthReviewCalendar(showDateReviewView: .constant(true))
}

