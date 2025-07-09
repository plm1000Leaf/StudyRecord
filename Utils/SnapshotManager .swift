//
//  SnapshotManager .swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/06/20.
//

import SwiftUI
import UIKit


final class SnapshotManager: ObservableObject {
    @Published var image: UIImage? = nil

    /// 指定した幅で中身にあわせた高さを計測し、縦長でもすべて含むスクショを取得
    func captureFull<Content: View>(
        _ view: Content,
        fixedWidth: CGFloat
    ) {
        let controller = UIHostingController(rootView: view)
        // 幅を固定して、高さは無限大まで測れるように
        let targetSize = controller.sizeThatFits(
            in: CGSize(width: fixedWidth, height: .greatestFiniteMagnitude)
        )
        controller.view.bounds = CGRect(origin: .zero, size: targetSize)
        controller.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let img = renderer.image { _ in
            controller.view.drawHierarchy(
                in: controller.view.bounds,
                afterScreenUpdates: true
            )
        }

        DispatchQueue.main.async {
            self.image = img
        }
    }
}
