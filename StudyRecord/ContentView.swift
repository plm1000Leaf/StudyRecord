//
//  ContentView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/18.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTabIndex = 1
    @State private var navigateToReview = false
    @State private var navigateToPlan = false
    @State private var showAfterCheckView = true
    var body: some View {
        ZStack {
            MainTabView(
                selectedTabIndex: $selectedTabIndex,
                navigateToReview: $navigateToReview,
                navigateToPlan: $navigateToReview
            )

        }
    }
    }


#Preview {
    MainTabView(selectedTabIndex: .constant(1), navigateToReview: .constant(true), navigateToPlan: .constant(true))
}
