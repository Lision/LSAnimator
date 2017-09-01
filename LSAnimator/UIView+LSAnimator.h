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
@property (nonatomic, copy, readonly) LSAnimatorRect ls_frame;
@property (nonatomic, copy, readonly) LSAnimatorRect ls_bounds;
@property (nonatomic, copy, readonly) LSAnimatorSize ls_size;
@property (nonatomic, copy, readonly) LSAnimatorPoint ls_origin;
@property (nonatomic, copy, readonly) LSAnimatorPoint ls_center;
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_x;
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_y;
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_width;
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_height;
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_opacity;
@property (nonatomic, copy, readonly) LSAnimatorColor ls_background;
@property (nonatomic, copy, readonly) LSAnimatorColor ls_borderColor;
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_borderWidth;
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_cornerRadius;
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_scale;
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_scaleX;
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_scaleY;
@property (nonatomic, copy, readonly) LSAnimatorPoint ls_anchor;

// Moves
// Affects views position and bounds
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_moveX;
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_moveY;
@property (nonatomic, copy, readonly) LSAnimatorPoint ls_moveXY;
@property (nonatomic, copy, readonly) LSAnimatorPolarCoordinate ls_movePolar;

// Increments
// Affects views position and bounds
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_increWidth;
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_increHeight;
@property (nonatomic, copy, readonly) LSAnimatorSize ls_increSize;

// Transforms
// Affects views transform property NOT position and bounds
// These should be used for AutoLayout
// These should NOT be mixed with properties that affect position and bounds
- (UIView *)ls_transformIdentity;

@property (nonatomic, copy, readonly) LSAnimatorDegrees ls_rotate; // Same as rotateZ
@property (nonatomic, copy, readonly) LSAnimatorDegrees ls_rotateX;
@property (nonatomic, copy, readonly) LSAnimatorDegrees ls_rotateY;
@property (nonatomic, copy, readonly) LSAnimatorDegrees ls_rotateZ;
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_transformX;
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_transformY;
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_transformZ;
@property (nonatomic, copy, readonly) LSAnimatorPoint ls_transformXY;
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_transformScale; // x and y equal
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_transformScaleX;
@property (nonatomic, copy, readonly) LSAnimatorFloat ls_transformScaleY;


#pragma mark - Bezier Paths
// Animation effects dont apply
@property (nonatomic, copy, readonly) LSAnimatorBezierPath ls_moveOnPath;
@property (nonatomic, copy, readonly) LSAnimatorBezierPath ls_moveAndRotateOnPath;
@property (nonatomic, copy, readonly) LSAnimatorBezierPath ls_moveAndReverseRotateOnPath;


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
@property (nonatomic, copy, readonly) LSAnimatorBlock ls_preAnimationBlock;
@property (nonatomic, copy, readonly) LSAnimatorBlock ls_postAnimationBlock;
@property (nonatomic, copy, readonly) LSFinalAnimatorCompletion ls_theFinalCompletion;


#pragma mark - Animator Delay
@property (nonatomic, copy, readonly) LSAnimatorTimeInterval ls_delay;
@property (nonatomic, copy, readonly) LSAnimatorTimeInterval ls_wait;


#pragma mark - Animator Controls
@property (nonatomic, copy, readonly) LSAnimatorRepeatAnimation ls_repeat;
@property (nonatomic, copy, readonly) LSAnimatorTimeInterval ls_thenAfter;
@property (nonatomic, copy, readonly) LSAnimatorAnimation ls_animate;
@property (nonatomic, copy, readonly) LSAnimatorAnimationWithRepeat ls_animateWithRepeat;
@property (nonatomic, copy, readonly) LSAnimatorAnimationWithCompletion ls_animateWithCompletion;


#pragma mark - Multi-chain
- (UIView *)ls_concurrent;

@end
