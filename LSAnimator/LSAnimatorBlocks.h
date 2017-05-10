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

#pragma mark - CALayer Blocks
typedef CALayer * (^LSCAAnimatorRect)(CGRect rect);
#define LSCAAnimatorRect(rect) ^CALayer * (CGRect rect)

typedef CALayer * (^LSCAAnimatorSize)(CGFloat width, CGFloat height);
#define LSCAAnimatorSize(width,height) ^CALayer * (CGFloat width, CGFloat height)

typedef CALayer * (^LSCAAnimatorPoint)(CGFloat x, CGFloat y);
#define LSCAAnimatorPoint(x,y) ^CALayer * (CGFloat x, CGFloat y)

typedef CALayer * (^LSCAAnimatorFloat)(CGFloat f);
#define LSCAAnimatorFloat(f) ^CALayer * (CGFloat f)

typedef CALayer * (^LSCAAnimatorColor)(UIColor *color);
#define LSCAAnimatorColor(color) ^CALayer * (UIColor *color)

typedef CALayer * (^LSCAAnimatorPolarCoordinate)(CGFloat radius, CGFloat angle);
#define LSCAAnimatorPolarCoordinate(radius,angle) ^CALayer * (CGFloat radius, CGFloat angle)

typedef CALayer * (^LSCAAnimatorDegrees)(CGFloat angle);
#define LSCAAnimatorDegrees(angle) ^CALayer * (CGFloat angle)

typedef CALayer * (^LSCAAnimatorLayoutConstraint)(NSLayoutConstraint *constraint, CGFloat f);
#define LSCAAnimatorLayoutConstraint(constraint,f) ^CALayer * (NSLayoutConstraint *constraint, CGFloat f)

typedef CALayer * (^LSCAAnimatorBezierPath)(UIBezierPath *path);
#define LSCAAnimatorBezierPath(path) ^CALayer * (UIBezierPath *path)

typedef CALayer * (^LSCAAnimatorBlock)(void(^block)());
#define LSCAAnimatorBlock(block) ^CALayer * (void(^block)())

typedef void (^LSCAFinalAnimatorCompletion)(void(^block)());
#define LSCAFinalAnimatorCompletion(block) ^void (void(^block)())

typedef CALayer * (^LSCAAnimatorTimeInterval)(NSTimeInterval t);
#define LSCAAnimatorTimeInterval(t) ^CALayer * (NSTimeInterval t)

typedef CALayer * (^LSCAAnimatorRepeatAnimation)(NSTimeInterval duration, NSInteger count);
#define LSCAAnimatorRepeatAnimation(duration, count) ^CALayer * (NSTimeInterval duration, NSInteger count)

typedef void (^LSCAAnimatorAnimation)(NSTimeInterval duration);
#define LSCAAnimatorAnimation(duration) ^void (NSTimeInterval duration)

typedef void (^LSCAAnimatorAnimationWithRepeat)(NSTimeInterval duration, NSInteger count);
#define LSCAAnimatorAnimationWithRepeat(duration, count) ^void (NSTimeInterval duration, NSInteger count)

typedef void (^LSCAAnimatorAnimationWithCompletion)(NSTimeInterval duration, void(^completion)());
#define LSCAAnimatorAnimationWithCompletion(duration,completion) ^void (NSTimeInterval duration, void(^completion)())


#pragma mark - UIView Blocks
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
