import SwiftUI
import UIKit

public struct ToSwiftUI<Controller: UIViewController>: UIViewControllerRepresentable {
    let controller: () -> Controller

    public init(controller: @escaping () -> Controller) {
        self.controller = controller
    }

    public func makeUIViewController(context: Context) -> Controller {
        controller()
    }

    public func updateUIViewController(_ uiViewController: Controller, context: Context) {}
}
