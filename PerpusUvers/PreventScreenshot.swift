//
//  PreventScreenshot.swift
//  PerpusUvers
//
//  Created by Erwin on 05/04/24.
//

import SwiftUI
import UIKit

public final class ScreenshotPreventingView: UIView {

    private var contentView: UIView?
    private let textField = UITextField()

    public var preventScreenCapture = true {
        didSet {
            textField.isSecureTextEntry = preventScreenCapture
        }
    }

    public override var isUserInteractionEnabled: Bool {
        didSet {
            secureViewContainer?.isUserInteractionEnabled = isUserInteractionEnabled
        }
    }

    private lazy var secureViewContainer: UIView? = try? getSecureContainer()

    func getSecureContainer() throws -> UIView? {
        return textField.subviews.filter { subview in
            type(of: subview).description() == "_UITextLayoutCanvasView"
        }.first
    }
    
    public init(contentView: UIView? = nil) {
        self.contentView = contentView
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func setupUI() {
        textField.backgroundColor = .clear
        textField.isUserInteractionEnabled = false

        guard let viewContainer = secureViewContainer else { return }
        
        addSubview(viewContainer)
        viewContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            viewContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            viewContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            viewContainer.topAnchor.constraint(equalTo: topAnchor),
            viewContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    public func setup(contentView: UIView) {
        self.contentView?.removeFromSuperview()
        self.contentView = contentView

        guard let viewContainer = secureViewContainer else { return }

        viewContainer.addSubview(contentView)
        viewContainer.isUserInteractionEnabled = isUserInteractionEnabled
        contentView.translatesAutoresizingMaskIntoConstraints = false

        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor)
        bottomConstraint.priority = .required - 1

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: viewContainer.topAnchor),
            bottomConstraint
        ])
    }
}

struct SecureView<Content: View>: UIViewControllerRepresentable {

    private var preventScreenCapture: Bool
    private let content: () -> Content

    init(preventScreenCapture: Bool, @ViewBuilder content: @escaping () -> Content) {
        self.preventScreenCapture = preventScreenCapture
        self.content = content
    }

    func makeUIViewController(context: Context) -> SecureViewHostingViewController<Content> {
        SecureViewHostingViewController(preventScreenCapture: preventScreenCapture, content: content)
    }

    func updateUIViewController(_ uiViewController: SecureViewHostingViewController<Content>, context: Context) {
        uiViewController.preventScreenCapture = preventScreenCapture
    }
}

final class SecureViewHostingViewController<Content: View>: UIViewController {

    private let content: () -> Content
    
    private let secureView = ScreenshotPreventingView()

    var preventScreenCapture: Bool = true {
        didSet {
            secureView.preventScreenCapture = preventScreenCapture
        }
    }

    init(preventScreenCapture: Bool, @ViewBuilder content: @escaping () -> Content) {
        self.preventScreenCapture = preventScreenCapture
        self.content = content
        super.init(nibName: nil, bundle: nil)

        setupUI()
        secureView.preventScreenCapture = preventScreenCapture
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        view.addSubview(secureView)
        secureView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secureView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            secureView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            secureView.topAnchor.constraint(equalTo: view.topAnchor),
            secureView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        let hostVC = UIHostingController(rootView: content())
        hostVC.view.translatesAutoresizingMaskIntoConstraints = false

        addChild(hostVC)
        secureView.setup(contentView: hostVC.view)
        hostVC.didMove(toParent: self)
    }
}

public struct PreventScreenshot: ViewModifier {
    public let isProtected: Bool

    public func body(content: Content) -> some View {
        SecureView(preventScreenCapture: isProtected) {
            content
        }
    }
}

public extension View {
    func screenshotProtected(isProtected: Bool) -> some View {
        modifier(PreventScreenshot(isProtected: isProtected))
    }
}
