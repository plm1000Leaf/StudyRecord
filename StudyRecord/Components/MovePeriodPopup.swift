//
//  MovePeriodPopup.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/03/26.
//

import SwiftUI

struct MovePeriodPopup: View {
    @Binding var showPopup: Bool
    let items: [String]

    var body: some View {
        ZStack {

            if showPopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showPopup = false
                    }

                selectPeriodField
//                .background(Color.white)
//                .cornerRadius(12)
//                .shadow(radius: 10)
            }
        }
        .animation(.easeInOut, value: showPopup)
    }
}


#Preview {
    MovePeriodPopup(showPopup: .constant(true), items: (2020...2031).map { "\($0)" })
}

extension MovePeriodPopup {
    private var selectPeriodField: some View {
        VStack(spacing: 20) {
            ZStack{
                Rectangle()
                    .frame(width: 360, height: 360)
                    .foregroundColor(.white)
                VStack {
                    ForEach(0..<4) { rowIndex in
                        HStack{
                            ForEach(0..<3) { columnIndex in
                                let index = rowIndex * 3 + columnIndex
                                if index < items.count {
                                    ZStack{
                                        Rectangle()
                                            .frame(width:104, height: 72)
                                            .padding(.bottom, 8)
                                        Text(items[index])
                                            .foregroundColor(.blue)
                                    }
                                } else {
                                    Rectangle()
                                        .frame(width: 104, height: 72)
                                        .opacity(0)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}
