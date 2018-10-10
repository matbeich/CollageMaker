//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

class SwipeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    init(duration: TimeInterval, presenting: Bool) {
        self.duration = duration
        self.presenting = presenting

        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(duration)
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let from = transitionContext.view(forKey: .from),
            let to = transitionContext.view(forKey: .to),
            let fromSnapshot = from.snapshotView(afterScreenUpdates: false)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let moveTransform = CGAffineTransform(translationX: presenting ? from.frame.width : -from.frame.width, y: 0)
        let containerView = transitionContext.containerView

        containerView.addSubview(fromSnapshot)
        containerView.addSubview(to)

        to.frame = from.frame.applying(moveTransform)
        fromSnapshot.frame = from.frame

        let presentingAnimation = {
            fromSnapshot.frame.origin.x = -fromSnapshot.frame.width
            to.frame = from.frame
        }

        let dismissingAnimation = {
            fromSnapshot.frame.origin.x = fromSnapshot.frame.width
            to.frame = from.frame
        }

        let animation = presenting ? presentingAnimation : dismissingAnimation

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: animation) { finished in
            fromSnapshot.removeFromSuperview()

            if transitionContext.transitionWasCancelled {
                to.removeFromSuperview()
            }

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

    private var duration: TimeInterval
    var presenting: Bool
}
