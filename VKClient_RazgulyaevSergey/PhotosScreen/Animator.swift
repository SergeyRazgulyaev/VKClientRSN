//
//  Animator.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 30.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let source = transitionContext.viewController(forKey: .from) else { return }
        guard let destination = transitionContext.viewController(forKey: .to) else { return }
        
        transitionContext.containerView.addSubview(destination.view)
        
        destination.view.frame = source.view.frame
        
        let initialDestinationRotation = CGAffineTransform(rotationAngle: -1.5708)
        let initialDestinationTransition = CGAffineTransform(translationX: source.view.frame.width*2, y: source.view.frame.height)
        destination.view.transform = initialDestinationRotation.concatenating(initialDestinationTransition)
        
        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext),
                                delay: 0,
                                options: .calculationModePaced,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                       relativeDuration: 1.0,
                                                       animations: {
                                                        source.view.layer.anchorPoint = CGPoint(x: 1, y: 0)
                                                        let sourceRotation = CGAffineTransform(rotationAngle: 1.5708)
                                                        let sourceTransition = CGAffineTransform(translationX: source.view.frame.width/2, y: -source.view.frame.height/2)
                                                        source.view.transform = sourceRotation.concatenating(sourceTransition)
                                    })
                                    UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                       relativeDuration: 1.0,
                                                       animations: {
                                                        destination.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
                                                        let destinationTransition = CGAffineTransform(translationX: 0, y: -source.view.frame.width/2)
                                                        destination.view.transform = destinationTransition
                                    })
        }) { result in
            if result && !transitionContext.transitionWasCancelled {
                source.view.transform = .identity
                transitionContext.completeTransition(true)
            }
            else {
                transitionContext.completeTransition(false)
            }
        }
    }
}


class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let source = transitionContext.viewController(forKey: .from) else { return }
        guard let destination = transitionContext.viewController(forKey: .to) else { return }
        
        transitionContext.containerView.addSubview(destination.view)
        transitionContext.containerView.sendSubviewToBack(destination.view)
        
        destination.view.frame = source.view.frame
        
        let initialDestinationRotation = CGAffineTransform(rotationAngle: 1.5708)
        let initialDestinationTransition = CGAffineTransform(translationX: 0, y: 0)
        destination.view.transform = initialDestinationRotation.concatenating(initialDestinationTransition)
        
        
        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext),
                                delay: 0,
                                options: .calculationModePaced,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                       relativeDuration: 1.0,
                                                       animations: {
                                                        source.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
                                                        let sourceRotation = CGAffineTransform(rotationAngle: -1.5708)
                                                        let sourceTransition = CGAffineTransform(translationX: source.view.frame.width/2, y: 0)
                                                        source.view.transform = sourceRotation.concatenating(sourceTransition)
                                    })
                                    UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                       relativeDuration: 1.0,
                                                       animations: {
                                                        destination.view.layer.anchorPoint = CGPoint(x: 1.0, y: 0)
                                                        let destinationTransition = CGAffineTransform(translationX: 0, y: 0)
                                                        destination.view.transform = destinationTransition
                                                        
                                    })
        }) { finished in
            if finished && !transitionContext.transitionWasCancelled {
                source.removeFromParent()
            } else if transitionContext.transitionWasCancelled {
                destination.view.transform = .identity
            }
            transitionContext.completeTransition(finished && !transitionContext.transitionWasCancelled)
        }
    }
}

class InteractiveTransition: UIPercentDrivenInteractiveTransition {
    var hasStarted: Bool = false
    var shouldFinish: Bool = false
    
    var viewController: UIViewController? {
        didSet {
            let edgePanRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            edgePanRecognizer.edges = [.left]
            viewController?.view.addGestureRecognizer(edgePanRecognizer)
        }
    }
    
    @objc func handlePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        switch gesture.state {
        case .began:
            hasStarted = true
            viewController?.navigationController?.popViewController(animated: true)
            
        case .changed:
            let translation = gesture.translation(in: gesture.view?.superview)
            let relativeTranslation = translation.x / (gesture.view?.bounds.width ?? 1)
            let progress = max(0, min(1, relativeTranslation))
            
            shouldFinish = progress > 0.33
            
            update(progress)
            
        case .ended:
            hasStarted = false
            shouldFinish ? finish() : cancel()
            
        case .cancelled:
            hasStarted = false
            cancel()
        default:
            return
        }
    }
}
