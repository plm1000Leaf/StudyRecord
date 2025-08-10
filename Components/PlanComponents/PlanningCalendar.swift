import SwiftUI
import CoreData
import Combine

struct PlanningCalendar: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject private var recordService = DailyRecordService.shared
    @Binding var currentMonth: Date
    @Binding var isTapDate: Bool
    @Binding var showPopup: Bool
    @Binding var selectedDate: Date?
    
    @State private var dailyData: [Int: DailyStudyData] = [:]
    @State private var refreshTrigger = false // 手動更新用のトリガー

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
                                .padding(.bottom, 8)
                        }
                        
                        ForEach(days, id: \.self) { date in
                            VStack {
                                if date > 0 {
                                    Text("\(date)")
                                        .font(.system(size: 16))
                                        .padding(.leading, 16)
                                        .cornerRadius(5)
                                    todayStudyPlan(for: date)
                                }
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
            }
        }
        .onAppear {
            loadMonthlyData()
        }
        .onChange(of: currentMonth) { _ in
            loadMonthlyData()
        }
        .onChange(of: refreshTrigger) { _ in
            // 手動更新トリガー
            loadMonthlyData()
        }
        .onReceive(recordService.objectWillChange) { _ in
            loadMonthlyData()
        }
    }
    
    // MARK: - Public Methods
    
    /// 外部からデータ更新を要求する関数
    func refreshData() {
        refreshTrigger.toggle()
    }
    
    // MARK: - Data Loading
    private func loadMonthlyData() {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: currentMonth)
        let month = calendar.component(.month, from: currentMonth)
        let numberOfDays = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
        
        var newData: [Int: DailyStudyData] = [:]
        
        for day in 1...numberOfDays {
            if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                let record = DailyRecordManager.shared.fetchOrCreateRecord(for: date, context: viewContext)
                newData[day] = DailyStudyData(
                    materialName: record.material?.name,
                    scheduledTime: formatTime(hour: record.scheduledHour, minute: record.scheduledMinute),
                    hasData: record.material != nil || record.scheduledHour != 0 || record.scheduledMinute != 0
                )
            }
        }
        
        dailyData = newData
        print("📅 カレンダーデータを更新しました: \(newData.count)日分")
    }
    
    private func formatTime(hour: Int16, minute: Int16) -> String {
        if hour == 0 && minute == 0 {
            return "未設定"
        }
        return String(format: "%02d:%02d", hour, minute)
    }
}

struct DailyStudyData {
    let materialName: String?
    let scheduledTime: String
    let hasData: Bool
}

extension PlanningCalendar {
    private func todayStudyPlan(for date: Int) -> some View {
        let studyData = dailyData[date]
        
    return VStack {
            ZStack {
                Button(action: {
                    withAnimation {
                        selectedDate = Calendar.current.date(from: DateComponents(
                            year: Calendar.current.component(.year, from: currentMonth),
                            month: Calendar.current.component(.month, from: currentMonth),
                            day: date
                        ))
                        isTapDate = true
                    }
                }) {
                    if let materialName = studyData?.materialName {
                        ZStack{
                            Rectangle()
                                .cornerRadius(2.5)
                                .frame(width: 40, height: 32)
                                .foregroundColor(.mainColor0)
                            Text(studyData?.materialName ?? "")
                                .font(.system(size: 8))
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 36)
                                .padding(.horizontal, 2)
                        }
                    } else {
                        ZStack{
                            Rectangle()
                                .cornerRadius(2.5)
                                .frame(width: 40, height: 32)
                                .foregroundColor( .mainColor0.opacity(0.5))
                            Text("未設定")
                                .font(.system(size: 8))
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 36)
                                .padding(.horizontal, 2)
                        }
                    }
                }
            }
            
            HStack(spacing: 1) {
                Image(systemName: "clock")
                    .font(.system(size: 8))
                Text(studyData?.scheduledTime ?? "未設定")
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

            .padding(.bottom, 8)
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
                    ZStack{
                        Circle()
                            .fill(Color.lightblue1)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2) // 枠線
                            )
                        Image(systemName: "chevron.left")
                            .bold()
                    }
                }
            
                Spacer()
                
                Button(action: {
                    currentMonth = CalendarUtils.changeMonth(currentMonth: currentMonth, by: 1)
                }) {
                    ZStack{
                        Circle()
                            .fill(Color.lightblue1)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2) // 枠線
                            )
                        Image(systemName: "chevron.right")
                            .bold()
                    }

                }
            }
            .padding(.horizontal)

            .padding(.bottom, 14)
            .padding()
        }
    }
