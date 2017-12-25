//
//  LSAnimatorChain.h
//  LSAnimator
//
//  Created by Lision on 2017/4/30.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LSAnimatorLinker.h"

NS_ASSUME_NONNULL_BEGIN

@class LSKeyframeAnimation;

typedef void (^LSAnimatorChainCompleteBlock)();

@interface LSAnimatorChain : NSObject

@property (nonatomic, weak) CALayer *layer;
@property (nonatomic, copy) LSAnimatorChainCompleteBlock completeBlock;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

+ (instancetype)chainWithLayer:(CALayer *)layer;
- (instancetype)initWithLayer:(CALayer *)layer NS_DESIGNATED_INITIALIZER;

- (void)updateAnchorWithAction:(LSAnimationCalculationAction)action;

- (void)addAnimation:(LSKeyframeAnimation *)animation;
- (void)addAnimationFunctionBlock:(LSKeyframeAnimationFunctionBlock)functionBlock;
- (void)addAnimationCalculationAction:(LSAnimationCalculationAction)action;
- (void)addAnimationCompletionAction:(LSAnimationCompletionAction)action;

- (void)updateBeforeCurrentLinkerAnimationBlock:(LSAnimatorLinkerBlock)block;
- (void)updateAfterCurrentLinkerAnimationBlock:(LSAnimatorLinkerBlock)block;

- (void)thenAfter:(NSTimeInterval)time;
- (void)repeat:(NSInteger)count andIsAnimation:(BOOL)isAnimation;
- (void)updateCurrentTurnLinkerAnimationsDelay:(NSTimeInterval)delay;
- (void)updateCurrentTurnLinkerAnimationsDuration:(NSTimeInterval)duration;

- (void)animateWithWithAnimationKey:(NSString *)animationKey;
- (void)executeCompletionActions;
- (BOOL)isEmptiedAfterTryToRemoveCurrentTurnLinker;

@end

NS_ASSUME_NONNULL_END
