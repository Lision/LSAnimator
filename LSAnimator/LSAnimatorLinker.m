//
//  LSAnimatorLinker.m
//  LSAnimator
//
//  Created by Lision on 2017/4/30.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import "LSAnimatorLinker.h"


@interface LSAnimatorLinker ()

@property (strong, nonatomic) CAAnimationGroup *ls_animationgroup;
@property (strong, nonatomic) NSMutableArray <LSKeyframeAnimation *> *ls_animations;
@property (strong, nonatomic) NSMutableArray <LSAnimationCalculationAction> *ls_animationCalculationActions;
@property (strong, nonatomic) NSMutableArray <LSAnimationCompletionAction> *ls_animationCompletionActions;

@end

@implementation LSAnimatorLinker

+ (instancetype)linkerWithView:(UIView *)view andAnimatorChain:(LSAnimatorChain *)animatorChain {
    return [[self alloc] initWithView:view andAnimatorChain:animatorChain];
}

- (instancetype)initWithView:(UIView *)view andAnimatorChain:(LSAnimatorChain *)animatorChain {
    if (self = [super init]) {
        _view = view;
        _animatorChain = animatorChain;
    }
    
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    typeof(self) copySelf = [[self.class allocWithZone:zone] initWithView:self.view andAnimatorChain:self.animatorChain];
    copySelf.animationDelay = self.animationDelay;
    copySelf.animationDuration = self.animationDuration;
    copySelf.beforelinkerBlock = [self.beforelinkerBlock copy];
    copySelf.afterLinkerBlock = [self.afterLinkerBlock copy];
    copySelf.anchorCalculationAction = [self.anchorCalculationAction copy];
    copySelf.ls_animationgroup = [self.ls_animationgroup copy];
    copySelf.ls_animations = [[NSMutableArray alloc] initWithArray:self.ls_animations copyItems:YES];
    copySelf.ls_animationCalculationActions = [[NSMutableArray alloc] initWithArray:self.ls_animationCalculationActions copyItems:YES];
    copySelf.ls_animationCompletionActions = [[NSMutableArray alloc] initWithArray:self.ls_animationCompletionActions copyItems:YES];
    
    return copySelf;
}

- (CAAnimationGroup *)ls_animationgroup {
    if (!_ls_animationgroup) {
        _ls_animationgroup = [CAAnimationGroup animation];
    }
    
    return _ls_animationgroup;
}

- (NSMutableArray<LSKeyframeAnimation *> *)ls_animations {
    if (!_ls_animations) {
        _ls_animations = [NSMutableArray array];
    }
    
    return _ls_animations;
}

- (NSMutableArray<LSAnimationCalculationAction> *)ls_animationCalculationActions {
    if (!_ls_animationCalculationActions) {
        _ls_animationCalculationActions = [NSMutableArray array];
    }
    
    return _ls_animationCalculationActions;
}

- (NSMutableArray<LSAnimationCompletionAction> *)ls_animationCompletionActions {
    if (!_ls_animationCompletionActions) {
        _ls_animationCompletionActions = [NSMutableArray array];
    }
    
    return _ls_animationCompletionActions;
}

- (void)ls_addAnimation:(LSKeyframeAnimation *)animation {
    [self.ls_animations addObject:animation];
}

- (void)ls_addAnimationFunctionBlock:(LSKeyframeAnimationFunctionBlock)functionBlock {
    [self.ls_animations lastObject].functionBlock = functionBlock;
}

- (void)ls_addAnimationCalculationAction:(LSAnimationCalculationAction)action {
    [self.ls_animationCalculationActions addObject:action];
}

- (void)ls_addAnimationCompletionAction:(LSAnimationCompletionAction)action {
    [self.ls_animationCompletionActions addObject:action];
}

- (void)ls_animateWithAnimationKey:(NSString *)animationKey {
    if (self.beforelinkerBlock) {
        self.beforelinkerBlock();
    }
    
    if (self.anchorCalculationAction) {
        self.anchorCalculationAction(self.view, self.animatorChain);
    }
    
    self.ls_animationgroup.duration = self.animationDuration;
    for (LSAnimationCalculationAction action in self.ls_animationCalculationActions) {
        action(self.view, self.animatorChain);
    }
    for (LSKeyframeAnimation *animation in self.ls_animations) {
        animation.duration = self.ls_animationgroup.duration;
        [animation ls_calculate];
    }
    self.ls_animationgroup.beginTime = CACurrentMediaTime() + self.animationDelay;
    self.ls_animationgroup.animations = self.ls_animations;
    
    // change 
    if ([self.view isKindOfClass:[UIView class]]) {
        [((UIView *)self.view).layer addAnimation:self.ls_animationgroup forKey:animationKey];
    }
    
    if ([self.view isKindOfClass:[CALayer class]]) {
        [((CALayer *)self.view) addAnimation:self.ls_animationgroup forKey:animationKey];
    }
    
    
    
}

- (void)ls_executeCompletionActions {
    NSTimeInterval delay = MAX(self.ls_animationgroup.beginTime - CACurrentMediaTime(), 0.0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (LSAnimationCompletionAction action in self.ls_animationCompletionActions) {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            action(self.view);
            [CATransaction commit];
        }
    });
}

- (void)ls_executeAfterLinkerBlock {
    if (self.afterLinkerBlock) {
        self.afterLinkerBlock();
    }
}

@end
