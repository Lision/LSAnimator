//
//  CoreAnimator.swift
//  CoreAnimator
//
//  Created by Lision on 2017/12/28.
//  Copyright © 2017年 Lision. All rights reserved.
//

import Foundation
import UIKit

internal extension Double {
    var toCG: CGFloat {
        return CGFloat(self)
    }
}

public final class CoreAnimator {
    fileprivate var animator: LSAnimator!
    
    convenience public init(view: UIView) {
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
    public func make(frame: CGRect) -> Self {
        _ = animator.makeFrame(frame)
        return self
    }
    
    public func make(bounds: CGRect) -> Self {
        _ = animator.makeBounds(bounds)
        return self
    }

    public func make(width: Double, height: Double) -> Self {
        _ = animator.makeSize(width.toCG, height.toCG)
        return self
    }

    public func makeOrigin(x: Double, y: Double) -> Self {
        _ = animator.makeOrigin(x.toCG, y.toCG)
        return self
    }

    public func makePosition(x: Double, y: Double) -> Self {
        _ = animator.makePosition(x.toCG, y.toCG)
        return self
    }

    public func make(x: Double) -> Self {
        _ = animator.makeX(x.toCG)
        return self
    }

    public func make(y: Double) -> Self {
        _ = animator.makeY(y.toCG)
        return self
    }

    public func make(width: Double) -> Self {
        _ = animator.makeWidth(width.toCG)
        return self
    }

    public func make(height: Double) -> Self {
        _ = animator.makeHeight(height.toCG)
        return self
    }

    public func make(alpha: Double) -> Self {
        _ = animator.makeOpacity(alpha.toCG)
        return self
    }

    public func make(backgroundColor color: UIColor) -> Self {
        _ = animator.makeBackground(color)
        return self
    }

    public func make(borderColor color: UIColor) -> Self {
        _ = animator.makeBorderColor(color)
        return self
    }

    public func make(borderWidth width: Double) -> Self {
        _ = animator.makeBorderWidth(width.toCG)
        return self
    }

    public func make(cornerRadius: Double) -> Self {
        _ = animator.makeCornerRadius(cornerRadius.toCG)
        return self
    }

    public func make(scale: Double) -> Self {
        _ = animator.makeScale(scale.toCG)
        return self
    }
    
    public func make(scaleX: Double) -> Self {
        _ = animator.makeScaleX(scaleX.toCG)
        return self
    }

    public func make(scaleY: Double) -> Self {
        _ = animator.makeScaleY(scaleY.toCG)
        return self
    }

    public func makeAnchor(x: Double, y: Double) -> Self {
        _ = animator.makeAnchor(x.toCG, y.toCG)
        return self
    }

    // MARK: - Move Animations
    public func move(x: Double) -> Self {
        _ = animator.moveX(x.toCG)
        return self
    }

    public func move(y: Double) -> Self {
        _ = animator.moveY(y.toCG)
        return self
    }

    public func move(x: Double, y: Double) -> Self {
        _ = animator.moveXY(x.toCG, y.toCG)
        return self
    }

    public func movePolar(radius: Double, angle: Double) -> Self {
        _ = animator.movePolar(radius.toCG, angle.toCG)
        return self
    }

    // MARK: - Incre Animations
    public func incre(width: Double) -> Self {
        _ = animator.increWidth(width.toCG)
        return self
    }
    
    public func incre(height: Double) -> Self {
        _ = animator.increHeight(height.toCG)
        return self
    }
    
    public func incre(width: Double, height: Double) -> Self {
        _ = animator.increSize(width.toCG, height.toCG)
        return self
    }
    
    // MARK: - Transform Animations
    public var transformIdentity: CoreAnimator {
        animator.transformIdentity()
        return self
    }

    public func rotate(angle: Double) -> Self {
        _ = animator.rotate(angle.toCG)
        return self
    }

    public func rotateX(angle: Double) -> Self {
        _ = animator.rotateX(angle.toCG)
        return self
    }

    public func rotateY(angle: Double) -> Self {
        _ = animator.rotateY(angle.toCG)
        return self
    }

    public func rotateZ(angle: Double) -> Self {
        _ = animator.rotateZ(angle.toCG)
        return self
    }

    public func transform(x: Double) -> Self {
        _ = animator.transformX(x.toCG)
        return self
    }

    public func transform(y: Double) -> Self {
        _ = animator.transformY(y.toCG)
        return self
    }
    
    public func transform(z: Double) -> Self {
        _ = animator.transformZ(z.toCG)
        return self
    }

    public func transform(x: Double, y: Double) -> Self {
        _ = animator.transformXY(x.toCG, y.toCG)
        return self
    }

    public func transform(scale: Double) -> Self {
        _ = animator.transformScale(scale.toCG)
        return self
    }

    public func transform(scaleX: Double) -> Self {
        _ = animator.transformScaleX(scaleX.toCG)
        return self
    }

    public func transform(scaleY: Double) -> Self {
        _ = animator.transformScaleY(scaleY.toCG)
        return self
    }

    // MARK: - BezierPath Animations
    public func move(onPath path: UIBezierPath, rotate: Bool = false, isReversed: Bool = false) -> Self {
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
    public enum AnchorPosition {
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

    public func anchor(_ position: AnchorPosition) -> CoreAnimator {
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
    public var easeIn: CoreAnimator {
        animator.easeIn()
        return self
    }

    public var easeOut: CoreAnimator {
        animator.easeOut()
        return self
    }

    public var easeInOut: CoreAnimator {
        animator.easeInOut()
        return self
    }

    public var easeBack: CoreAnimator {
        animator.easeBack()
        return self
    }

    public var spring: CoreAnimator {
        animator.spring()
        return self
    }

    public var bounce: CoreAnimator {
        animator.bounce()
        return self
    }

    public var easeInQuad: CoreAnimator {
        animator.easeInQuad()
        return self
    }

    public var easeOutQuad: CoreAnimator {
        animator.easeOutQuad()
        return self
    }

    public var easeInOutQuad: CoreAnimator {
        animator.easeInOutQuad()
        return self
    }

    public var easeInCubic: CoreAnimator {
        animator.easeInCubic()
        return self
    }

    public var easeOutCubic: CoreAnimator {
        animator.easeOutCubic()
        return self
    }

    public var easeInOutCubic: CoreAnimator {
        animator.easeInOutCubic()
        return self
    }

    public var easeInQuart: CoreAnimator {
        animator.easeInQuart()
        return self
    }

    public var easeOutQuart: CoreAnimator {
        animator.easeOutQuart()
        return self
    }

    public var easeInOutQuart: CoreAnimator {
        animator.easeInOutQuart()
        return self
    }

    public var easeInQuint: CoreAnimator {
        animator.easeInQuint()
        return self
    }

    public var easeOutQuint: CoreAnimator {
        animator.easeOutQuint()
        return self
    }

    public var easeInOutQuint: CoreAnimator {
        animator.easeInOutQuint()
        return self
    }

    public var easeInSine: CoreAnimator {
        animator.easeInSine()
        return self
    }

    public var easeOutSine: CoreAnimator {
        animator.easeOutSine()
        return self
    }

    public var easeInOutSine: CoreAnimator {
        animator.easeInOutSine()
        return self
    }

    public var easeInExpo: CoreAnimator {
        animator.easeInExpo()
        return self
    }

    public var easeOutExpo: CoreAnimator {
        animator.easeOutExpo()
        return self
    }

    public var easeInOutExpo: CoreAnimator {
        animator.easeInOutExpo()
        return self
    }

    public var easeInCirc: CoreAnimator {
        animator.easeInCirc()
        return self
    }

    public var easeOutCirc: CoreAnimator {
        animator.easeOutCirc()
        return self
    }

    public var easeInOutCirc: CoreAnimator {
        animator.easeInOutCirc()
        return self
    }

    public var easeInElastic: CoreAnimator {
        animator.easeInElastic()
        return self
    }

    public var easeOutElastic: CoreAnimator {
        animator.easeOutElastic()
        return self
    }

    public var easeInOutElastic: CoreAnimator {
        animator.easeInOutElastic()
        return self
    }

    public var easeInBack: CoreAnimator {
        animator.easeInBack()
        return self
    }

    public var easeOutBack: CoreAnimator {
        animator.easeOutBack()
        return self
    }

    public var easeInOutBack: CoreAnimator {
        animator.easeInOutBack()
        return self
    }

    public var easeInBounce: CoreAnimator {
        animator.easeInBounce()
        return self
    }

    public var easeOutBounce: CoreAnimator {
        animator.easeOutBounce()
        return self
    }

    public var easeInOutBounce: CoreAnimator {
        animator.easeInOutBounce()
        return self
    }

    // MARK: - Hooks
    public func preAnimationBlock(block: @escaping () -> ()) -> Self {
        _ = animator.preAnimationBlock(block)
        return self
    }

    public func postAnimationBlock(block: @escaping () -> ()) -> Self {
        _ = animator.postAnimationBlock(block)
        return self
    }
    
    public func theFinalCompletion(block: @escaping () -> ()) {
        animator.theFinalCompletion(block)
    }
    
    // MARK: - Delay & Wait
    public func delay(t: TimeInterval) -> Self {
        _ = animator.delay(t)
        return self
    }
    
    public func wait(t: TimeInterval) -> Self {
        _ = animator.wait(t)
        return self
    }

    // MARK: - Animator Controls
    public func `repeat`(t: TimeInterval, count: Int) -> Self {
        _ = animator.`repeat`(t, count)
        return self
    }

    public func thenAfter(t: TimeInterval) -> Self {
        _ = animator.thenAfter(t)
        return self
    }

    public func animate(t: TimeInterval) {
        animator.animate(t)
    }

    public func animateWithRepeat(t: TimeInterval, count: Int) {
        animator.animateWithRepeat(t, count)
    }

    public func animate(t: TimeInterval, completion: @escaping () -> ()) {
        animator.animateWithCompletion(t, completion)
    }
    
    // MARK: - Multi-chain Animations
    public var concurrent: CoreAnimator {
        animator.concurrent()
        return self
    }
}
