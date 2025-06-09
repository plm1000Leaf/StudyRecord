import SwiftUI
import CoreData

struct DateReviewView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var recordService = DailyRecordService.shared
    @State private var selectedRowIndex: Int? = nil
    @State private var isTapEditButton = false
    @State private var userInput: String = ""
    @State private var reviews: [Int: String] = [:]
    @State private var materialNames: [Int: String] = [:]
    @State private var materialImages: [Int: UIImage] = [:]
    @State private var checkedDates: [Int: Bool] = [:]
    @Binding var showDateReviewView: Bool
    @Binding var currentMonth: Date 
    @Binding var reviewText: String

  
    
    var body: some View {
            VStack{

                DateReviewHeader
                
                ScrollView {
                    let numberOfDaysInMonth = Calendar.current.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
                    ForEach(0..<numberOfDaysInMonth, id: \.self){ index in
                        Group {
                            if selectedRowIndex == index {
                                    SelectReview(index: index)

                            } else {
                                DateReviewRow(index: index)
                                    .onTapGesture {
                                        selectedRowIndex = index
                                    }
                            }
                        }
                    }
                }
            }
            .background(Color.baseColor0)
            .onAppear {
                loadCheckedDates()
            }
            .onChange(of: currentMonth) { _ in
                loadCheckedDates()
            }

    }
    
}


extension DateReviewView {
    private func DateReviewRow(index: Int) -> some View {
        guard let (day, weekday) = CalendarUtils.dayAndWeekday(at: index, from: currentMonth) else {
            return AnyView(EmptyView())
        }
        let isChecked = checkedDates[day] ?? false
        let backgroundColor = isChecked ? Color.mainColor10 : Color.notCheckedColor20
        let frameColor = isChecked ? Color.mainColor0 : Color.notCheckedColor10
        let textColor = isChecked ? Color.baseColor10 : Color.gray0
        return AnyView(
            HStack(alignment: .top, spacing: 32) {
                VStack(alignment: .trailing) {
                    Text("\(day)")
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
        guard let date = Calendar.current.date(byAdding: .day, value: index, to: startOfMonth(currentMonth)) else {
            fatalError("日付取得に失敗")
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
        guard let (day, weekday) = CalendarUtils.dayAndWeekday(at: index, from: currentMonth) else {
            return AnyView(EmptyView())
        }
        
        let dailyRecord = record(for: index)
        let startPageText = dailyRecord.startPage ?? "-"
        let startUnitText = dailyRecord.startUnit ?? "-"
        let endPageText = dailyRecord.endPage ?? "-"
        let endUnitText = dailyRecord.endUnit ?? "-"
        
        let isChecked = checkedDates[day] ?? false
        let backgroundColor = isChecked ? Color.mainColor20 : Color.notCheckedColor20
        let frameColor = isChecked ? Color.mainColor0 : Color.notCheckedColor10
        
        return AnyView(
            HStack(alignment: .top, spacing: 32) {
                VStack(alignment: .trailing) {
                    Text("\(day)")
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
                            Rectangle()
                                .frame(width: 88, height:  120)
                                .foregroundColor(.mainColor0)
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

