//
//  MonthReviewView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/25.
//

import SwiftUI
import UIKit

struct MonthReviewView: View {
    @State private var showDateReviewView = false
    @State private var selectedDateFromCalendar: Int? = nil
    @State private var isTapShareButton = false
    @State private var shareImage: UIImage? = nil
    @State private var captureRect: CGRect = .zero
    @Binding var showMonthReviewView: Bool
    @Binding var currentMonth: Date
    var body: some View {
        ZStack {
            if !showDateReviewView {
                monthView
                    .transition(.move(edge: .leading))
            } else {
                DateReviewView(showDateReviewView: $showDateReviewView,
                               currentMonth: $currentMonth,
                               reviewText: .constant(""),
                               selectedDateFromMonthReview: selectedDateFromCalendar,
                               isFromAfterCheck: false
                               
                )
                    .transition(.move(edge: .trailing))
            }

            if isTapShareButton {
                ShareView(
                    isTapShareButton: $isTapShareButton,
                    screenshot: shareImage
                )
        
            }
            
        }
        .animation(.easeInOut, value: showDateReviewView)

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
                DispatchQueue.main.async { captureRect = geo.frame(in: .global) }
                return Color.clear
            }
        )
        .background(Color.baseColor0)
    }
    
    private func captureScreenshot() {
        shareImage = ScreenshotHelper.captureScreen(in: captureRect)
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
//    MonthReviewView(showMonthReviewView: .constant(true), currentMonth: <#Date#>)
//}
