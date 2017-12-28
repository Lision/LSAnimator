//
//  LSAnimatorLinker.m
//  LSAnimator
//
//  Created by Lision on 2017/4/30.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import "LSAnimatorLinker.h"
#import "LSAnimator.h"

@interface LSAnimatorLinker ()

@property (nonatomic, strong) CAAnimationGroup *animationgroup;
@property (nonatomic, strong) NSMutableArray <LSKeyframeAnimation *> *animations;
@property (nonatomic, strong) NSMutableArray <LSAnimationCalculationAction> *animationCalculationActions;
@property (nonatomic, strong) NSMutableArray <LSAnimationCompletionAction> *animationCompletionActions;

@end

@implementation LSAnimatorLinker

+ (instancetype)linkerWithAnimator:(LSAnimator *)animator andAnimatorChain:(LSAnimatorChain *)animatorChain {
    return [[self alloc] initWithAnimator:animator andAnimatorChain:animatorChain];
}

- (instancetype)initWithAnimator:(LSAnimator *)animator andAnimatorChain:(LSAnimatorChain *)animatorChain {
    if (self = [super init]) {
        _animator = animator;
        _animatorChain = animatorChain;
    }
    
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    typeof(self) copySelf = [[self.class allocWithZone:zone] initWithAnimator:self.animator andAnimatorChain:self.animatorChain];
    copySelf.animationDelay = self.animationDelay;
    copySelf.animationDuration = self.animationDuration;
    copySelf.beforelinkerBlock = [self.beforelinkerBlock copy];
    copySelf.afterLinkerBlock = [self.afterLinkerBlock copy];
    copySelf.anchorCalculationAction = [self.anchorCalculationAction copy];
    copySelf.animationgroup = [self.animationgroup copy];
    copySelf.animations = [[NSMutableArray alloc] initWithArray:self.animations copyItems:YES];
    copySelf.animationCalculationActions = [[NSMutableArray alloc] initWithArray:self.animationCalculationActions copyItems:YES];
    copySelf.animationCompletionActions = [[NSMutableArray alloc] initWithArray:self.animationCompletionActions copyItems:YES];
    
    return copySelf;
}

- (CAAnimationGroup *)animationgroup {
    if (!_animationgroup) {
        _animationgroup = [CAAnimationGroup animation];
    }
    
    return _animationgroup;
}

- (NSMutableArray<LSKeyframeAnimation *> *)animations {
    if (!_animations) {
        _animations = [NSMutableArray array];
    }
    
    return _animations;
}

- (NSMutableArray<LSAnimationCalculationAction> *)animationCalculationActions {
    if (!_animationCalculationActions) {
        _animationCalculationActions = [NSMutableArray array];
    }
    
    return _animationCalculationActions;
}

- (NSMutableArray<LSAnimationCompletionAction> *)animationCompletionActions {
    if (!_animationCompletionActions) {
        _animationCompletionActions = [NSMutableArray array];
    }
    
    return _animationCompletionActions;
}

- (void)addAnimation:(LSKeyframeAnimation *)animation {
    [self.animations addObject:animation];
}

- (void)addAnimationFunctionBlock:(LSKeyframeAnimationFunctionBlock)functionBlock {
    [self.animations lastObject].functionBlock = functionBlock;
}

- (void)addAnimationCalculationAction:(LSAnimationCalculationAction)action {
    [self.animationCalculationActions addObject:action];
}

- (void)addAnimationCompletionAction:(LSAnimationCompletionAction)action {
    [self.animationCompletionActions addObject:action];
}

- (void)animateWithAnimationKey:(NSString *)animationKey {
    if (self.beforelinkerBlock) {
        self.beforelinkerBlock();
    }
    
    if (self.anchorCalculationAction) {
        self.anchorCalculationAction(self.animator, self.animatorChain);
    }
    
    self.animationgroup.duration = self.animationDuration;
    for (LSAnimationCalculationAction action in self.animationCalculationActions) {
        action(self.animator, self.animatorChain);
    }
    for (LSKeyframeAnimation *animation in self.animations) {
        animation.duration = self.animationgroup.duration;
        [animation calculate];
    }
    self.animationgroup.beginTime = CACurrentMediaTime() + self.animationDelay;
    self.animationgroup.animations = self.animations;
    [self.animator.layer addAnimation:self.animationgroup forKey:animationKey];
}

- (void)executeCompletionActions {
    NSTimeInterval delay = MAX(self.animationgroup.beginTime - CACurrentMediaTime(), 0.0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (LSAnimationCompletionAction action in self.animationCompletionActions) {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            action(self.animator);
            [CATransaction commit];
        }
    });
}

- (void)executeAfterLinkerBlock {
    if (self.afterLinkerBlock) {
        self.afterLinkerBlock();
    }
}

@end
