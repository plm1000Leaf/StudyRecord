
//  ShereView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/06/16.
//

import SwiftUI
import CoreData
import UIKit
import Social


struct ShareView: View {
    @EnvironmentObject private var snapshotManager: SnapshotManager
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var recordService = DailyRecordService.shared
    
    @Binding var isTapShareButton: Bool
    
    let screenshot: UIImage?
    var fromAfterCheck: Bool = false
    var materialText: String? = nil
    var monthlySummary: String? = nil
    var continuationDays: Int? = nil
    
    var body: some View {
        ZStack{
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 56){
                Button(action: {
                    isTapShareButton = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .padding(32)
                        
                        .padding(.bottom, -56)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                screenShot
                shareButton
            }
        
        }
    }
    
}

extension ShareView{
    private var screenShot: some View {
        Group {
            if fromAfterCheck {
                VStack(spacing: 16) {
                    HStack{
                        Image(systemName:"book")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        Text("教材")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }

                    
                    Text(materialText ?? "")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                    
                    Spacer()
                        .frame(height:24)
                    
                    if let days = continuationDays {
                        HStack{
                            Image(systemName:"leaf")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            Text("継続日数")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                            }

                        
                        Text("\(days)日")
                            .font(.system(size: 48))
                            .foregroundColor(.white)
                            .padding(.leading, 8)

                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.mainColor0)
            } else if let screenshot = screenshot {
                VStack(spacing: 8) {
                    Image(uiImage: screenshot)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            } else {
                Rectangle()
            }
        }
        .frame(width:312,height:400)
    }
    
    private var shareButton: some View {
        HStack(spacing: 24){
            Button(action: shareToX) {
                
                ZStack{
                    Rectangle()
                        .cornerRadius(16)
                        .frame(width:88,height:88)
                        .foregroundColor(.black)
                    Text("X")
                        .bold()
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
            }
            
            Button(action: shareToGeneral) {
                ZStack{
                    Rectangle()
                        .cornerRadius(16)
                        .frame(width:88,height:88)
                        .foregroundColor(.gray)
                    Image(systemName:"ellipsis")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
            }
            
        }
        .padding(.bottom, 40)
    }
    
    private func snapshot(size: CGSize) -> UIImage {
        // UIHostingController に載せ替え
        let controller = UIHostingController(rootView: self)
        // レンダリング用の View
        let view = controller.view!

        // サイズを指定
        view.bounds = CGRect(origin: .zero, size: size)
        view.backgroundColor = .clear

        // レンダリング
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
    
    private func shareToX() {
        let material = materialText ?? ""
        let summary = monthlySummary ?? ""
        let daysText = continuationDays.map { "\($0)日" } ?? ""
        let shareTodayRecord = "今日の教材: \(material)\n今月の学習回数: \(summary)\n継続日数: \(daysText)"
        let shareContinuationDays = " \(daysText)継続して学習しています"
        if fromAfterCheck {
            if let composeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter),
               let topVC = UIApplication.topViewController() {
                composeVC.setInitialText(shareTodayRecord)
                topVC.present(composeVC, animated: true)
            }
        } else if let img = screenshot {
            if let composeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter),
               let topVC = UIApplication.topViewController() {
                composeVC.setInitialText("今日の学習記録をシェアします")
                composeVC.setInitialText(shareContinuationDays)
                composeVC.add(img)
                topVC.present(composeVC, animated: true)
            }
        }
    }
    
    private func shareToGeneral() {
        let textContent: String = {
            guard fromAfterCheck else { return "今日の学習記録をシェアします" }
            let material = materialText ?? ""
            let summary = monthlySummary ?? ""
            let daysText = continuationDays.map { "\($0)日" } ?? ""
            return """
            今日の教材: \(material)
            今月の学習回数: \(summary)
            継続日数: \(daysText)
            """
        }()
        if fromAfterCheck {
                if let url = URL(string: "line://msg/text/\(textContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else if let topVC = UIApplication.topViewController() {
                    let activityVC = UIActivityViewController(activityItems: [textContent], applicationActivities: nil)
                    activityVC.excludedActivityTypes = [.postToTwitter, .postToFacebook, .mail, .message]
                    
                    if let pop = activityVC.popoverPresentationController {
                        pop.sourceView = topVC.view
                        pop.sourceRect = CGRect(
                            x: topVC.view.bounds.midX,
                            y: topVC.view.bounds.midY,
                            width: 0,
                            height: 0
                        )
                        pop.permittedArrowDirections = []
                    }
                    
                    DispatchQueue.main.async {
                        topVC.present(activityVC, animated: true, completion: nil)
                    }
                }
            } else if let img = screenshot, let topVC = UIApplication.topViewController() {
                let activityVC = UIActivityViewController(activityItems: [img], applicationActivities: nil)
                activityVC.excludedActivityTypes = [.postToTwitter, .postToFacebook, .postToWeibo]
                
                if let pop = activityVC.popoverPresentationController {
                    pop.sourceView = topVC.view
                    pop.sourceRect = CGRect(
                        x: topVC.view.bounds.midX,
                        y: topVC.view.bounds.midY,
                        width: 0,
                        height: 0
                    )
                    pop.permittedArrowDirections = []
                }
                
                DispatchQueue.main.async {
                    topVC.present(activityVC, animated: true, completion: nil)
                }
            }
    }
    
}

extension UIApplication {
    static func topViewController(
        _ base: UIViewController? = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows.first(where: { $0.isKeyWindow })?
            .rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

//#Preview {
//    ShareView(isTapShareButton: $isTapShareButton)
//}
