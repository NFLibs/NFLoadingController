//
//  NFLoadingView.swift
//  NFLoadingView
//
//  Created by Apple on 11/30/16.
//  Copyright © 2016 NF. All rights reserved.
//

import UIKit
import SwiftGifOrigin
public typealias NFLoadingControllerFrameClosure = () -> CGRect
public typealias NFBackgroundViewClosure = () -> UIView

public enum NFLoadingControllerPresentingStyle {
    case fade
    case popIn
}
public enum NFLoadingControllerDismissalStyle {
    case fade
    case popOut
}

open class NFLoadingControllerBuilder{
    public var image:UIImage = UIImage()
    public var alpha:CGFloat = 1
    public var textColor:UIColor = UIColor.red
    public var textFont:UIFont = .boldSystemFont(ofSize: 15)
    public var presentingStyle:NFLoadingControllerPresentingStyle = .popIn
    public var dismissalStyle:NFLoadingControllerDismissalStyle = .popOut
    public var frame:NFLoadingControllerFrameClosure = {
        return CGRect(x:UIScreen.main.bounds.size.width/2-100,y:UIScreen.main.bounds.size.height/2-100,width:200,height:200)
    }
    public var backgroundView : NFBackgroundViewClosure = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black
        return backgroundView
    }
    public var waitingText:String = "Please Wait..."
    
    typealias BuilderClosure = (NFLoadingControllerBuilder) -> ()
    
    public init(buildClosure: BuilderClosure) {
        buildClosure(self)
    }
}

open class NFLoadingController:NSObject{
    internal var presentedViewController:UIViewController = UIViewController()
    internal var imageView:UIImageView!
    internal var label:UILabel!
    internal var dismissalAnimator = NFLoadingViewDismissalAnimator()
    internal var presentingAnimator = NFLoadingViewPresentingAnimator()
    internal var builder:NFLoadingControllerBuilder!
    public init?(builder:NFLoadingControllerBuilder){
        super.init()
        
        presentedViewController.view.backgroundColor = UIColor.clear
        
        self.imageView = UIImageView(image: builder.image)
        self.imageView.contentMode = .scaleAspectFit
        
        self.label = UILabel()
        self.label.text = builder.waitingText
        self.label.font = builder.textFont
        self.label.textColor = builder.textColor
        self.label.textAlignment = .center
        self.label.numberOfLines = 1
        
        presentedViewController.view.addSubview(self.imageView)
        presentedViewController.view.addSubview(self.label)
        
        self.addConstraints()
        
        dismissalAnimator.style = builder.dismissalStyle
        presentingAnimator.style = builder.presentingStyle
        
        self.builder = builder
    }
    override public  init(){
        super.init()
    }
    fileprivate func addConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.label.translatesAutoresizingMaskIntoConstraints = false
        presentedViewController.view.clipsToBounds = false
        if #available(iOS 9.0, *) {
            self.imageView.topAnchor.constraint(equalTo: presentedViewController.view.topAnchor).isActive = true
            self.imageView.leadingAnchor.constraint(equalTo: presentedViewController.view.leadingAnchor).isActive = true
            self.imageView.trailingAnchor.constraint(equalTo: presentedViewController.view.trailingAnchor).isActive = true
            self.imageView.bottomAnchor.constraint(equalTo: self.label.topAnchor).isActive = true
            self.label.bottomAnchor.constraint(equalTo: presentedViewController.view.bottomAnchor).isActive = true
            self.label.centerXAnchor.constraint(equalTo: presentedViewController.view.centerXAnchor).isActive = true
            self.label.heightAnchor.constraint(equalToConstant: 30).isActive = true
            
        } else {
           
            let imageViewTopConstraint = NSLayoutConstraint(item: self.imageView, attribute: .top , relatedBy: .equal, toItem: presentedViewController.view, attribute: .top, multiplier: 1, constant: 0)
            let imageViewLeadingConstraint = NSLayoutConstraint(item: self.imageView, attribute: .leading, relatedBy: .equal, toItem: presentedViewController.view, attribute: .leading, multiplier: 1, constant: 0)
            let imageViewTrailingConstraint = NSLayoutConstraint(item: self.imageView, attribute: .trailing, relatedBy: .equal, toItem: presentedViewController.view, attribute: .trailing, multiplier: 1, constant: 0)
            let imageViewBottomConstraint = NSLayoutConstraint(item: self.imageView, attribute: .bottom, relatedBy: .equal, toItem: self.label, attribute: .top, multiplier: 1, constant: 0)
            let labelBottomConstraint = NSLayoutConstraint(item: self.label, attribute: .bottom, relatedBy: .equal, toItem: presentedViewController.view, attribute: .bottom, multiplier: 1, constant: 0)
            let labelCenterXConstraint = NSLayoutConstraint(item: self.label, attribute: .centerX, relatedBy: .equal, toItem: presentedViewController.view, attribute: .centerX, multiplier: 1, constant: 0)
            let labelHeightConstraint = NSLayoutConstraint(item: self.label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
            presentedViewController.view.addConstraints([imageViewTopConstraint,imageViewLeadingConstraint,imageViewTrailingConstraint,imageViewBottomConstraint,labelBottomConstraint,labelCenterXConstraint,labelHeightConstraint])
        }
        

    }
    public func present(from viewController:UIViewController,completion:(()->Void)?){
        presentedViewController.modalPresentationStyle = .custom
        presentedViewController.transitioningDelegate = self
        viewController.present(presentedViewController, animated: true) { 
            if completion != nil {
                completion!()
            }
        }
    }
    public func dismiss(_ completion:(()->Void)?){
        
            self.presentedViewController.dismiss(animated: true, completion: { 
                if completion != nil {
                    completion!()
                }
            })
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
extension NFLoadingController: UIViewControllerTransitioningDelegate{
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return NFLoadingViewPresentationController(presentedViewController: presented, presenting: presenting,frame:builder.frame,alpha:builder.alpha,dimmingView:builder.backgroundView())
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.dismissalAnimator
    }
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return self.presentingAnimator
    }
}



class NFLoadingViewPresentationController: UIPresentationController{
    var frame : NFLoadingControllerFrameClosure!
    var dimmingView:UIView!
    var alpha:CGFloat = 1
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?,frame:@escaping NFLoadingControllerFrameClosure,alpha:CGFloat,dimmingView:UIView) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.dimmingView = dimmingView
        self.frame = frame
        self.alpha = alpha
    }
    override var frameOfPresentedViewInContainerView: CGRect{
        return frame()
    }
    override func containerViewWillLayoutSubviews() {
        self.presentedView!.frame = frameOfPresentedViewInContainerView
        self.dimmingView.frame = UIScreen.main.bounds
    }
    override func presentationTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            return
        }
        
        
        
        containerView?.addSubview(self.dimmingView)
        self.dimmingView.alpha = 0
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.dimmingView.alpha = self.alpha
            }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            return
        }
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
                self.dimmingView.alpha = 0
            }) { (UIViewControllerTransitionCoordinatorContext) in
                
        }
    }
    
}
class NFLoadingViewPresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var style:NFLoadingControllerPresentingStyle!
    
    init(withStyle style:NFLoadingControllerPresentingStyle) {
        super.init()
        self.style = style
    }
    override init() {
        super.init()
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let presentedViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
                let containerView = transitionContext.containerView
        containerView.addSubview(presentedViewController.view)
        presentedViewController.view.frame = transitionContext.finalFrame(for: presentedViewController)
        if self.style == .popIn {
            presentedViewController.view.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        }
        else if self.style == .fade {
            presentedViewController.view.alpha = 0
            
        }
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            if self.style == .fade {
                presentedViewController.view.alpha = 1
            }
            else if self.style == .popIn {
                presentedViewController.view.transform = CGAffineTransform.identity
            }
        }) { (Bool) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

class NFLoadingViewDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var style:NFLoadingControllerDismissalStyle!
    override init() {
        super.init()
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let presentedViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {

            if self.style == .popOut {
                presentedViewController.view.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            }
            else if self.style == .fade {
                presentedViewController.view.alpha = 0
            }
            
        }) { (Bool) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            presentedViewController.view.alpha = 1
            presentedViewController.view.transform = CGAffineTransform.identity
        }
    }
    
}
