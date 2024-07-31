//
//  ChatPaidSubscriptionResultController.swift
//  _idx_Lib_ElloAppUI_30995A25_ios_min14.0
//
//

import Display
import UIKit
import AccountContext
import SwiftSignalKit
import ElloAppPresentationData
import AsyncDisplayKit
import ElloAppCore

// MARK: - SubscriptionChannelPriceController
public class ChatPaidSubscriptionResultController: ViewController {
    public enum Status {
        case success(ElloAppChannelPayType)
        case notEnoughMoney
        case error
        
        var image: UIImage? {
            switch self {
            case .success:
                return UIImage(bundleImageName: "Chat/Subscription/ChannelSubscribeSuccess")
            case .notEnoughMoney:
                return UIImage(bundleImageName: "Chat/Subscription/ChannelSubscribeOops")
            case .error:
                return UIImage(bundleImageName: "Chat/Subscription/ChannelSubscribeError")
            }
        }
        
        func title(with localizedStrings: PresentationStrings) -> String {
            switch self {
            case .success:
                return localizedStrings.ChatPaidSubscriptionResult_Title_Success
            case .notEnoughMoney:
                return localizedStrings.ChatPaidSubscriptionResult_Title_Oops
            case .error:
                return localizedStrings.ChatPaidSubscriptionResult_Title_Error
            }
        }
        
        func subtitle(with localizedStrings: PresentationStrings) -> String? {
            switch self {
            case .success(let type):
                switch type {
                case .subscription, .free:
                    return localizedStrings.ChatPaidSubscriptionResult_Subtitle_Success
                case .onlineCourse:
                    return localizedStrings.ChatCourseSubscriptionResult_Subtitle_Success
                }
            case .notEnoughMoney:
                return localizedStrings.ChatPaidSubscriptionResult_Subtitle_Oops
            case .error:
                return localizedStrings.ChatPaidSubscriptionResult_Subtitle_Error
            }
        }
    }
    
    private let context: AccountContext
    private var presentationData: PresentationData
    private let status: Status
    private lazy var localizedStrings: PresentationStrings = {
        presentationData.strings
    }()
    
    private var disposable = MetaDisposable()
    
    private let _back = Promise<Void>()
    var backSignal: Signal<Void, NoError> {
        _back.get()
    }
    
    public init(context: AccountContext, status: Status) {
        self.context = context
        self.presentationData = context.sharedContext.currentPresentationData.with { $0 }
        self.status = status
        
        let navigationBarPresentationData = NavigationBarPresentationData(
            theme: NavigationBarTheme(
                buttonColor: presentationData.theme.rootController.navigationBar.accentTextColor,
                disabledButtonColor: presentationData.theme.rootController.navigationBar.disabledButtonColor,
                primaryTextColor: presentationData.theme.rootController.navigationBar.primaryTextColor,
                backgroundColor: .clear,
                enableBackgroundBlur: false,
                separatorColor: .clear,
                badgeBackgroundColor: .clear,
                badgeStrokeColor: .clear,
                badgeTextColor: .clear
            ),
            strings: NavigationBarStrings(presentationStrings: presentationData.strings)
        )
        
        super.init(navigationBarPresentationData: navigationBarPresentationData)
        
        title = ""
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: presentationData.strings.Common_Back,
            style: .plain,
            target: nil,
            action: nil
        )
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func displayNodeDidLoad() {
        super.displayNodeDidLoad()
        
        let _ = backSignal.start { [weak self] _ in
            debugPrint("next")
            self?.dismiss()
        }
    }
    
    @objc private func nextPressed() {
        _back.set(.complete())
    }
    
    override public func loadDisplayNode() {
        displayNode = ChatPaidSubscriptionResultControllerNode(theme: presentationData.theme, status: status, localizedStrings: localizedStrings, backPromise: _back)
        displayNodeDidLoad()
    }
    
    override public func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        controllerNode.containerLayoutUpdated(
            layout,
            navigationBarHeight: navigationLayout(layout: layout).navigationFrame.maxY,
            transition: transition
        )
    }
    
    private var controllerNode: ChatPaidSubscriptionResultControllerNode {
        displayNode as! ChatPaidSubscriptionResultControllerNode
    }
}

public class ChatPaidSubscriptionResultControllerNode: ASDisplayNode {
    private var constraints: [NSLayoutConstraint] = []
    private let status: ChatPaidSubscriptionResultController.Status
    private let localizedStrings: PresentationStrings
    private let backPromise: Promise<Void>
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(bundleImageName: "Chat/Subscription/ChannelSubscribeSuccess")
        imageView.setContentHuggingPriority(.init(249), for: .vertical)
        imageView.setContentCompressionResistancePriority(.init(749), for: .vertical)
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: 0x070708)
        label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: 0x070708)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.cornerRadius = 10.0
        button.borderWidth = 1.0
        button.borderColor = UIColor(hex: 0xCFCFD2)
        button.setTitle(localizedStrings.Common_Back, for: .normal)
        button.backgroundColor = UIColor(hex: 0xFFFFFF)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(UIColor(hex: 0x070708), for: .normal)
        
        return button
    }()
    
    init(theme: PresentationTheme? = nil, status: ChatPaidSubscriptionResultController.Status, localizedStrings: PresentationStrings, backPromise: Promise<Void>) {
        self.status = status
        self.localizedStrings = localizedStrings
        self.backPromise = backPromise
        
        super.init()
        
        backgroundColor = .white
        view.disablesInteractiveTransitionGestureRecognizer = true
        
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(button)
        
        button.addAction { [weak self] in
            self?.backPromise.set(.single(Void()))
        }
    }
    
    public override func didLoad() {
        super.didLoad()
        
        imageView.image = status.image
        titleLabel.text = status.title(with: localizedStrings)
        subtitleLabel.text = status.subtitle(with: localizedStrings)
    }
    
    private func configureLayout(navigationBarHeight: CGFloat) {
        clearConstraints()
        
        let imageCenterYAnchor = view.centerYAnchor.constraint(equalTo: imageView.centerYAnchor, constant: 68)
        imageCenterYAnchor.priority = .defaultLow
        
        constraints = [
            imageView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: navigationBarHeight),
            view.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            imageCenterYAnchor,
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: button.topAnchor, constant: -32),
            
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 16),
            view.bottomAnchor.constraint(greaterThanOrEqualTo: button.bottomAnchor, constant: 34),
            button.heightAnchor.constraint(equalToConstant: 47)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func clearConstraints() {
        constraints.forEach { $0.isActive = false }
        constraints.removeAll()
    }
    
    func containerLayoutUpdated(_ layout: ContainerViewLayout, navigationBarHeight: CGFloat, transition: ContainedViewLayoutTransition) {
        configureLayout(navigationBarHeight: navigationBarHeight)
    }
}
