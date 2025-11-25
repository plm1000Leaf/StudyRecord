//
//  LabelSelectModal.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/11/25.
//

import SwiftUI

struct LabelAddModal: View{
    var body: some View {
        VStack{
            addLabelArea
        }
    }
}

extension LabelAddModal {

    
    private var addLabelArea: some View {
        HStack(spacing: 16){
            Rectangle()
                .frame(width: 256,height: 48)
            Circle()
                .frame(width: 40)
        }
    }
}
    


#Preview {
    LabelAddModal()
}
