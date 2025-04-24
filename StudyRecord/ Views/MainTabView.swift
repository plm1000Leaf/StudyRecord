//
//  TabView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/27.
//

import SwiftUI

struct MainTabView: View {
//    var selectedTab: Int
    @State private var selectedTab = 1
    @State private var selectedSegment = 0
    
    var body: some View {
        TabView(selection: $selectedTab){
            YearReviewView(selectedSegment: $selectedSegment)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Review")
                }
                .tag(0)
            
            BeforeCheckView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Check")
                }
                .tag(1)
            
            StudyPlanView()
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


#Preview {
    MainTabView()
}


