import SwiftUI
import CoreData

struct DateReviewView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedRowIndex: Int? = nil
    @State private var isTapEditButton = false
    @State private var userInput: String = ""
    @State private var reviews: [Int: String] = [:]
    @State private var materialNames: [Int: String] = [:]
    @State private var materialImages: [Int: UIImage] = [:]
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
            
        

    }
    
}


extension DateReviewView {
    private func DateReviewRow(index: Int) -> some View {
        guard let (day, weekday) = CalendarUtils.dayAndWeekday(at: index, from: currentMonth) else {
            return AnyView(EmptyView())
        }
        
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
                        .fill(Color.mainColor10)
                        .frame(width: 248, height: 88)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.mainColor0, lineWidth: 4)
                        )
                    
                    Text(reviews[index] ?? record(for: index).review ?? "")
                        .font(.system(size: 12))
                        .foregroundColor(.gray0)
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
    private func SelectReview(index: Int) -> some View {
        guard let (day, weekday) = CalendarUtils.dayAndWeekday(at: index, from: currentMonth) else {
            return AnyView(EmptyView())
        }
        
        let dailyRecord = record(for: index)
        let startPageText = dailyRecord.startPage ?? "-"
        let startUnitText = dailyRecord.startUnit ?? "-"
        let endPageText = dailyRecord.endPage ?? "-"
        let endUnitText = dailyRecord.endUnit ?? "-"
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
                            .fill(Color.mainColor20)
                            .frame(width: 248, height: 288)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.mainColor0, lineWidth: 4)                             )
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
                                    .font(.system(size: 16))
                                    .frame(width: 104)
                                    .foregroundColor(.gray0)
                                
                                HStack{
                                    Text(startPageText)
                                        .font(.system(size: 12))
                                    Text(startUnitText)
                                        .font(.system(size: 12))
                                }
                                Text("〜")
                                    .font(.system(size: 16))
                                    .bold()
                                    .rotationEffect(.degrees(90))
                                HStack{
                                    Text(endPageText)
                                        .font(.system(size: 12))
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

