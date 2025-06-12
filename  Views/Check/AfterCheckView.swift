

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
    
    var dismiss: () -> Void

    var body: some View {
        afterCheckView
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.baseColor0)
            .onAppear {
                loadContinuationDays()
            }
    }
}

extension AfterCheckView {
    
    private var afterCheckView: some View {
        VStack(spacing: 80){
            checkViewTitle
            studyDoneText
            continuationDaysView
            shareButton
            checkButton
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarBackButtonHidden(true)
        .background(Color.baseColor0)
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
    
    private var shareButton: some View {
        Image(systemName: "square.and.arrow.up")
            .font(.system(size: 40))
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    private var checkButton: some View {
        HStack(spacing: 56){
            BasicButton(label: "振り返る", width: 144, height: 72, fontSize: 24){
                selectedTabIndex = 0
                navigateToReview = true
                dismiss()
                print("振り返るボタンが押されました")
            }
            
            BasicButton(label: "明日の予定", width: 144, height: 72, fontSize: 24){
                selectedTabIndex = 2
                navigateToPlan = true
                dismiss()
            }
        }
    }
    
    // MARK: - Methods
    
    private func loadContinuationDays() {
        continuationDays = recordService.calculateContinuationDays(context: viewContext)
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
