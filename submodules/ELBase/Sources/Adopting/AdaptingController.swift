//
//  AdaptingController.swift
//  _idx_ELProfileUI_3402FF40_ios_min11.0
//
//

import UIKit
import Display

public class AdaptingController: ViewController {
    private var wasViewDidLoad = false
    public var altController: UIViewController?
    public var containerViewLayout: ContainerViewLayout? {
        didSet {
            onContainerViewLayoutHandler?(containerViewLayout)
        }
    }
    public var onContainerViewLayoutHandler: ((_ containerViewLayout: ContainerViewLayout?) -> Void)?
    
    public init(viewController: UIViewController?) {
        super.init(navigationBarPresentationData: nil)
        
        altController = viewController
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        
        altController?.loadView()
        
        viewDidLoad()
    }
    
    public override func viewDidLoad() {
        if wasViewDidLoad { return }
        
        super.viewDidLoad()
        
        altController?.viewDidLoad()
        
        wasViewDidLoad = true
    }
    
    public override func didMove(toParent parent: UIViewController?) {
        if parent != nil {
            addControllerIfNeeded()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        altController?.beginAppearanceTransition(true, animated: animated)
        addControllerIfNeeded()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        altController?.endAppearanceTransition()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        altController?.beginAppearanceTransition(false, animated: animated)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        altController?.endAppearanceTransition()
    }
    
    override public func loadDisplayNode() {
        displayNode = AdaptingControllerNode()
        displayNodeDidLoad()
    }
    
    public override func updateNavigationBarLayout(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.updateNavigationBarLayout(layout, transition: transition)
        addControllerIfNeeded()
    }
    
    public override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        controllerNode.containerLayoutUpdated(layout, navigationBarHeight: 98, transition: transition)
        containerViewLayout = layout

        addControllerIfNeeded()
    }
    
    // MARK: - Private
    
    private var controllerNode: AdaptingControllerNode {
        return displayNode as! AdaptingControllerNode
    }
    
    private func addControllerIfNeeded() {
        guard altController?.isViewLoaded == true else {
            return
        }
        
        if let altView = altController?.view, !controllerNode.view.subviews.contains(altView) {
            controllerNode.view.addSubview(altView)
        }
        
        altController?.view.frame = controllerNode.bounds

    }
}
