//
//  CALayer+LSAnimator.h
//  LSAnimatorDemo
//
//  Created by 谢俊逸 on 07/05/2017.
//  Copyright © 2017 Lision. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LSAnimatorBlocks.h"

@interface CALayer (LSAnimator)

#pragma mark - Animations
// Properties
// Affects views position and bounds
@property (nonatomic, copy, readonly) LSCAAnimatorRect ls_frame;
@property (nonatomic, copy, readonly) LSCAAnimatorRect ls_bounds;
@property (nonatomic, copy, readonly) LSCAAnimatorSize ls_size;
@property (nonatomic, copy, readonly) LSCAAnimatorPoint ls_origin;
@property (nonatomic, copy, readonly) LSCAAnimatorPoint ls_position;
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_x;
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_y;
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_width;
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_height;
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_opacity;
@property (nonatomic, copy, readonly) LSCAAnimatorColor ls_background;
@property (nonatomic, copy, readonly) LSCAAnimatorColor ls_borderColor;
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_borderWidth;
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_cornerRadius;
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_scale;
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_scaleX;
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_scaleY;
@property (nonatomic, copy, readonly) LSCAAnimatorPoint ls_anchor;

// Moves
// Affects views position and bounds
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_moveX;
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_moveY;
@property (nonatomic, copy, readonly) LSCAAnimatorPoint ls_moveXY;
@property (nonatomic, copy, readonly) LSCAAnimatorPolarCoordinate ls_movePolar;

// Increments
// Affects views position and bounds
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_increWidth;
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_increHeight;
@property (nonatomic, copy, readonly) LSCAAnimatorSize ls_increSize;

// Transforms
// Affects views transform property NOT position and bounds
// These should be used for AutoLayout
// These should NOT be mixed with properties that affect position and bounds
- (CALayer *)ls_transformIdentity;

@property (nonatomic, copy, readonly) LSCAAnimatorDegrees ls_rotate; // Same as rotateZ
@property (nonatomic, copy, readonly) LSCAAnimatorDegrees ls_rotateX;
@property (nonatomic, copy, readonly) LSCAAnimatorDegrees ls_rotateY;
@property (nonatomic, copy, readonly) LSCAAnimatorDegrees ls_rotateZ;
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_transformX;
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_transformY;
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_transformZ;
@property (nonatomic, copy, readonly) LSCAAnimatorPoint ls_transformXY;
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_transformScale; // x and y equal
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_transformScaleX;
@property (nonatomic, copy, readonly) LSCAAnimatorFloat ls_transformScaleY;


#pragma mark - Bezier Paths
// Animation effects dont apply
@property (nonatomic, copy, readonly) LSCAAnimatorBezierPath ls_moveOnPath;
@property (nonatomic, copy, readonly) LSCAAnimatorBezierPath ls_moveAndRotateOnPath;
@property (nonatomic, copy, readonly) LSCAAnimatorBezierPath ls_moveAndReverseRotateOnPath;


#pragma mark - Anchor
- (CALayer *)ls_anchorDefault;
- (CALayer *)ls_anchorCenter;
- (CALayer *)ls_anchorTop;
- (CALayer *)ls_anchorBottom;
- (CALayer *)ls_anchorLeft;
- (CALayer *)ls_anchorRight;
- (CALayer *)ls_anchorTopLeft;
- (CALayer *)ls_anchorTopRight;
- (CALayer *)ls_anchorBottomLeft;
- (CALayer *)ls_anchorBottomRight;


#pragma mark - Animation Effect Functions
- (CALayer *)ls_easeIn;
- (CALayer *)ls_easeOut;
- (CALayer *)ls_easeInOut;
- (CALayer *)ls_easeBack;
- (CALayer *)ls_spring;
- (CALayer *)ls_bounce;
- (CALayer *)ls_easeInQuad;
- (CALayer *)ls_easeOutQuad;
- (CALayer *)ls_easeInOutQuad;
- (CALayer *)ls_easeInCubic;
- (CALayer *)ls_easeOutCubic;
- (CALayer *)ls_easeInOutCubic;
- (CALayer *)ls_easeInQuart;
- (CALayer *)ls_easeOutQuart;
- (CALayer *)ls_easeInOutQuart;
- (CALayer *)ls_easeInQuint;
- (CALayer *)ls_easeOutQuint;
- (CALayer *)ls_easeInOutQuint;
- (CALayer *)ls_easeInSine;
- (CALayer *)ls_easeOutSine;
- (CALayer *)ls_easeInOutSine;
- (CALayer *)ls_easeInExpo;
- (CALayer *)ls_easeOutExpo;
- (CALayer *)ls_easeInOutExpo;
- (CALayer *)ls_easeInCirc;
- (CALayer *)ls_easeOutCirc;
- (CALayer *)ls_easeInOutCirc;
- (CALayer *)ls_easeInElastic;
- (CALayer *)ls_easeOutElastic;
- (CALayer *)ls_easeInOutElastic;
- (CALayer *)ls_easeInBack;
- (CALayer *)ls_easeOutBack;
- (CALayer *)ls_easeInOutBack;
- (CALayer *)ls_easeInBounce;
- (CALayer *)ls_easeOutBounce;
- (CALayer *)ls_easeInOutBounce;


#pragma mark - Blocks
// Allows handling in in context of the animation state
@property (nonatomic, copy, readonly) LSCAAnimatorBlock ls_preAnimationBlock;
@property (nonatomic, copy, readonly) LSCAAnimatorBlock ls_postAnimationBlock;
@property (nonatomic, copy, readonly) LSCAFinalAnimatorCompletion ls_theFinalCompletion;


#pragma mark - Animator Delay
@property (nonatomic, copy, readonly) LSCAAnimatorTimeInterval ls_delay;
@property (nonatomic, copy, readonly) LSCAAnimatorTimeInterval ls_wait;


#pragma mark - Animator Controls
@property (nonatomic, copy, readonly) LSCAAnimatorRepeatAnimation ls_repeat;
@property (nonatomic, copy, readonly) LSCAAnimatorTimeInterval ls_thenAfter;
@property (nonatomic, copy, readonly) LSCAAnimatorAnimation ls_animate;
@property (nonatomic, copy, readonly) LSCAAnimatorAnimationWithRepeat ls_animateWithRepeat;
@property (nonatomic, copy, readonly) LSCAAnimatorAnimationWithCompletion ls_animateWithCompletion;


#pragma mark - Multi-chain
- (CALayer *)ls_concurrent;

@end
