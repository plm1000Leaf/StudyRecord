
// MainTabView.swift - 修正版

//
//  TabView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/27.
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedTabIndex: Int
    @Binding var navigateToReview: Bool
    @Binding var navigateToPlan: Bool
    
    // 明日の予定専用のフラグを追加
    @State private var openTomorrowPlan = false
    
    var body: some View {
        TabView(selection: $selectedTabIndex){
            YearReviewView(showDateReviewView: $navigateToReview)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Review")
                }
                .tag(0)
            
            BeforeCheckView(
                selectedTabIndex: $selectedTabIndex,
                navigateToReview: $navigateToReview,
                navigateToPlan: $navigateToPlan,
                selectedDate: Calendar.current.startOfDay(for: Date())
            )
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Check")
                }
                .tag(1)
            
            StudyPlanView(
                openPlanSettingOnAppear: navigateToPlan && !openTomorrowPlan,
                openTomorrowPlan: openTomorrowPlan
            )
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Study Plan")
                }
                .tag(2)
        }
        .onChange(of: selectedTabIndex) { newIndex in
            // タブ2（Study Plan）に遷移した時の処理
            if newIndex == 2 && navigateToPlan {
                // AfterCheckViewからの明日の予定遷移かどうかを判定
                openTomorrowPlan = true
                
                // フラグをリセット
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    navigateToPlan = false
                    openTomorrowPlan = false
                }
            }
        }
    }
}

struct HomeView: View {
    var body: some View {
        Text("ホーム画面")
    }
}

struct ProfileView: View {
    var body: some View {
        Text("プロフィール画面")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("設定画面")
    }
}
