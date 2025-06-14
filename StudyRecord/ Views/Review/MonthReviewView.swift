//
//  MonthReviewView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/25.
//

import SwiftUI

struct MonthReviewView: View {
    @State private var showDateReviewView = false
    @State private var selectedDateFromCalendar: Int? = nil
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
                }
            )

            
        }
        .background(Color.baseColor0)
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
