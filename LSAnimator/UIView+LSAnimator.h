//
//  UIView+LSAnimator.h
//  LSAnimator
//
//  Created by Lision on 2017/4/30.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSAnimatorBlocks.h"

@interface UIView (LSAnimator)

#pragma mark - Animations
// Properties
// Affects views position and bounds
- (LSAnimatorRect)ls_frame;
- (LSAnimatorRect)ls_bounds;
- (LSAnimatorSize)ls_size;
- (LSAnimatorPoint)ls_origin;
- (LSAnimatorPoint)ls_center;
- (LSAnimatorFloat)ls_x;
- (LSAnimatorFloat)ls_y;
- (LSAnimatorFloat)ls_width;
- (LSAnimatorFloat)ls_height;
- (LSAnimatorFloat)ls_opacity;
- (LSAnimatorColor)ls_background;
- (LSAnimatorColor)ls_borderColor;
- (LSAnimatorFloat)ls_borderWidth;
- (LSAnimatorFloat)ls_cornerRadius;
- (LSAnimatorFloat)ls_scale;
- (LSAnimatorFloat)ls_scaleX;
- (LSAnimatorFloat)ls_scaleY;
- (LSAnimatorPoint)ls_anchor;

// Moves
// Affects views position and bounds
- (LSAnimatorFloat)ls_moveX;
- (LSAnimatorFloat)ls_moveY;
- (LSAnimatorPoint)ls_moveXY;
- (LSAnimatorPolarCoordinate)ls_movePolar;

// Increments
// Affects views position and bounds
- (LSAnimatorFloat)ls_increWidth;
- (LSAnimatorFloat)ls_increHeight;
- (LSAnimatorSize)ls_increSize;

// Transforms
// Affects views transform property NOT position and bounds
// These should be used for AutoLayout
// These should NOT be mixed with properties that affect position and bounds
- (UIView *)ls_transformIdentity;
- (LSAnimatorDegrees)ls_rotate; // Same as rotateZ
- (LSAnimatorDegrees)ls_rotateX;
- (LSAnimatorDegrees)ls_rotateY;
- (LSAnimatorDegrees)ls_rotateZ;
- (LSAnimatorFloat)ls_transformX;
- (LSAnimatorFloat)ls_transformY;
- (LSAnimatorFloat)ls_transformZ;
- (LSAnimatorPoint)ls_transformXY;
- (LSAnimatorFloat)ls_transformScale; // x and y equal
- (LSAnimatorFloat)ls_transformScaleX;
- (LSAnimatorFloat)ls_transformScaleY;


#pragma mark - Bezier Paths
// Animation effects dont apply
- (LSAnimatorBezierPath)ls_moveOnPath;
- (LSAnimatorBezierPath)ls_moveAndRotateOnPath;
- (LSAnimatorBezierPath)ls_moveAndReverseRotateOnPath;


#pragma mark - Anchor
- (UIView *)ls_anchorDefault;
- (UIView *)ls_anchorCenter;
- (UIView *)ls_anchorTop;
- (UIView *)ls_anchorBottom;
- (UIView *)ls_anchorLeft;
- (UIView *)ls_anchorRight;
- (UIView *)ls_anchorTopLeft;
- (UIView *)ls_anchorTopRight;
- (UIView *)ls_anchorBottomLeft;
- (UIView *)ls_anchorBottomRight;


#pragma mark - Animation Effect Functions
- (UIView *)ls_easeIn;
- (UIView *)ls_easeOut;
- (UIView *)ls_easeInOut;
- (UIView *)ls_easeBack;
- (UIView *)ls_spring;
- (UIView *)ls_bounce;
- (UIView *)ls_easeInQuad;
- (UIView *)ls_easeOutQuad;
- (UIView *)ls_easeInOutQuad;
- (UIView *)ls_easeInCubic;
- (UIView *)ls_easeOutCubic;
- (UIView *)ls_easeInOutCubic;
- (UIView *)ls_easeInQuart;
- (UIView *)ls_easeOutQuart;
- (UIView *)ls_easeInOutQuart;
- (UIView *)ls_easeInQuint;
- (UIView *)ls_easeOutQuint;
- (UIView *)ls_easeInOutQuint;
- (UIView *)ls_easeInSine;
- (UIView *)ls_easeOutSine;
- (UIView *)ls_easeInOutSine;
- (UIView *)ls_easeInExpo;
- (UIView *)ls_easeOutExpo;
- (UIView *)ls_easeInOutExpo;
- (UIView *)ls_easeInCirc;
- (UIView *)ls_easeOutCirc;
- (UIView *)ls_easeInOutCirc;
- (UIView *)ls_easeInElastic;
- (UIView *)ls_easeOutElastic;
- (UIView *)ls_easeInOutElastic;
- (UIView *)ls_easeInBack;
- (UIView *)ls_easeOutBack;
- (UIView *)ls_easeInOutBack;
- (UIView *)ls_easeInBounce;
- (UIView *)ls_easeOutBounce;
- (UIView *)ls_easeInOutBounce;


#pragma mark - Blocks
// Allows handling in in context of the animation state
- (LSAnimatorBlock)ls_preAnimationBlock;
- (LSAnimatorBlock)ls_postAnimationBlock;
- (LSFinalAnimatorCompletion)ls_theFinalCompletion;


#pragma mark - Animator Delay
- (LSAnimatorTimeInterval)ls_delay;
- (LSAnimatorTimeInterval)ls_wait;


#pragma mark - Animator Controls
- (LSAnimatorRepeatAnimation)ls_repeat;
- (LSAnimatorTimeInterval)ls_thenAfter;
- (LSAnimatorAnimation)ls_animate;
- (LSAnimatorAnimationWithRepeat)ls_animateWithRepeat;
- (LSAnimatorAnimationWithCompletion)ls_animateWithCompletion;


#pragma mark - Multi-chain
- (UIView *)ls_concurrent;

@end
