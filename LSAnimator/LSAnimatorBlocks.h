//
//  LSBlocks.h
//  LSAnimator
//
//  Created by Lision on 2017/4/30.
//  Copyright © 2017年 Lision. All rights reserved.
//

#ifndef LSBlocks_h
#define LSBlocks_h

typedef UIView * (^LSAnimatorRect)(CGRect rect);
#define LSAnimatorRect(rect) ^UIView * (CGRect rect)

typedef UIView * (^LSAnimatorSize)(CGFloat width, CGFloat height);
#define LSAnimatorSize(width,height) ^UIView * (CGFloat width, CGFloat height)

typedef UIView * (^LSAnimatorPoint)(CGFloat x, CGFloat y);
#define LSAnimatorPoint(x,y) ^UIView * (CGFloat x, CGFloat y)

typedef UIView * (^LSAnimatorFloat)(CGFloat f);
#define LSAnimatorFloat(f) ^UIView * (CGFloat f)

typedef UIView * (^LSAnimatorColor)(UIColor *color);
#define LSAnimatorColor(color) ^UIView * (UIColor *color)

typedef UIView * (^LSAnimatorPolarCoordinate)(CGFloat radius, CGFloat angle);
#define LSAnimatorPolarCoordinate(radius,angle) ^UIView * (CGFloat radius, CGFloat angle)

typedef UIView * (^LSAnimatorDegrees)(CGFloat angle);
#define LSAnimatorDegrees(angle) ^UIView * (CGFloat angle)

typedef UIView * (^LSAnimatorLayoutConstraint)(NSLayoutConstraint *constraint, CGFloat f);
#define LSAnimatorLayoutConstraint(constraint,f) ^UIView * (NSLayoutConstraint *constraint, CGFloat f)

typedef UIView * (^LSAnimatorBezierPath)(UIBezierPath *path);
#define LSAnimatorBezierPath(path) ^UIView * (UIBezierPath *path)

typedef UIView * (^LSAnimatorBlock)(void(^block)());
#define LSAnimatorBlock(block) ^UIView * (void(^block)())

typedef void (^LSFinalAnimatorCompletion)(void(^block)());
#define LSFinalAnimatorCompletion(block) ^void (void(^block)())

typedef UIView * (^LSAnimatorTimeInterval)(NSTimeInterval t);
#define LSAnimatorTimeInterval(t) ^UIView * (NSTimeInterval t)

typedef UIView * (^LSAnimatorRepeatAnimation)(NSTimeInterval duration, NSInteger count);
#define LSAnimatorRepeatAnimation(duration, count) ^UIView * (NSTimeInterval duration, NSInteger count)

typedef void (^LSAnimatorAnimation)(NSTimeInterval duration);
#define LSAnimatorAnimation(duration) ^void (NSTimeInterval duration)

typedef void (^LSAnimatorAnimationWithRepeat)(NSTimeInterval duration, NSInteger count);
#define LSAnimatorAnimationWithRepeat(duration, count) ^void (NSTimeInterval duration, NSInteger count)

typedef void (^LSAnimatorAnimationWithCompletion)(NSTimeInterval duration, void(^completion)());
#define LSAnimatorAnimationWithCompletion(duration,completion) ^void (NSTimeInterval duration, void(^completion)())

#endif /* LSBlocks_h */
