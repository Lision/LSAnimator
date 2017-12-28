//
//  LSAnimatorLinker.h
//  LSAnimator
//
//  Created by Lision on 2017/4/30.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LSAnimatorBlocks.h"
#import "LSKeyframeAnimation.h"

NS_ASSUME_NONNULL_BEGIN

@class LSAnimator, LSAnimatorChain;

typedef void (^LSAnimatorLinkerBlock)(void);
typedef void (^LSAnimationCalculationAction)(__weak LSAnimator *animator, __weak LSAnimatorChain *animatorChain);
typedef void (^LSAnimationCompletionAction)(__weak LSAnimator *animator);

@interface LSAnimatorLinker : NSObject <NSCopying>

@property (nonatomic, weak) LSAnimator *animator;
@property (nonatomic, weak) LSAnimatorChain *animatorChain;
@property (nonatomic, assign) NSTimeInterval animationDelay;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, copy) LSAnimatorLinkerBlock beforelinkerBlock;
@property (nonatomic, copy) LSAnimatorLinkerBlock afterLinkerBlock;
@property (nonatomic, copy) LSAnimationCalculationAction anchorCalculationAction;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

+ (instancetype)linkerWithAnimator:(LSAnimator *)animator andAnimatorChain:(LSAnimatorChain *)animatorChain;
- (instancetype)initWithAnimator:(LSAnimator *)animator andAnimatorChain:(LSAnimatorChain *)animatorChain NS_DESIGNATED_INITIALIZER;

- (void)addAnimation:(LSKeyframeAnimation *)animation;
- (void)addAnimationFunctionBlock:(LSKeyframeAnimationFunctionBlock)functionBlock;
- (void)addAnimationCalculationAction:(LSAnimationCalculationAction)action;
- (void)addAnimationCompletionAction:(LSAnimationCompletionAction)action;

- (void)animateWithAnimationKey:(NSString *)animationKey;
- (void)executeCompletionActions;
- (void)executeAfterLinkerBlock;

@end

NS_ASSUME_NONNULL_END
