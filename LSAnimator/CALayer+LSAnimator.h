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
- (LSCAAnimatorRect)ls_frame;
- (LSCAAnimatorRect)ls_bounds;
- (LSCAAnimatorSize)ls_size;
- (LSCAAnimatorPoint)ls_origin;
- (LSCAAnimatorPoint)ls_position;
- (LSCAAnimatorFloat)ls_x;
- (LSCAAnimatorFloat)ls_y;
- (LSCAAnimatorFloat)ls_width;
- (LSCAAnimatorFloat)ls_height;
- (LSCAAnimatorFloat)ls_opacity;
- (LSCAAnimatorColor)ls_background;
- (LSCAAnimatorColor)ls_borderColor;
- (LSCAAnimatorFloat)ls_borderWidth;
- (LSCAAnimatorFloat)ls_cornerRadius;
- (LSCAAnimatorFloat)ls_scale;
- (LSCAAnimatorFloat)ls_scaleX;
- (LSCAAnimatorFloat)ls_scaleY;
- (LSCAAnimatorPoint)ls_anchor;

// Moves
// Affects views position and bounds
- (LSCAAnimatorFloat)ls_moveX;
- (LSCAAnimatorFloat)ls_moveY;
- (LSCAAnimatorPoint)ls_moveXY;
- (LSCAAnimatorPolarCoordinate)ls_movePolar;

// Increments
// Affects views position and bounds
- (LSCAAnimatorFloat)ls_increWidth;
- (LSCAAnimatorFloat)ls_increHeight;
- (LSCAAnimatorSize)ls_increSize;

// Transforms
// Affects views transform property NOT position and bounds
// These should be used for AutoLayout
// These should NOT be mixed with properties that affect position and bounds
- (CALayer *)ls_transformIdentity;
- (LSCAAnimatorDegrees)ls_rotate; // Same as rotateZ
- (LSCAAnimatorDegrees)ls_rotateX;
- (LSCAAnimatorDegrees)ls_rotateY;
- (LSCAAnimatorDegrees)ls_rotateZ;
- (LSCAAnimatorFloat)ls_transformX;
- (LSCAAnimatorFloat)ls_transformY;
- (LSCAAnimatorFloat)ls_transformZ;
- (LSCAAnimatorPoint)ls_transformXY;
- (LSCAAnimatorFloat)ls_transformScale; // x and y equal
- (LSCAAnimatorFloat)ls_transformScaleX;
- (LSCAAnimatorFloat)ls_transformScaleY;


#pragma mark - Bezier Paths
// Animation effects dont apply
- (LSCAAnimatorBezierPath)ls_moveOnPath;
- (LSCAAnimatorBezierPath)ls_moveAndRotateOnPath;
- (LSCAAnimatorBezierPath)ls_moveAndReverseRotateOnPath;


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
- (LSCAAnimatorBlock)ls_preAnimationBlock;
- (LSCAAnimatorBlock)ls_postAnimationBlock;
- (LSFinalAnimatorCompletion)ls_theFinalCompletion;


#pragma mark - Animator Delay
- (LSCAAnimatorTimeInterval)ls_delay;
- (LSCAAnimatorTimeInterval)ls_wait;


#pragma mark - Animator Controls
- (LSCAAnimatorRepeatAnimation)ls_repeat;
- (LSCAAnimatorTimeInterval)ls_thenAfter;
- (LSCAAnimatorAnimation)ls_animate;
- (LSCAAnimatorAnimationWithRepeat)ls_animateWithRepeat;
- (LSCAAnimatorAnimationWithCompletion)ls_animateWithCompletion;


#pragma mark - Multi-chain
- (CALayer *)ls_concurrent;

@end
