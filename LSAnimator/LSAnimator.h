//
//  LSAnimator.h
//  LSAnimator
//
//  Created by Lision on 2017/5/3.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LSAnimatorBlocks.h"

#if __has_include(<LSAnimator/LSAnimator.h>)

FOUNDATION_EXPORT double LSAnimatorVersionNumber;
FOUNDATION_EXPORT const unsigned char LSAnimatorVersionString[];

#else

#endif

NS_ASSUME_NONNULL_BEGIN

@interface LSAnimator : NSObject

@property (nonatomic, weak, readonly) CALayer *layer;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

+ (instancetype)animatorWithView:(UIView *)view;
- (instancetype)initWithView:(UIView *)view;

+ (instancetype)animatorWithLayer:(CALayer *)layer;
- (instancetype)initWithLayer:(CALayer *)layer NS_DESIGNATED_INITIALIZER;


#pragma mark - Animations
// Properties
// Affects views position and bounds
@property (nonatomic, copy, readonly) LSAnimatorRect ls_frame;
@property (nonatomic, copy, readonly) LSAnimatorRect ls_bounds;
@property (nonatomic, copy, readonly) LSAnimatorSize ls_size;
@property (nonatomic, copy, readonly) LSAnimatorPoint ls_origin;
@property (nonatomic, copy, readonly) LSAnimatorPoint ls_position;
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
- (LSAnimator *)ls_transformIdentity;
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
- (LSAnimator *)ls_anchorDefault;
- (LSAnimator *)ls_anchorCenter;
- (LSAnimator *)ls_anchorTop;
- (LSAnimator *)ls_anchorBottom;
- (LSAnimator *)ls_anchorLeft;
- (LSAnimator *)ls_anchorRight;
- (LSAnimator *)ls_anchorTopLeft;
- (LSAnimator *)ls_anchorTopRight;
- (LSAnimator *)ls_anchorBottomLeft;
- (LSAnimator *)ls_anchorBottomRight;


#pragma mark - Animation Effect Functions
- (LSAnimator *)ls_easeIn;
- (LSAnimator *)ls_easeOut;
- (LSAnimator *)ls_easeInOut;
- (LSAnimator *)ls_easeBack;
- (LSAnimator *)ls_spring;
- (LSAnimator *)ls_bounce;
- (LSAnimator *)ls_easeInQuad;
- (LSAnimator *)ls_easeOutQuad;
- (LSAnimator *)ls_easeInOutQuad;
- (LSAnimator *)ls_easeInCubic;
- (LSAnimator *)ls_easeOutCubic;
- (LSAnimator *)ls_easeInOutCubic;
- (LSAnimator *)ls_easeInQuart;
- (LSAnimator *)ls_easeOutQuart;
- (LSAnimator *)ls_easeInOutQuart;
- (LSAnimator *)ls_easeInQuint;
- (LSAnimator *)ls_easeOutQuint;
- (LSAnimator *)ls_easeInOutQuint;
- (LSAnimator *)ls_easeInSine;
- (LSAnimator *)ls_easeOutSine;
- (LSAnimator *)ls_easeInOutSine;
- (LSAnimator *)ls_easeInExpo;
- (LSAnimator *)ls_easeOutExpo;
- (LSAnimator *)ls_easeInOutExpo;
- (LSAnimator *)ls_easeInCirc;
- (LSAnimator *)ls_easeOutCirc;
- (LSAnimator *)ls_easeInOutCirc;
- (LSAnimator *)ls_easeInElastic;
- (LSAnimator *)ls_easeOutElastic;
- (LSAnimator *)ls_easeInOutElastic;
- (LSAnimator *)ls_easeInBack;
- (LSAnimator *)ls_easeOutBack;
- (LSAnimator *)ls_easeInOutBack;
- (LSAnimator *)ls_easeInBounce;
- (LSAnimator *)ls_easeOutBounce;
- (LSAnimator *)ls_easeInOutBounce;


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
- (LSAnimator *)ls_concurrent;

@end

NS_ASSUME_NONNULL_END
