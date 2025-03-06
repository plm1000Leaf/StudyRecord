//
//  MonthReviewView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/25.
//

import SwiftUI

struct MonthReviewView: View {

    var body: some View {
            VStack{

                DateReviewHeader
                MonthReviewCalendar()
                Spacer()
                
            }

        }
    }

#Preview {
    MonthReviewView()
}

extension MonthReviewView {
    private var DateReviewHeader: some View {

            HStack{
  
                        HStack{
                            Image(systemName: "chevron.left")
                            Text("年")
                        }

                Spacer()
                
            }
            .padding(.leading, 28)
            .padding(.bottom, 40)
        }

}

#Preview {
   MonthReviewView()
}
