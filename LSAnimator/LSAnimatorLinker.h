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

@class LSAnimatorChain;

typedef void (^LSAnimatorLinkerBlock)();
typedef void (^LSAnimationCalculationAction)(__weak id view, __weak LSAnimatorChain *animatorChain);
typedef void (^LSAnimationCompletionAction)(__weak id view);

@interface LSAnimatorLinker : NSObject <NSCopying>

@property (nonatomic, weak) id view;
@property (nonatomic, weak) LSAnimatorChain *animatorChain;
@property (nonatomic, assign) NSTimeInterval animationDelay;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, copy) LSAnimatorLinkerBlock beforelinkerBlock;
@property (nonatomic, copy) LSAnimatorLinkerBlock afterLinkerBlock;
@property (nonatomic, copy) LSAnimationCalculationAction anchorCalculationAction;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

+ (instancetype)linkerWithView:(id)view andAnimatorChain:(LSAnimatorChain *)animatorChain;
- (instancetype)initWithView:(id)view andAnimatorChain:(LSAnimatorChain *)animatorChain;

- (void)ls_addAnimation:(LSKeyframeAnimation *)animation;
- (void)ls_addAnimationFunctionBlock:(LSKeyframeAnimationFunctionBlock)functionBlock;
- (void)ls_addAnimationCalculationAction:(LSAnimationCalculationAction)action;
- (void)ls_addAnimationCompletionAction:(LSAnimationCompletionAction)action;

- (void)ls_animateWithAnimationKey:(NSString *)animationKey;
- (void)ls_executeCompletionActions;
- (void)ls_executeAfterLinkerBlock;

@end

NS_ASSUME_NONNULL_END
