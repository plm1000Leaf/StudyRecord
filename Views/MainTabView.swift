
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
    
    @State private var openTomorrowPlan = false
    
    var body: some View {
        TabView(selection: $selectedTabIndex){
            YearReviewView(showDateReviewView: $navigateToReview)
                .tabItem {
                    Image(systemName: "rectangle.grid.2x2.fill")
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
                    Image(systemName: "checkmark")
                    Text("Check")
                }
                .tag(1)
            
            StudyPlanView(
                openPlanSettingOnAppear: navigateToPlan && !openTomorrowPlan,
                openTomorrowPlan: openTomorrowPlan
            )
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Plan")
                }
                .tag(2)
        }
        .tint(.mainColor0)
        .onChange(of: selectedTabIndex) { newIndex in
            if newIndex == 2 && navigateToPlan {
                // AfterCheckViewからの明日の予定遷移かどうかを判定
                openTomorrowPlan = true
                
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
