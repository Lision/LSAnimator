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
- (instancetype)initWithLayer:(CALayer *)layer;

- (void)ls_updateAnchorWithAction:(LSAnimationCalculationAction)action;

- (void)ls_addAnimation:(LSKeyframeAnimation *)animation;
- (void)ls_addAnimationFunctionBlock:(LSKeyframeAnimationFunctionBlock)functionBlock;
- (void)ls_addAnimationCalculationAction:(LSAnimationCalculationAction)action;
- (void)ls_addAnimationCompletionAction:(LSAnimationCompletionAction)action;

- (void)ls_updateBeforeCurrentLinkerAnimationBlock:(LSAnimatorLinkerBlock)block;
- (void)ls_updateAfterCurrentLinkerAnimationBlock:(LSAnimatorLinkerBlock)block;

- (void)ls_thenAfter:(NSTimeInterval)time;
- (void)ls_repeat:(NSInteger)count andIsAnimation:(BOOL)isAnimation;
- (void)ls_updateCurrentTurnLinkerAnimationsDelay:(NSTimeInterval)delay;
- (void)ls_updateCurrentTurnLinkerAnimationsDuration:(NSTimeInterval)duration;

- (void)ls_animateWithWithAnimationKey:(NSString *)animationKey;
- (void)ls_executeCompletionActions;
- (BOOL)ls_isEmptiedAfterTryToRemoveCurrentTurnLinker;

@end

NS_ASSUME_NONNULL_END
