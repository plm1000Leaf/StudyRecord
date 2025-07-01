
import UIKit

struct ScreenshotHelper {
    static func captureScreen() -> UIImage? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        return renderer.image { context in
            window.layer.render(in: context.cgContext)
        }
    }
}
