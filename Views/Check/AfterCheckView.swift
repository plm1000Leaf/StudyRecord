

import SwiftUI
import CoreData

struct AfterCheckView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var recordService = DailyRecordService.shared
    
    @Binding var isDoneStudy: Bool
    @Binding var selectedTabIndex: Int
    @Binding var navigateToReview: Bool
    @Binding var navigateToPlan: Bool
    
    @State private var continuationDays: Int = 0
    @State private var isTapShareButton = false
    @State private var shareMaterialText: String = ""
    @State private var shareMonthlySummary: String = ""
    @State private var shareContinuationDays: Int = 0
    @State private var showCancelCheckAlert = false
    
    var dismiss: () -> Void
    

    var body: some View {
        ZStack {
            afterCheckView
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color.baseColor0)

            if isTapShareButton {
                ShareView(
                    isTapShareButton: $isTapShareButton, 
                    screenshot: nil,
                    fromAfterCheck: true,
                    materialText: shareMaterialText,
                    monthlySummary: shareMonthlySummary,
                    continuationDays: shareContinuationDays 
                )
            }
        }
        .onAppear {
            loadContinuationDays()
        }
    }
}

extension AfterCheckView {
    
    private var afterCheckView: some View {
        VStack(spacing: 80){
            HStack{
                checkViewTitle
                cancelCheckButton
            }
            studyDoneText
            continuationDaysView
            openShareScreenButton
            transitionScreenButton
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarBackButtonHidden(true)
        .background(Color.baseColor0)
        .alert("チェックを取り消し", isPresented: $showCancelCheckAlert) {
            
            Button("取り消し", role: .destructive) {
                recordService.updateIsChecked(false, context: viewContext)
                isDoneStudy = false
                dismiss()
            }
            
            Button("キャンセル", role: .cancel) {
            }
            
        } message: {
            Text("Doneボタンを押し間違えた場合\n取り消すことができます")
        }
    }
    
    private var checkViewTitle: some View {
        Text("今日の学習")
            .font(.system(size: 32))
            .padding(.top, 48)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var studyDoneText: some View {
        Text("学習完了")
            .font(.system(size: 72))
            .accessibilityIdentifier("afterCheckCompletionTitle")
    }
    
    private var continuationDaysView: some View {
        VStack{
            Text("継続日数")
                .font(.system(size: 48))
            Text("\(continuationDays)日")
                .font(.system(size: 48))
        }
        .padding(.bottom, -64)
    }
    
    private var openShareScreenButton: some View {
        
        HStack{
            Spacer()
            Button(action: {
                prepareShareTexts()
                isTapShareButton = true
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 40))
            }
        }
    }
    
    private var cancelCheckButton: some View {
        Button(action: {
            showCancelCheckAlert = true
        }) {
            Image(systemName: "return")
                .font(.system(size: 32))
        }
    }
    

    private var transitionScreenButton: some View {
        HStack(spacing: 56){
            
            Button(action: {
                selectedTabIndex = 0
                navigateToReview = true
                dismiss()
                print("振り返るボタンが押されました")
            }) {
                BasicButton(label: "振り返る", width: 144, height: 72, fontSize: 24)
            }

            Button(action: {
                selectedTabIndex = 2
                navigateToPlan = true
                dismiss()
            }){
                BasicButton(label: "明日の予定", width: 144, height: 72, fontSize: 24)
            }
        }
    }
    
    // MARK: - Methods
    
    private func loadContinuationDays() {
        continuationDays = recordService.calculateContinuationDays(from: Date(), context: viewContext)
    }
    
    private func prepareShareTexts() {
        shareMaterialText = recordService.getMaterial()?.name ?? "未設定"

        let now = Date()
        let year = Calendar.current.component(.year, from: now)
        let month = Calendar.current.component(.month, from: now)
        let count = MonthlyRecordManager.shared.fetchRecord(for: year, month: month, context: viewContext)?.checkCount ?? 0
        shareMonthlySummary =  "\(count)日"
        shareContinuationDays = continuationDays
    }
}

#Preview {
    AfterCheckView(
        isDoneStudy: .constant(true),
        selectedTabIndex: .constant(1),
        navigateToReview: .constant(false),
        navigateToPlan: .constant(false),
        dismiss: {}
    )
    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
