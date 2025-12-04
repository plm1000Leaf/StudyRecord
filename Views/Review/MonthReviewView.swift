//
//  MonthReviewView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/25.
//

import SwiftUI
import UIKit

struct MonthReviewView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var snapshotManager: SnapshotManager
    @StateObject private var recordService = DailyRecordService.shared
    @State private var showDateReviewView = false
    @State private var selectedDateFromCalendar: Int? = nil
    @State private var isTapShareButton = false
    @State private var shareImage: UIImage? = nil
    @State private var captureRect: CGRect = .zero
    @State private var continuationDays: Int = 0
    @State private var shareMaterialText: String = ""
    @State private var shareMonthlySummary: String = ""
    @State private var shareContinuationDays: Int = 0
    @Binding var showMonthReviewView: Bool
    @Binding var currentMonth: Date
    var body: some View {
        ZStack {
            if !showDateReviewView {
                monthView
                    .zIndex(0)
                    .transition(.move(edge: .leading))
            } else {
                DateReviewView(showDateReviewView: $showDateReviewView,
                               currentMonth: $currentMonth,
                               reviewText: .constant(""),
                               selectedDateFromMonthReview: selectedDateFromCalendar,
                               isFromAfterCheck: false
                               
                )
                .zIndex(1)
                .transition(.move(edge: .trailing))
            }

            if isTapShareButton {
                ShareView(
                    isTapShareButton: $isTapShareButton,
                    screenshot: shareImage,
                    materialText: shareMaterialText,
                    monthlySummary: shareMonthlySummary,
                    continuationDays: shareContinuationDays
                )
        
            }
            
        }
        .onAppear{
            continuationDays = recordService.calculateContinuationDays(from: Date(), context: viewContext)
        }
        .animation(.easeInOut, value: showDateReviewView)
        .background(Color.baseColor0.edgesIgnoringSafeArea(.all))
        }
    }



extension MonthReviewView {
    private var monthView: some View {
        VStack{

            DateReviewHeader
            MonthReviewCalendar(
                currentMonth: .constant(currentMonth),
                showDateReviewView:$showDateReviewView,
                onDateSelected: { selectedDay in
                selectedDateFromCalendar = selectedDay
                },
                onShareTapped: captureScreenshot
            )
            
        }
        .background(
            GeometryReader { geo -> Color in
                DispatchQueue.main.async {
                    let frame = geo.frame(in: .global)

                    let adjusted = frame.insetBy(dx: 1, dy: 20)

                    captureRect = adjusted
                }
                return Color.clear
            }
        )

        .background(Color.baseColor0)
    }
    
    private func captureScreenshot() {
        shareImage = ScreenshotHelper.captureScreen(in: captureRect)
        prepareShareTexts()
        isTapShareButton = true
    }
    
    
    
    private var DateReviewHeader: some View {

            HStack{
                Button(action: {
                    withAnimation {
                        showMonthReviewView = false  // YearReviewView に戻る
                    }
                }) {
                    HStack{
                        Image(systemName: "chevron.left")
                        Text("年")
                    }
                    .foregroundColor(.gray30)
                }

                Spacer()
                
            }
            .padding(.leading, 28)
            .padding(.bottom, -40)
        }

}

//#Preview {
//
//let controller = PersistenceController.preview
//        return     MonthReviewView(showMonthReviewView: .constant(true), currentMonth: $currentMonth)
//        .environment(\.managedObjectContext, controller.container.viewContext)
//    
//}

extension MonthReviewView {
    private func prepareShareTexts() {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: currentMonth)
        let month = calendar.component(.month, from: currentMonth)

        let checkCount = recordService.getCheckedCountForMonth(currentMonth, context: viewContext)
        let mostUsedMaterial = recordService.getMostUsedMaterialName(for: currentMonth, context: viewContext) ?? "未設定"

        shareMaterialText = mostUsedMaterial
        shareMonthlySummary = "\(year)年\(month)月は\(checkCount)日取り組みました\n \(mostUsedMaterial)を主に取り組みました"
        shareContinuationDays = continuationDays
    }
}


#Preview {
    // Preview 用のスタブ
    let controller = PersistenceController.preview
    @State var showMonth = true
    @State var month = Date()

    return MonthReviewView(
        showMonthReviewView: $showMonth,
        currentMonth: $month
    )
    .environment(\.managedObjectContext, controller.container.viewContext)
    .environmentObject(SnapshotManager()) // ← 必要ならモックでもOK
}
