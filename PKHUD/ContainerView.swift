//
//  ContainerView.swift
//  Pods
//
//  Created by Fabian Renner on 21.04.16.
//
//

import UIKit

internal class ContainerView: UIView {
    
    internal let frameView: FrameView
    internal init(frameView: FrameView = FrameView()) {
        self.frameView = frameView
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        frameView = FrameView()
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        backgroundColor = UIColor.clearColor()
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backgroundView)
        addSubview(frameView)
        
        let left = NSLayoutConstraint(item: backgroundView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: backgroundView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: backgroundView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: backgroundView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        
        let centerX = NSLayoutConstraint(item: frameView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: frameView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        self.addConstraints([left, top, right, bottom])
        self.addConstraints([centerX, centerY])
    }
    
    internal func showFrameView() {
        layer.removeAllAnimations()
        frameView.alpha = 1.0

        let width = NSLayoutConstraint(item: frameView, attribute: .width, relatedBy: .equal, toItem: frameView.content, attribute: .width, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: frameView, attribute: .height, relatedBy: .equal, toItem: frameView.content, attribute: .height, multiplier: 1, constant: 0)
        
        frameView.addConstraints([width, height])
        
        hidden = false
    }
    
    fileprivate var willHide = false
    
    internal func hideFrameView(animated anim: Bool, completion: ((Bool) -> Void)? = nil) {
        let finalize: (_ finished: Bool) -> (Void) = { finished in
            if finished {
                self.isHidden = true
                self.removeFromSuperview()
            }
        
            self.willHide = false
            
            completion?(finished)
        }
        
        if isHidden {
            return
        }
        
        willHide = true
        
        if anim {
            UIView.animate(withDuration: 0.8, animations: {
                self.frameView.alpha = 0.0
                self.hideBackground(animated: false)
            }, completion: finalize)
        } else {
            self.frameView.alpha = 0.0
            finalize(true)
        }
    }
    
    fileprivate let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white:0.0, alpha:0.25)
        view.alpha = 0.0
        return view
    }()
    
    internal func showBackground(animated anim: Bool) {
        if anim {
            UIView.animate(withDuration: 0.175, animations: {
                self.backgroundView.alpha = 1.0
            }) 
        } else {
            backgroundView.alpha = 1.0
        }
    }
    
    internal func hideBackground(animated anim: Bool) {
        if anim {
            UIView.animate(withDuration: 0.65, animations: {
                self.backgroundView.alpha = 0.0
            }) 
        } else {
            backgroundView.alpha = 0.0
        }
    }
}
