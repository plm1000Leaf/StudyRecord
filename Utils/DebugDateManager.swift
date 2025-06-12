

//
//  DebugDateManager.swift
//  StudyRecord
//
//  Created by デバッグ機能 on 2025/06/09.
//

import Foundation
import SwiftUI

/// デバッグ用の日付管理クラス
class DebugDateManager: ObservableObject {
    static let shared = DebugDateManager()
    
    @Published private var debugDate: Date?
    
    private init() {}
    
    /// 現在の日付を取得（デバッグモードの場合はデバッグ日付を返す）
    var currentDate: Date {
        #if DEBUG
        return debugDate ?? Date()
        #else
        return Date()
        #endif
    }
    
    /// デバッグ用の日付を設定
    func setDebugDate(_ date: Date) {
        #if DEBUG
        debugDate = date
        print("🐛 デバッグ日付を設定: \(date.formatted(.dateTime.locale(.init(identifier: "ja_JP"))))")
        #endif
    }
    
    /// デバッグ日付をリセット（実際の日付に戻す）
    func resetToRealDate() {
        #if DEBUG
        debugDate = nil
        print("🐛 実際の日付に戻しました")
        #endif
    }
    
    /// 指定した日数だけ日付を進める/戻す
    func addDays(_ days: Int) {
        #if DEBUG
        let baseDate = debugDate ?? Date()
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: baseDate) {
            setDebugDate(newDate)
        }
        #endif
    }
    
    /// 明日に設定
    func setToTomorrow() {
        addDays(1)
    }
    
    /// 昨日に設定
    func setToYesterday() {
        addDays(-1)
    }
    
    /// 指定した日数前に設定
    func setDaysAgo(_ days: Int) {
        addDays(-days)
    }
    
    /// デバッグモードかどうか
    var isDebugMode: Bool {
        #if DEBUG
        return debugDate != nil
        #else
        return false
        #endif
    }
}

/// デバッグ用の日付選択ビュー
struct DebugDatePicker: View {
    @StateObject private var debugDateManager = DebugDateManager.shared
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    
    var body: some View {
        #if DEBUG
        VStack(spacing: 16) {
            Text("🐛 デバッグモード")
                .font(.headline)
                .foregroundColor(.red)
            
            if debugDateManager.isDebugMode {
                Text("現在のデバッグ日付:")
                Text(debugDateManager.currentDate.formatted(.dateTime.locale(.init(identifier: "ja_JP"))))
                    .font(.title2)
                    .padding()
                    .background(Color.yellow.opacity(0.3))
                    .cornerRadius(8)
            }
            
            HStack(spacing: 12) {
                Button("昨日") {
                    debugDateManager.setToYesterday()
                }
                .buttonStyle(.bordered)
                
                Button("今日") {
                    debugDateManager.resetToRealDate()
                }
                .buttonStyle(.bordered)
                
                Button("明日") {
                    debugDateManager.setToTomorrow()
                }
                .buttonStyle(.bordered)
            }
            
            HStack(spacing: 12) {
                Button("3日前") {
                    debugDateManager.setDaysAgo(3)
                }
                .buttonStyle(.bordered)
                
                Button("1週間前") {
                    debugDateManager.setDaysAgo(7)
                }
                .buttonStyle(.bordered)
                
                Button("1ヶ月前") {
                    debugDateManager.setDaysAgo(30)
                }
                .buttonStyle(.bordered)
            }
            
            Button("日付を選択") {
                showDatePicker = true
            }
            .buttonStyle(.borderedProminent)
            
            if debugDateManager.isDebugMode {
                Button("リセット") {
                    debugDateManager.resetToRealDate()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .sheet(isPresented: $showDatePicker) {
            NavigationView {
                DatePicker(
                    "デバッグ日付を選択",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .navigationTitle("日付選択")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("キャンセル") {
                            showDatePicker = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("決定") {
                            debugDateManager.setDebugDate(selectedDate)
                            showDatePicker = false
                        }
                    }
                }
            }
        }
        #endif
    }
}
