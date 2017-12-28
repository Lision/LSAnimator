//
//  LSBlocks.h
//  LSAnimator
//
//  Created by Lision on 2017/4/30.
//  Copyright © 2017年 Lision. All rights reserved.
//

#ifndef LSBlocks_h
#define LSBlocks_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class LSAnimator;

#pragma mark - LSAnimator Blocks
typedef LSAnimator * (^LSAnimatorRect)(CGRect rect);
#define LSAnimatorRect(rect) ^LSAnimator * (CGRect rect)

typedef LSAnimator * (^LSAnimatorSize)(CGFloat width, CGFloat height);
#define LSAnimatorSize(width,height) ^LSAnimator * (CGFloat width, CGFloat height)

typedef LSAnimator * (^LSAnimatorPoint)(CGFloat x, CGFloat y);
#define LSAnimatorPoint(x,y) ^LSAnimator * (CGFloat x, CGFloat y)

typedef LSAnimator * (^LSAnimatorFloat)(CGFloat f);
#define LSAnimatorFloat(f) ^LSAnimator * (CGFloat f)

typedef LSAnimator * (^LSAnimatorColor)(UIColor *color);
#define LSAnimatorColor(color) ^LSAnimator * (UIColor *color)

typedef LSAnimator * (^LSAnimatorPolarCoordinate)(CGFloat radius, CGFloat angle);
#define LSAnimatorPolarCoordinate(radius,angle) ^LSAnimator * (CGFloat radius, CGFloat angle)

typedef LSAnimator * (^LSAnimatorDegrees)(CGFloat angle);
#define LSAnimatorDegrees(angle) ^LSAnimator * (CGFloat angle)

typedef LSAnimator * (^LSAnimatorLayoutConstraint)(NSLayoutConstraint *constraint, CGFloat f);
#define LSAnimatorLayoutConstraint(constraint,f) ^LSAnimator * (NSLayoutConstraint *constraint, CGFloat f)

typedef LSAnimator * (^LSAnimatorBezierPath)(UIBezierPath *path);
#define LSAnimatorBezierPath(path) ^LSAnimator * (UIBezierPath *path)

typedef LSAnimator * (^LSAnimatorBlock)(void(^block)(void));
#define LSAnimatorBlock(block) ^LSAnimator * (void(^block)(void))

typedef void (^LSFinalAnimatorCompletion)(void(^block)(void));
#define LSFinalAnimatorCompletion(block) ^void (void(^block)(void))

typedef LSAnimator * (^LSAnimatorTimeInterval)(NSTimeInterval t);
#define LSAnimatorTimeInterval(t) ^LSAnimator * (NSTimeInterval t)

typedef LSAnimator * (^LSAnimatorRepeatAnimation)(NSTimeInterval duration, NSInteger count);
#define LSAnimatorRepeatAnimation(duration, count) ^LSAnimator * (NSTimeInterval duration, NSInteger count)

typedef void (^LSAnimatorAnimation)(NSTimeInterval duration);
#define LSAnimatorAnimation(duration) ^void (NSTimeInterval duration)

typedef void (^LSAnimatorAnimationWithRepeat)(NSTimeInterval duration, NSInteger count);
#define LSAnimatorAnimationWithRepeat(duration, count) ^void (NSTimeInterval duration, NSInteger count)

typedef void (^LSAnimatorAnimationWithCompletion)(NSTimeInterval duration, void(^completion)(void));
#define LSAnimatorAnimationWithCompletion(duration,completion) ^void (NSTimeInterval duration, void(^completion)(void))

#endif /* LSBlocks_h */
