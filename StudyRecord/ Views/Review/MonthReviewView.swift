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
                Rectangle()
                    .frame(width: 336, height: 352)

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
                VStack{
  
                        HStack{
                            Image(systemName: "chevron.left")
                            Text("年")
                        }
                    
                    HStack(alignment: .bottom){
                        Text("2025")
                            .font(.system(size: 16))
                            .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
                        
                        Text("1")
                            .font(.system(size: 48))
                            .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
                    }
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
