//
//  HUD.swift
//  PKHUD
//
//  Created by Philip Kluz on 6/13/14.
//  Copyright (c) 2016 NSExceptional. All rights reserved.
//  Licensed under the MIT license.
//

import UIKit

/// The PKHUD object controls showing and hiding of the HUD, as well as its contents and touch response behavior.
open class PKHUD: NSObject {
    
    fileprivate struct Constants {
        static let sharedHUD = PKHUD()
    }
    
    fileprivate let containerView = ContainerView()
    fileprivate var hideTimer: Timer?
    
    public typealias TimerAction = (Bool) -> Void
    fileprivate var timerActions = [String: TimerAction]()
    
    // MARK: Public
    
    open class var sharedHUD: PKHUD {
        return Constants.sharedHUD
    }
    
    public override init () {
        super.init()
        NotificationCenter.default.addObserver(self,
            selector: #selector(PKHUD.willEnterForeground(_:)),
            name: NSNotification.Name.UIApplicationWillEnterForeground,
            object: nil)
        userInteractionOnUnderlyingViewsEnabled = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open var dimsBackground = true
    open var userInteractionOnUnderlyingViewsEnabled: Bool {
        get {
            return !containerView.isUserInteractionEnabled
        }
        set {
            containerView.isUserInteractionEnabled = !newValue
        }
    }
    
    open var isVisible: Bool {
        return !containerView.isHidden
    }
    
    open var contentView: UIView {
        get {
            return containerView.frameView.content
        }
        set {
            containerView.frameView.content = newValue
            startAnimatingContentView()
        }
    }
    
    open var effect: UIVisualEffect? {
        get {
            return containerView.frameView.effect
        }
        set {
            containerView.frameView.effect = effect
        }
    }
    
    public func show(onView view: UIView) {
        if self.containerView.superview == nil {
            view.addSubview(self.containerView)
            let left = NSLayoutConstraint(item: containerView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0)
            let top = NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
            let right = NSLayoutConstraint(item: containerView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
            
            view.addConstraints([left,top,right,bottom])
        }
        containerView.showFrameView()

        if dimsBackground {
            containerView.showBackground(animated: true)
        }
        
        startAnimatingContentView()
    }
    
    open func hide(animated anim: Bool = true, completion: TimerAction? = nil) {
        containerView.hideFrameView(animated: anim, completion: completion)
        stopAnimatingContentView()
    }
    
    open func hide(_ animated: Bool, completion: TimerAction? = nil) {
        hide(animated: animated, completion: completion)
    }
    
    open func hide(afterDelay delay: TimeInterval, completion: TimerAction? = nil) {
        let key = UUID().uuidString
        let userInfo = ["timerActionKey": key]
        if let completion = completion {
            timerActions[key] = completion
        }
        
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(timeInterval: delay,
                                                           target: self,
                                                           selector: #selector(PKHUD.performDelayedHide(_:)),
                                                           userInfo: userInfo,
                                                           repeats: false)
    }
    
    // MARK: Internal
    
    internal func willEnterForeground(_ notification: Notification?) {
        self.startAnimatingContentView()
    }
    
    internal func performDelayedHide(_ timer: Timer? = nil) {
        let userInfo = timer?.userInfo as? Dictionary<String, AnyObject>
        let key = userInfo?["timerActionKey"] as? String
        var completion: TimerAction?
        
        if let key = key, let action = timerActions[key] {
            completion = action
            timerActions[key] = nil
        }
        
        hide(animated: true, completion: completion);
    }
    
    internal func startAnimatingContentView() {
        if isVisible && contentView.conforms(to: PKHUDAnimating.self) {
            let animatingContentView = contentView as! PKHUDAnimating
            animatingContentView.startAnimation()
        }
    }
    
    internal func stopAnimatingContentView() {
        if let animatingContentView = contentView as? PKHUDAnimating {
            animatingContentView.stopAnimation?()
        }
    }
}
