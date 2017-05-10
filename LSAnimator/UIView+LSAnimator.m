//
//  UIView+LSAnimator.m
//  LSAnimator
//
//  Created by Lision on 2017/4/30.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import <objc/runtime.h>
#import "CALayer+LSAnimator.h"

@implementation UIView (LSAnimator)

#pragma mark - Animator Kinds
- (LSAnimatorRect)ls_frame {
    LSAnimatorRect animator = LSAnimatorRect(rect) {
        return self.ls_origin(rect.origin.x, rect.origin.y).ls_bounds(rect);
    };
    
    return animator;
}

- (LSAnimatorRect)ls_bounds {
    LSAnimatorRect animator = LSAnimatorRect(rect) {
        return self.ls_size(rect.size.width, rect.size.height);
    };
    
    return animator;
}

- (LSAnimatorSize)ls_size {
    LSAnimatorSize animator = LSAnimatorSize(width, height) {
        self.layer.ls_size(width, height);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPoint)ls_origin {
    LSAnimatorPoint animator = LSAnimatorPoint(x, y) {
        self.layer.ls_origin(x, y);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPoint)ls_center {
    LSAnimatorPoint animator = LSAnimatorPoint(x, y) {
        self.layer.ls_position(x, y);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_x {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_x(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_y {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_y(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_width {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_width(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_height {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_height(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_opacity {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_opacity(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorColor)ls_background {
    LSAnimatorColor animator = LSAnimatorColor(color) {
        self.layer.ls_background(color);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorColor)ls_borderColor {
    LSAnimatorColor animator = LSAnimatorColor(color) {
        self.layer.ls_borderColor(color);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_borderWidth {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_borderWidth(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_cornerRadius {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_cornerRadius(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_scale {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_scale(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_scaleX {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_scaleX(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_scaleY {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_scaleY(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPoint)ls_anchor {
    LSAnimatorPoint animator = LSAnimatorPoint(x, y) {
        self.layer.ls_anchor(x, y);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_moveX {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_moveX(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_moveY {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_moveY(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPoint)ls_moveXY {
    LSAnimatorPoint animator = LSAnimatorPoint(x, y) {
        self.layer.ls_moveXY(x, y);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPolarCoordinate)ls_movePolar {
    LSAnimatorPolarCoordinate animator = LSAnimatorPolarCoordinate(radius, angle) {
        self.layer.ls_movePolar(radius, angle);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_increWidth {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_increWidth(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_increHeight {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_increHeight(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorSize)ls_increSize {
    LSAnimatorSize animator = LSAnimatorSize(width, height) {
        self.layer.ls_increSize(width, height);
        
        return self;
    };
    
    return animator;
}

- (UIView *)ls_transformIdentity {
    [self.layer ls_transformIdentity];
    
    return self;
}

- (LSAnimatorDegrees)ls_rotate {
    return [self ls_rotateZ];
}

- (LSAnimatorDegrees)ls_rotateX {
    LSAnimatorDegrees animator = LSAnimatorDegrees(angle) {
        self.layer.ls_rotateX(angle);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorDegrees)ls_rotateY {
    LSAnimatorDegrees animator = LSAnimatorDegrees(angle) {
        self.layer.ls_rotateY(angle);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorDegrees)ls_rotateZ {
    LSAnimatorDegrees animator = LSAnimatorDegrees(angle) {
        self.layer.ls_rotateZ(angle);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_transformX {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_transformX(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_transformY {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_transformY(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_transformZ {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_transformZ(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPoint)ls_transformXY {
    LSAnimatorPoint animator = LSAnimatorPoint(x, y) {
        self.layer.ls_transformXY(x, y);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_transformScale {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_transformScale(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_transformScaleX {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_transformScaleX(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_transformScaleY {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        self.layer.ls_transformScaleY(f);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorBezierPath)ls_moveOnPath {
    LSAnimatorBezierPath animator = LSAnimatorBezierPath(path) {
        self.layer.ls_moveOnPath(path);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorBezierPath)ls_moveAndRotateOnPath {
    LSAnimatorBezierPath animator = LSAnimatorBezierPath(path) {
        self.layer.ls_moveAndRotateOnPath(path);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorBezierPath)ls_moveAndReverseRotateOnPath {
    LSAnimatorBezierPath animator = LSAnimatorBezierPath(path) {
        self.layer.ls_moveAndReverseRotateOnPath(path);
        
        return self;
    };
    
    return animator;
}

- (UIView *)ls_anchorDefault {
    [self.layer ls_anchorDefault];
    
    return self;
}

- (UIView *)ls_anchorCenter {
    [self.layer ls_anchorCenter];
    
    return self;
}

- (UIView *)ls_anchorTop {
    [self.layer ls_anchorTop];
    
    return self;
}

- (UIView *)ls_anchorBottom {
    [self.layer ls_anchorBottom];
    
    return self;
}

- (UIView *)ls_anchorLeft {
    [self.layer ls_anchorLeft];
    
    return self;
}

- (UIView *)ls_anchorRight {
    [self.layer ls_anchorRight];
    
    return self;
}

- (UIView *)ls_anchorTopLeft {
    [self.layer ls_anchorTopLeft];
    
    return self;
}

- (UIView *)ls_anchorTopRight {
    [self.layer ls_anchorTopRight];
    
    return self;
}

- (UIView *)ls_anchorBottomLeft {
    [self.layer ls_anchorBottomLeft];
    
    return self;
}

- (UIView *)ls_anchorBottomRight {
    [self.layer ls_anchorBottomRight];
    
    return self;
}

#pragma mark - Animator Effects
- (UIView *)ls_easeIn {
    [self.layer ls_easeIn];
    
    return self;
}

- (UIView *)ls_easeOut {
    [self.layer ls_easeOut];
    
    return self;
}

- (UIView *)ls_easeInOut {
    [self.layer ls_easeInOut];
    
    return self;
}

- (UIView *)ls_easeBack {
    [self.layer ls_easeBack];
    
    return self;
}

- (UIView *)ls_spring {
    [self.layer ls_spring];
    
    return self;
}

- (UIView *)ls_bounce {
    [self.layer ls_bounce];
    
    return self;
}

- (UIView *)ls_easeInQuad {
    [self.layer ls_easeInQuad];
    
    return self;
}

- (UIView *)ls_easeOutQuad {
    [self.layer ls_easeOutQuad];
    
    return self;
}

- (UIView *)ls_easeInOutQuad {
    [self.layer ls_easeInOutQuad];
    
    return self;
}

- (UIView *)ls_easeInCubic {
    [self.layer ls_easeInCubic];
    
    return self;
}

- (UIView *)ls_easeOutCubic {
    [self.layer ls_easeOutCubic];
    
    return self;
}

- (UIView *)ls_easeInOutCubic {
    [self.layer ls_easeInOutCubic];
    
    return self;
}

- (UIView *)ls_easeInQuart {
    [self.layer ls_easeInQuart];
    
    return self;
}

- (UIView *)ls_easeOutQuart {
    [self.layer ls_easeOutQuart];
    
    return self;
}

- (UIView *)ls_easeInOutQuart {
    [self.layer ls_easeInOutQuart];
    
    return self;
}

- (UIView *)ls_easeInQuint {
    [self.layer ls_easeInQuint];
    
    return self;
}

- (UIView *)ls_easeOutQuint {
    [self.layer ls_easeOutQuint];
    
    return self;
}

- (UIView *)ls_easeInOutQuint {
    [self.layer ls_easeInOutQuint];
    
    return self;
}

- (UIView *)ls_easeInSine {
    [self.layer ls_easeInSine];
    
    return self;
}

- (UIView *)ls_easeOutSine {
    [self.layer ls_easeOutSine];
    
    return self;
}

- (UIView *)ls_easeInOutSine {
    [self.layer ls_easeInOutSine];
    
    return self;
}

- (UIView *)ls_easeInExpo {
    [self.layer ls_easeInExpo];
    
    return self;
}

- (UIView *)ls_easeOutExpo {
    [self.layer ls_easeOutExpo];
    
    return self;
}

- (UIView *)ls_easeInOutExpo {
    [self.layer ls_easeInOutExpo];
    
    return self;
}

- (UIView *)ls_easeInCirc {
    [self.layer ls_easeInCirc];
    
    return self;
}

- (UIView *)ls_easeOutCirc {
    [self.layer ls_easeOutCirc];
    
    return self;
}

- (UIView *)ls_easeInOutCirc {
    [self.layer ls_easeInOutCirc];
    
    return self;
}

- (UIView *)ls_easeInElastic {
    [self.layer ls_easeInElastic];
    
    return self;
}

- (UIView *)ls_easeOutElastic {
    [self.layer ls_easeOutElastic];
    
    return self;
}

- (UIView *)ls_easeInOutElastic {
    [self.layer ls_easeInOutElastic];
    
    return self;
}

- (UIView *)ls_easeInBack {
    [self.layer ls_easeInBack];
    
    return self;
}

- (UIView *)ls_easeOutBack {
    [self.layer ls_easeOutBack];
    
    return self;
}

- (UIView *)ls_easeInOutBack {
    [self.layer ls_easeInOutBack];
    
    return self;
}

- (UIView *)ls_easeInBounce {
    [self.layer ls_easeInBounce];
    
    return self;
}

- (UIView *)ls_easeOutBounce {
    [self.layer ls_easeOutBounce];
    
    return self;
}

- (UIView *)ls_easeInOutBounce {
    [self.layer ls_easeInOutBounce];
    
    return self;
}

#pragma mark - Blocks
- (LSAnimatorBlock)ls_preAnimationBlock {
    LSAnimatorBlock animator = LSAnimatorBlock(block) {
        self.layer.ls_preAnimationBlock(block);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorBlock)ls_postAnimationBlock {
    LSAnimatorBlock animator = LSAnimatorBlock(block) {
        self.layer.ls_postAnimationBlock(block);
        
        return self;
    };
    
    return animator;
}

- (LSFinalAnimatorCompletion)ls_theFinalCompletion {
    LSFinalAnimatorCompletion animator = LSFinalAnimatorCompletion(block) {
        self.layer.ls_theFinalCompletion(block);
    };
    
    return animator;
}

- (LSAnimatorTimeInterval)ls_delay {
    LSAnimatorTimeInterval animator = LSAnimatorTimeInterval(t) {
        self.layer.ls_delay(t);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorTimeInterval)ls_wait {
    LSAnimatorTimeInterval animator = LSAnimatorTimeInterval(t) {
        self.layer.ls_wait(t);
        
        return self;
    };
    
    return animator;
}

#pragma mark - Animator Controls
- (LSAnimatorRepeatAnimation)ls_repeat {
    LSAnimatorRepeatAnimation animator = LSAnimatorRepeatAnimation(duration, count) {
        self.layer.ls_repeat(duration, count);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorTimeInterval)ls_thenAfter {
    LSAnimatorTimeInterval animator = LSAnimatorTimeInterval(t) {
        self.layer.ls_thenAfter(t);
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorAnimation)ls_animate {
    LSAnimatorAnimation animator = LSAnimatorAnimation(duration) {
        self.layer.ls_animate(duration);
    };
    
    return animator;
}

- (LSAnimatorAnimationWithRepeat)ls_animateWithRepeat {
    LSAnimatorAnimationWithRepeat animator = LSAnimatorAnimationWithRepeat(duration, count) {
        self.layer.ls_animateWithRepeat(duration, count);
    };
    
    return animator;
}

- (LSAnimatorAnimationWithCompletion)ls_animateWithCompletion {
    LSAnimatorAnimationWithCompletion animator = LSAnimatorAnimationWithCompletion(duration, completion) {
        self.layer.ls_animateWithCompletion(duration, completion);
    };
    
    return animator;
}

- (UIView *)ls_concurrent {
    [self.layer ls_concurrent];
    
    return self;
}

@end
