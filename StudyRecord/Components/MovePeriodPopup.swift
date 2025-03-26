//
//  MovePeriodPopup.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/03/26.
//

import SwiftUI

struct MovePeriodPopup: View {
    @Binding var showPopup: Bool

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
    MovePeriodPopup(showPopup: .constant(true))
}

extension MovePeriodPopup {
    private var selectPeriodField: some View {
        VStack(spacing: 20) {
            ZStack{
                Rectangle()
                    .frame(width: 360, height: 360)
                    .foregroundColor(.white)
                VStack {
                    ForEach(0..<4) { _ in
                        HStack{
                            ForEach(0..<3) { _ in
                                Rectangle()
                                    .frame(width:104, height: 72)
                                    .padding(.bottom, 8)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}
