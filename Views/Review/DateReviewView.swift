
import SwiftUI
import CoreData

struct DateReviewView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var recordService = DailyRecordService.shared
    @State private var selectedRowIndex: Int? = nil
    @State private var isTapEditButton = false
    @State private var userInput: String = ""
    @State private var isTapShareButton = false
    @State private var reviews: [Int: String] = [:]
    @State private var materialNames: [Int: String] = [:]
    @State private var materialImages: [Int: UIImage] = [:]
    @State private var checkedDates: [Int: Bool] = [:]
    @Binding var showDateReviewView: Bool
    @Binding var currentMonth: Date
    @Binding var reviewText: String
    
    // MonthReviewViewから選択された日付を受け取るパラメータ
    var selectedDateFromMonthReview: Int? = nil
    // AfterCheckViewからの遷移かどうかのフラグ
    var isFromAfterCheck: Bool = false

    var body: some View {
        ZStack{
        VStack{
            DateReviewHeader
            
            ScrollViewReader { proxy in
                ScrollView {
                    let numberOfDaysInMonth = Calendar.current.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
                    ForEach(0..<numberOfDaysInMonth, id: \.self){ index in
                        Group {
                            if selectedRowIndex == index {
                                SelectReview(index: index)
                                    .id("day-\(index)")
                            } else {
                                DateReviewRow(index: index)
                                    .id("day-\(index)")
                                    .onTapGesture {
                                        selectedRowIndex = index
                                    }
                            }
                        }
                    }
                }
                .onAppear {
                    setupInitialState(proxy: proxy)
                }
                .onChange(of: currentMonth) { _ in
                    loadCheckedDates()
                    setupInitialState(proxy: proxy)
                }
            }
        }
        .background(Color.baseColor0)
    }
    }
    
    // MARK: - Private Methods
    
    private func setupInitialState(proxy: ScrollViewProxy) {
        loadCheckedDates()
        
        if isFromAfterCheck {
            // AfterCheckViewからの遷移：今日の日付を選択してスクロール
            let today = Date()
            let calendar = Calendar.current
            if calendar.isDate(today, equalTo: currentMonth, toGranularity: .month) {
                let todayDay = calendar.component(.day, from: today)
                let todayIndex = todayDay - 1
                selectedRowIndex = todayIndex
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo("day-\(todayIndex)", anchor: .center)
                    }
                }
            }
        } else if let selectedDay = selectedDateFromMonthReview {
            // MonthReviewViewからの遷移：選択された日付を使用
            let selectedIndex = selectedDay - 1 // 0ベースのインデックスに変換
            selectedRowIndex = selectedIndex
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    proxy.scrollTo("day-\(selectedIndex)", anchor: .center)
                }
            }
        }
    }
}


extension DateReviewView {
    private func DateReviewRow(index: Int) -> some View {
        // インデックスから実際の日付を計算（0ベース → 1ベース）
        let dayNumber = index + 1
        guard let (day, weekday) = CalendarUtils.dayAndWeekday(at: index, from: startOfMonth(currentMonth)) else {
            return AnyView(EmptyView())
        }
        
        // dayNumberを使用してチェック状態を確認
        let isChecked = checkedDates[dayNumber] ?? false
        let backgroundColor = isChecked ? Color.mainColor10 : Color.notCheckedColor20
        let frameColor = isChecked ? Color.mainColor0 : Color.notCheckedColor10
        let textColor = isChecked ? Color.baseColor10 : Color.gray0
        
        return AnyView(
            HStack(alignment: .top, spacing: 32) {
                VStack(alignment: .trailing) {
                    Text("\(dayNumber)")
                        .font(.system(size: 32))
                    Text("(\(weekday))")
                        .font(.system(size: 16))
                }
                .foregroundColor(.gray0)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backgroundColor)
                        .frame(width: 248, height: 88)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(frameColor, lineWidth: 4)
                        )
                    
                    VStack {
                        Text(reviews[index] ?? record(for: index).review ?? "")
                            .font(.system(size: 16))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(maxWidth: 240)
                            .padding(.bottom, 8) // 下部に少し余白
                    }
                    .frame(width: 248, height: 88)
                }
            }
            .padding(.bottom, 32)
        )
    }
    
    private var DateReviewHeader: some View {
        ZStack{
            Rectangle()
                .frame(width: 392, height: 88)
                .foregroundColor(.gray10)
            HStack{
                VStack(alignment: .leading){
                    
                    Button(action: {
                        withAnimation {
                            showDateReviewView = false  // MonthReviewView に戻る
                        }
                    }){
                        HStack{
                            Image(systemName: "chevron.left")
                            Text("月")
                        }
                    }
                    
                    HStack(alignment: .bottom){
                        Text(CalendarUtils.yearString(from: currentMonth))
                            .font(.system(size: 16))
                            .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
                        
                        Text(CalendarUtils.monthString(from: currentMonth))
                            .font(.system(size: 48))
                            .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
                    }
                }
                Spacer()
                
            }
            .padding(.leading, 28)
            .foregroundColor(.white)
        }
    }
    
    private func record(for index: Int) -> DailyRecord {
        // インデックスから正確な日付を計算
        let dayNumber = index + 1
        let calendar = Calendar.current
        let year = calendar.component(.year, from: currentMonth)
        let month = calendar.component(.month, from: currentMonth)
        
        guard let date = calendar.date(from: DateComponents(year: year, month: month, day: dayNumber)) else {
            fatalError("日付取得に失敗: \(year)年\(month)月\(dayNumber)日")
        }
        
        return DailyRecordManager.shared.fetchOrCreateRecord(for: date, context: viewContext)
    }
    
    private func startOfMonth(_ date: Date) -> Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date)) ?? Date()
    }
    
    private func loadCheckedDates() {
        checkedDates = recordService.loadCheckedDates(for: currentMonth, context: viewContext)
    }
    
    private func SelectReview(index: Int) -> some View {
        // インデックスから実際の日付を計算
        let dayNumber = index + 1
        guard let (day, weekday) = CalendarUtils.dayAndWeekday(at: index, from: startOfMonth(currentMonth)) else {
            return AnyView(EmptyView())
        }
        
        let dailyRecord = record(for: index)
        let startPageText = dailyRecord.startPage ?? "-"
        let startUnitText = dailyRecord.startUnit ?? "-"
        let endPageText = dailyRecord.endPage ?? "-"
        let endUnitText = dailyRecord.endUnit ?? "-"
        
        let isChecked = checkedDates[dayNumber] ?? false
        let backgroundColor = isChecked ? Color.mainColor20 : Color.notCheckedColor20
        let frameColor = isChecked ? Color.mainColor0 : Color.notCheckedColor10
        
        return AnyView(
            HStack(alignment: .top, spacing: 32) {
                VStack(alignment: .trailing) {
                    Text("\(dayNumber)")
                        .font(.system(size: 32))
                    Text("(\(weekday))")
                        .font(.system(size: 16))
                }
                .foregroundColor(.gray0)
                
                ZStack{
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 8)
                            .fill(backgroundColor)
                            .frame(width: 248, height: 288)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(frameColor, lineWidth: 4)
                            )
                    }
                    VStack{
                        HStack{
                        if let image = materialImages[index] {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 88, height: 120)
                                
                        } else {
                            ZStack{
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.notCheckedColor10)
                                    .frame(width: 88, height:  120)
                                Text("未設定")
                                    .bold()
                                    .font(.system(size: 16))
                                    .foregroundColor(.baseColor20)
                            }

                        }
                            
                            VStack(spacing: 8){
                                Text(materialNames[index] ?? record(for: index).material?.name ?? "教材未設定")
                                    .bold()
                                    .font(.system(size: 16))
                                    .frame(width: 104)
                                    .foregroundColor(.gray0)
                                
                                HStack{
                                    Text(startPageText)
                                        .font(.system(size: 8))
                                        .frame(width: 56, height: 16)
                                    Text(startUnitText)
                                        .font(.system(size: 12))
                                }
                                Text("〜")
                                    .font(.system(size: 16))
                                    .bold()
                                    .rotationEffect(.degrees(90))
                                HStack{
                                    Text(endPageText)
                                        .font(.system(size: 8))
                                        .frame(width: 56, height: 20)
                                    Text(endUnitText)
                                        .font(.system(size: 12))
                                }
                                
                            }
                            .foregroundColor(.gray0)
                        }
                        .padding(.top, 24)
                        
                        
                        InputReviewField(
                            dailyRecord: record(for: index),
                            reviewText: Binding(
                                get: { reviews[index] ?? (record(for: index).review ?? "") },
                                set: { reviews[index] = $0 }
                            )
                        )
                        .onAppear {
                            let dailyRecord = record(for: index)
                            materialNames[index] = record(for: index).material?.name ?? "教材未設定"
                            
                            if let data = dailyRecord.material?.imageData,
                               let uiImage = UIImage(data: data) {
                                materialImages[index] = uiImage
                            } else {
                                materialImages[index] = nil
                            }
                        }

                    }
                }
            }
                .padding(.bottom, 32)
        )
    }
}
