//
//  LSAnimator.h
//  LSAnimator
//
//  Created by Lision on 2017/12/28.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSAnimatorBlocks.h"

#if __has_include(<LSAnimator/LSAnimator.h>)

//! Project version number for LSAnimator.
FOUNDATION_EXPORT double LSAnimatorVersionNumber;

//! Project version string for LSAnimator.
FOUNDATION_EXPORT const unsigned char LSAnimatorVersionString[];

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
// Makes
// Affects views position and bounds
@property (nonatomic, copy, readonly) LSAnimatorRect makeFrame;
@property (nonatomic, copy, readonly) LSAnimatorRect makeBounds;
@property (nonatomic, copy, readonly) LSAnimatorSize makeSize;
@property (nonatomic, copy, readonly) LSAnimatorPoint makeOrigin;
@property (nonatomic, copy, readonly) LSAnimatorPoint makePosition;
@property (nonatomic, copy, readonly) LSAnimatorFloat makeX;
@property (nonatomic, copy, readonly) LSAnimatorFloat makeY;
@property (nonatomic, copy, readonly) LSAnimatorFloat makeWidth;
@property (nonatomic, copy, readonly) LSAnimatorFloat makeHeight;
@property (nonatomic, copy, readonly) LSAnimatorFloat makeOpacity;
@property (nonatomic, copy, readonly) LSAnimatorColor makeBackground;
@property (nonatomic, copy, readonly) LSAnimatorColor makeBorderColor;
@property (nonatomic, copy, readonly) LSAnimatorFloat makeBorderWidth;
@property (nonatomic, copy, readonly) LSAnimatorFloat makeCornerRadius;
@property (nonatomic, copy, readonly) LSAnimatorFloat makeScale;
@property (nonatomic, copy, readonly) LSAnimatorFloat makeScaleX;
@property (nonatomic, copy, readonly) LSAnimatorFloat makeScaleY;
@property (nonatomic, copy, readonly) LSAnimatorPoint makeAnchor;

// Moves
// Affects views position and bounds
@property (nonatomic, copy, readonly) LSAnimatorFloat moveX;
@property (nonatomic, copy, readonly) LSAnimatorFloat moveY;
@property (nonatomic, copy, readonly) LSAnimatorPoint moveXY;
@property (nonatomic, copy, readonly) LSAnimatorPolarCoordinate movePolar;

// Increments
// Affects views position and bounds
@property (nonatomic, copy, readonly) LSAnimatorFloat increWidth;
@property (nonatomic, copy, readonly) LSAnimatorFloat increHeight;
@property (nonatomic, copy, readonly) LSAnimatorSize increSize;

// Transforms
// Affects views transform property NOT position and bounds
// These should be used for AutoLayout
// These should NOT be mixed with properties that affect position and bounds
- (LSAnimator *)transformIdentity;
@property (nonatomic, copy, readonly) LSAnimatorDegrees rotate; // Same as rotateZ
@property (nonatomic, copy, readonly) LSAnimatorDegrees rotateX;
@property (nonatomic, copy, readonly) LSAnimatorDegrees rotateY;
@property (nonatomic, copy, readonly) LSAnimatorDegrees rotateZ;
@property (nonatomic, copy, readonly) LSAnimatorFloat transformX;
@property (nonatomic, copy, readonly) LSAnimatorFloat transformY;
@property (nonatomic, copy, readonly) LSAnimatorFloat transformZ;
@property (nonatomic, copy, readonly) LSAnimatorPoint transformXY;
@property (nonatomic, copy, readonly) LSAnimatorFloat transformScale; // x and y equal
@property (nonatomic, copy, readonly) LSAnimatorFloat transformScaleX;
@property (nonatomic, copy, readonly) LSAnimatorFloat transformScaleY;


#pragma mark - Bezier Paths
// Animation effects dont apply
@property (nonatomic, copy, readonly) LSAnimatorBezierPath moveOnPath;
@property (nonatomic, copy, readonly) LSAnimatorBezierPath moveAndRotateOnPath;
@property (nonatomic, copy, readonly) LSAnimatorBezierPath moveAndReverseRotateOnPath;


#pragma mark - Anchor
- (LSAnimator *)anchorDefault;
- (LSAnimator *)anchorCenter;
- (LSAnimator *)anchorTop;
- (LSAnimator *)anchorBottom;
- (LSAnimator *)anchorLeft;
- (LSAnimator *)anchorRight;
- (LSAnimator *)anchorTopLeft;
- (LSAnimator *)anchorTopRight;
- (LSAnimator *)anchorBottomLeft;
- (LSAnimator *)anchorBottomRight;


#pragma mark - Animation Effect Functions
- (LSAnimator *)easeIn;
- (LSAnimator *)easeOut;
- (LSAnimator *)easeInOut;
- (LSAnimator *)easeBack;
- (LSAnimator *)spring;
- (LSAnimator *)bounce;
- (LSAnimator *)easeInQuad;
- (LSAnimator *)easeOutQuad;
- (LSAnimator *)easeInOutQuad;
- (LSAnimator *)easeInCubic;
- (LSAnimator *)easeOutCubic;
- (LSAnimator *)easeInOutCubic;
- (LSAnimator *)easeInQuart;
- (LSAnimator *)easeOutQuart;
- (LSAnimator *)easeInOutQuart;
- (LSAnimator *)easeInQuint;
- (LSAnimator *)easeOutQuint;
- (LSAnimator *)easeInOutQuint;
- (LSAnimator *)easeInSine;
- (LSAnimator *)easeOutSine;
- (LSAnimator *)easeInOutSine;
- (LSAnimator *)easeInExpo;
- (LSAnimator *)easeOutExpo;
- (LSAnimator *)easeInOutExpo;
- (LSAnimator *)easeInCirc;
- (LSAnimator *)easeOutCirc;
- (LSAnimator *)easeInOutCirc;
- (LSAnimator *)easeInElastic;
- (LSAnimator *)easeOutElastic;
- (LSAnimator *)easeInOutElastic;
- (LSAnimator *)easeInBack;
- (LSAnimator *)easeOutBack;
- (LSAnimator *)easeInOutBack;
- (LSAnimator *)easeInBounce;
- (LSAnimator *)easeOutBounce;
- (LSAnimator *)easeInOutBounce;


#pragma mark - Blocks
// Allows handling in in context of the animation state
@property (nonatomic, copy, readonly) LSAnimatorBlock preAnimationBlock;
@property (nonatomic, copy, readonly) LSAnimatorBlock postAnimationBlock;
@property (nonatomic, copy, readonly) LSFinalAnimatorCompletion theFinalCompletion;


#pragma mark - Animator Delay
@property (nonatomic, copy, readonly) LSAnimatorTimeInterval delay;
@property (nonatomic, copy, readonly) LSAnimatorTimeInterval wait;


#pragma mark - Animator Controls
@property (nonatomic, copy, readonly) LSAnimatorRepeatAnimation repeat;
@property (nonatomic, copy, readonly) LSAnimatorTimeInterval thenAfter;
@property (nonatomic, copy, readonly) LSAnimatorAnimation animate;
@property (nonatomic, copy, readonly) LSAnimatorAnimationWithRepeat animateWithRepeat;
@property (nonatomic, copy, readonly) LSAnimatorAnimationWithCompletion animateWithCompletion;


#pragma mark - Multi-chain
- (LSAnimator *)concurrent;

@end

NS_ASSUME_NONNULL_END
