//
//  TabView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/27.
//

import SwiftUI

struct MainTabView: View {
    @Binding var selectedTabIndex: Int

    @Binding var navigateToReview: Bool
    @Binding var navigateToPlan: Bool
    
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
                navigateToPlan: $navigateToPlan, selectedDate: Calendar.current.startOfDay(for: Date())
            )
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Check")
                }
                .tag(1)
            
            StudyPlanView(openPlanSettingOnAppear: navigateToPlan)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Study Plan")
                }
                .tag(2)
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


//#Preview {
//    MainTabView(selectedTab: <#Int#>, openDateReview: <#Binding<Bool>#>, openPlanSetting: <#Binding<Bool>#>)
//}


