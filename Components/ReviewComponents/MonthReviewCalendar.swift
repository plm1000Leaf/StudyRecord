import SwiftUI
import CoreData
import UIKit

struct MonthReviewCalendar: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var recordService = DailyRecordService.shared

    @Binding var currentMonth: Date
    @Binding var showDateReviewView: Bool
    @State private var checkedDates: [Int: Bool] = [:]
    
    var onDateSelected: ((Int) -> Void)? = nil
    var onShareTapped: (() -> Void)? = nil
    
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
                            if date > 0 {
                                Text("\(date)")
                                    .font(.system(size: 16))
                                    .padding(.leading, 16)
                                    .cornerRadius(5)
                                checkMark(for: date)
                            }
                        }
                    }
                }
                .padding()
                

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
        }
        .onAppear {
            loadCheckedDates()
        }
        .onChange(of: currentMonth) { _ in
            loadCheckedDates()
        }
    }
}

extension MonthReviewCalendar {
    private func checkMark(for date: Int) -> some View {
        Button(action: {
            onDateSelected?(date)
            withAnimation {
                showDateReviewView = true
            }
        }){
            if checkedDates[date] == true {
                Circle()
                    .frame(width: 30)
                    .padding(.bottom, 8)
                    .foregroundColor(.mainColor0)
            } else {
                Circle()
                    .stroke(
                        Color.mainColor0,
                        style: StrokeStyle(
                            lineWidth: 2,
                            dash: [5, 3]  // [線の長さ, 空白の長さ]
                        )
                    )
                    .frame(width: 30)
                    .padding(.bottom, 8)
            }
            
        }
    }
    
    private func loadCheckedDates() {
         checkedDates = recordService.loadCheckedDates(for: currentMonth, context: viewContext)
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
            Button(action: {
                onShareTapped?()
            }){
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 24))
                    .frame(maxWidth: .infinity, alignment:
                            .trailing)
                    .padding(.trailing, 28)
            }
        }
        
        .padding(.top, 40)
        
    }
    
}


