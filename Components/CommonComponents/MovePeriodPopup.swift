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
    let onSelect: (Int) -> Void

    var body: some View {
        ZStack {

            if showPopup {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showPopup = false
                    }

                selectPeriodField


            }
        }
        .animation(.easeInOut, value: showPopup)
    }
}


//#Preview {
//    MovePeriodPopup(showPopup: .constant(true), items: (2020...2031).map { "\($0)" })
//}

extension MovePeriodPopup {
    private var selectPeriodField: some View {
        VStack(spacing: 20) {
            ZStack{
                Rectangle()
                    .frame(width: 360, height: 360)
                    .foregroundColor(.baseColor0)
                    .cornerRadius(12)
                VStack {
                    ForEach(0..<4) { rowIndex in
                        HStack{
                            ForEach(0..<3) { columnIndex in
                                let index = rowIndex * 3 + columnIndex
                                if index < items.count {
                                    ZStack{
                                        Rectangle()
                                            .cornerRadius(8)
                                            .frame(width:104, height: 72)
                                            .foregroundColor(.mainColor10)


                                        Text(items[index])
                                            .onTapGesture {
                                                if let month = Int(items[index]) {
                                                    onSelect(month)
                                                    showPopup = false
                                                }
                                                if let year = Int(items[index]) {
                                                    onSelect(year)
                                                    showPopup = false
                                                }
                                            }
                                            .font(.system(size: 24))
                                            .foregroundColor(.white)
                                        
                                        
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
