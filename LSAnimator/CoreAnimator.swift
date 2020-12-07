//
//  CoreAnimator.swift
//  CoreAnimator
//
//  Created by Lision on 2017/12/28.
//  Copyright © 2017年 Lision. All rights reserved.
//

import Foundation
import UIKit
#if SWIFT_PACKAGE
import LSAnimatorCore
#endif

internal extension Double {
    var toCG: CGFloat {
        return CGFloat(self)
    }
}

public final class CoreAnimator {
    fileprivate var animator: LSAnimator!
    
    public convenience init(view: UIView) {
        self.init(layer: view.layer)
    }
    
    public init(layer: CALayer) {
        animator = LSAnimator(layer: layer)
    }
    
    public var layer: CALayer? {
        return animator.layer
    }
}

// MARK: - CoreAnimator Animations
public extension CoreAnimator {
    
    // MARK: - Make Animations
    func make(frame: CGRect) -> Self {
        _ = animator.makeFrame(frame)
        return self
    }
    
    func make(bounds: CGRect) -> Self {
        _ = animator.makeBounds(bounds)
        return self
    }

    func make(width: Double, height: Double) -> Self {
        _ = animator.makeSize(width.toCG, height.toCG)
        return self
    }

    func makeOrigin(x: Double, y: Double) -> Self {
        _ = animator.makeOrigin(x.toCG, y.toCG)
        return self
    }

    func makePosition(x: Double, y: Double) -> Self {
        _ = animator.makePosition(x.toCG, y.toCG)
        return self
    }

    func make(x: Double) -> Self {
        _ = animator.makeX(x.toCG)
        return self
    }

    func make(y: Double) -> Self {
        _ = animator.makeY(y.toCG)
        return self
    }

    func make(width: Double) -> Self {
        _ = animator.makeWidth(width.toCG)
        return self
    }

    func make(height: Double) -> Self {
        _ = animator.makeHeight(height.toCG)
        return self
    }

    func make(alpha: Double) -> Self {
        _ = animator.makeOpacity(alpha.toCG)
        return self
    }

    func make(backgroundColor color: UIColor) -> Self {
        _ = animator.makeBackground(color)
        return self
    }

    func make(borderColor color: UIColor) -> Self {
        _ = animator.makeBorderColor(color)
        return self
    }

    func make(borderWidth width: Double) -> Self {
        _ = animator.makeBorderWidth(width.toCG)
        return self
    }

    func make(cornerRadius: Double) -> Self {
        _ = animator.makeCornerRadius(cornerRadius.toCG)
        return self
    }

    func make(scale: Double) -> Self {
        _ = animator.makeScale(scale.toCG)
        return self
    }
    
    func make(scaleX: Double) -> Self {
        _ = animator.makeScaleX(scaleX.toCG)
        return self
    }

    func make(scaleY: Double) -> Self {
        _ = animator.makeScaleY(scaleY.toCG)
        return self
    }

    func makeAnchor(x: Double, y: Double) -> Self {
        _ = animator.makeAnchor(x.toCG, y.toCG)
        return self
    }

    // MARK: - Move Animations
    func move(x: Double) -> Self {
        _ = animator.moveX(x.toCG)
        return self
    }

    func move(y: Double) -> Self {
        _ = animator.moveY(y.toCG)
        return self
    }

    func move(x: Double, y: Double) -> Self {
        _ = animator.moveXY(x.toCG, y.toCG)
        return self
    }

    func movePolar(radius: Double, angle: Double) -> Self {
        _ = animator.movePolar(radius.toCG, angle.toCG)
        return self
    }

    // MARK: - Incre Animations
    func incre(width: Double) -> Self {
        _ = animator.increWidth(width.toCG)
        return self
    }
    
    func incre(height: Double) -> Self {
        _ = animator.increHeight(height.toCG)
        return self
    }
    
    func incre(width: Double, height: Double) -> Self {
        _ = animator.increSize(width.toCG, height.toCG)
        return self
    }
    
    // MARK: - Transform Animations
    var transformIdentity: CoreAnimator {
        animator.transformIdentity()
        return self
    }

    func rotate(angle: Double) -> Self {
        _ = animator.rotate(angle.toCG)
        return self
    }

    func rotateX(angle: Double) -> Self {
        _ = animator.rotateX(angle.toCG)
        return self
    }

    func rotateY(angle: Double) -> Self {
        _ = animator.rotateY(angle.toCG)
        return self
    }

    func rotateZ(angle: Double) -> Self {
        _ = animator.rotateZ(angle.toCG)
        return self
    }

    func transform(x: Double) -> Self {
        _ = animator.transformX(x.toCG)
        return self
    }

    func transform(y: Double) -> Self {
        _ = animator.transformY(y.toCG)
        return self
    }
    
    func transform(z: Double) -> Self {
        _ = animator.transformZ(z.toCG)
        return self
    }

    func transform(x: Double, y: Double) -> Self {
        _ = animator.transformXY(x.toCG, y.toCG)
        return self
    }

    func transform(scale: Double) -> Self {
        _ = animator.transformScale(scale.toCG)
        return self
    }

    func transform(scaleX: Double) -> Self {
        _ = animator.transformScaleX(scaleX.toCG)
        return self
    }

    func transform(scaleY: Double) -> Self {
        _ = animator.transformScaleY(scaleY.toCG)
        return self
    }

    // MARK: - BezierPath Animations
    func move(onPath path: UIBezierPath, rotate: Bool = false, isReversed: Bool = false) -> Self {
        if rotate {
            if isReversed {
                _ = animator.moveAndReverseRotateOnPath(path)
            } else {
                _ = animator.moveAndRotateOnPath(path)
            }
        } else {
            _ = animator.moveOnPath(path)
        }
        return self
    }

    // MARK: - Anchor Position
    enum AnchorPosition {
        case normal
        case center
        case top
        case bottom
        case left
        case right
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }

    func anchor(_ position: AnchorPosition) -> CoreAnimator {
        switch position {
        case .normal:
            animator.anchorDefault()
        case .center:
            animator.anchorCenter()
        case .top:
            animator.anchorTop()
        case .bottom:
            animator.anchorBottom()
        case .left:
            animator.anchorLeft()
        case .right:
            animator.anchorRight()
        case .topLeft:
            animator.anchorTopLeft()
        case .topRight:
            animator.anchorTopRight()
        case .bottomLeft:
            animator.anchorBottomLeft()
        case .bottomRight:
            animator.anchorBottomRight()
        }
        return self
    }

    // MARK: - Effect Functions
    var easeIn: CoreAnimator {
        animator.easeIn()
        return self
    }

    var easeOut: CoreAnimator {
        animator.easeOut()
        return self
    }

    var easeInOut: CoreAnimator {
        animator.easeInOut()
        return self
    }

    var easeBack: CoreAnimator {
        animator.easeBack()
        return self
    }

    var spring: CoreAnimator {
        animator.spring()
        return self
    }

    var bounce: CoreAnimator {
        animator.bounce()
        return self
    }

    var easeInQuad: CoreAnimator {
        animator.easeInQuad()
        return self
    }

    var easeOutQuad: CoreAnimator {
        animator.easeOutQuad()
        return self
    }

    var easeInOutQuad: CoreAnimator {
        animator.easeInOutQuad()
        return self
    }

    var easeInCubic: CoreAnimator {
        animator.easeInCubic()
        return self
    }

    var easeOutCubic: CoreAnimator {
        animator.easeOutCubic()
        return self
    }

    var easeInOutCubic: CoreAnimator {
        animator.easeInOutCubic()
        return self
    }

    var easeInQuart: CoreAnimator {
        animator.easeInQuart()
        return self
    }

    var easeOutQuart: CoreAnimator {
        animator.easeOutQuart()
        return self
    }

    var easeInOutQuart: CoreAnimator {
        animator.easeInOutQuart()
        return self
    }

    var easeInQuint: CoreAnimator {
        animator.easeInQuint()
        return self
    }

    var easeOutQuint: CoreAnimator {
        animator.easeOutQuint()
        return self
    }

    var easeInOutQuint: CoreAnimator {
        animator.easeInOutQuint()
        return self
    }

    var easeInSine: CoreAnimator {
        animator.easeInSine()
        return self
    }

    var easeOutSine: CoreAnimator {
        animator.easeOutSine()
        return self
    }

    var easeInOutSine: CoreAnimator {
        animator.easeInOutSine()
        return self
    }

    var easeInExpo: CoreAnimator {
        animator.easeInExpo()
        return self
    }

    var easeOutExpo: CoreAnimator {
        animator.easeOutExpo()
        return self
    }

    var easeInOutExpo: CoreAnimator {
        animator.easeInOutExpo()
        return self
    }

    var easeInCirc: CoreAnimator {
        animator.easeInCirc()
        return self
    }

    var easeOutCirc: CoreAnimator {
        animator.easeOutCirc()
        return self
    }

    var easeInOutCirc: CoreAnimator {
        animator.easeInOutCirc()
        return self
    }

    var easeInElastic: CoreAnimator {
        animator.easeInElastic()
        return self
    }

    var easeOutElastic: CoreAnimator {
        animator.easeOutElastic()
        return self
    }

    var easeInOutElastic: CoreAnimator {
        animator.easeInOutElastic()
        return self
    }

    var easeInBack: CoreAnimator {
        animator.easeInBack()
        return self
    }

    var easeOutBack: CoreAnimator {
        animator.easeOutBack()
        return self
    }

    var easeInOutBack: CoreAnimator {
        animator.easeInOutBack()
        return self
    }

    var easeInBounce: CoreAnimator {
        animator.easeInBounce()
        return self
    }

    var easeOutBounce: CoreAnimator {
        animator.easeOutBounce()
        return self
    }

    var easeInOutBounce: CoreAnimator {
        animator.easeInOutBounce()
        return self
    }

    // MARK: - Hooks
    func preAnimationBlock(block: @escaping () -> ()) -> Self {
        _ = animator.preAnimationBlock(block)
        return self
    }

    func postAnimationBlock(block: @escaping () -> ()) -> Self {
        _ = animator.postAnimationBlock(block)
        return self
    }
    
    func theFinalCompletion(block: @escaping () -> ()) {
        animator.theFinalCompletion(block)
    }
    
    // MARK: - Delay & Wait
    func delay(t: TimeInterval) -> Self {
        _ = animator.delay(t)
        return self
    }
    
    func wait(t: TimeInterval) -> Self {
        _ = animator.wait(t)
        return self
    }

    // MARK: - Animator Controls
    func `repeat`(t: TimeInterval, count: Int) -> Self {
        _ = animator.`repeat`(t, count)
        return self
    }

    func thenAfter(t: TimeInterval) -> Self {
        _ = animator.thenAfter(t)
        return self
    }

    func animate(t: TimeInterval) {
        animator.animate(t)
    }

    func animateWithRepeat(t: TimeInterval, count: Int) {
        animator.animateWithRepeat(t, count)
    }

    func animate(t: TimeInterval, completion: @escaping () -> ()) {
        animator.animateWithCompletion(t, completion)
    }
    
    // MARK: - Multi-chain Animations
    var concurrent: CoreAnimator {
        animator.concurrent()
        return self
    }
}
