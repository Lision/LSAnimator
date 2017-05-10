//
//  LSAnimatorChain.m
//  LSAnimator
//
//  Created by Lision on 2017/4/30.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import "LSAnimatorChain.h"

@interface LSAnimatorChain ()

@property (nonatomic, strong) NSMutableArray <LSAnimatorLinker *> *ls_animatorLinkers;

@end

@implementation LSAnimatorChain

+ (instancetype)chainWithLayer:(CALayer *)layer {
    return [[self alloc] initWithLayer:layer];
}

- (instancetype)initWithLayer:(CALayer *)layer {
    if (self = [super init]) {
        _layer = layer;
    }
    
    return self;
}

- (NSMutableArray<LSAnimatorLinker *> *)ls_animatorLinkers {
    if (!_ls_animatorLinkers) {
        _ls_animatorLinkers = [NSMutableArray arrayWithObject:[LSAnimatorLinker linkerWithLayer:self.layer andAnimatorChain:self]];
    }
    
    return _ls_animatorLinkers;
}

- (void)ls_updateAnchorWithAction:(LSAnimationCalculationAction)action {
    [self.ls_animatorLinkers lastObject].anchorCalculationAction = action;
}

- (void)ls_addAnimation:(LSKeyframeAnimation *)animation {
    [[self.ls_animatorLinkers firstObject] ls_addAnimation:animation];
}

- (void)ls_addAnimationFunctionBlock:(LSKeyframeAnimationFunctionBlock)functionBlock {
    [[self.ls_animatorLinkers firstObject] ls_addAnimationFunctionBlock:functionBlock];
}

- (void)ls_addAnimationCalculationAction:(LSAnimationCalculationAction)action {
    [[self.ls_animatorLinkers lastObject] ls_addAnimationCalculationAction:action];
}

- (void)ls_addAnimationCompletionAction:(LSAnimationCompletionAction)action {
    [[self.ls_animatorLinkers lastObject] ls_addAnimationCompletionAction:action];
}

- (void)ls_updateBeforeCurrentLinkerAnimationBlock:(LSAnimatorLinkerBlock)block {
    [self.ls_animatorLinkers lastObject].beforelinkerBlock = block;
}

- (void)ls_updateAfterCurrentLinkerAnimationBlock:(LSAnimatorLinkerBlock)block {
    [self.ls_animatorLinkers lastObject].afterLinkerBlock = block;
}

- (void)ls_thenAfter:(NSTimeInterval)time {
    [self ls_updateCurrentTurnLinkerAnimationsDuration:time];
    [self.ls_animatorLinkers addObject:[LSAnimatorLinker linkerWithLayer:self.layer andAnimatorChain:self]];
}

- (void)ls_repeat:(NSInteger)count andIsAnimation:(BOOL)isAnimation {
    for (NSInteger index = 0; index < count - 1; index++) {
        LSAnimatorLinker *animatorLinker = [[self.ls_animatorLinkers lastObject] copy];
        [self.ls_animatorLinkers addObject:animatorLinker];
    }
    
    if (!isAnimation) {
        [self.ls_animatorLinkers addObject:[LSAnimatorLinker linkerWithLayer:self.layer andAnimatorChain:self]];
    }
}

- (void)ls_updateCurrentTurnLinkerAnimationsDelay:(NSTimeInterval)delay {
    [self.ls_animatorLinkers lastObject].animationDelay = delay;
}

- (void)ls_updateCurrentTurnLinkerAnimationsDuration:(NSTimeInterval)duration {
    [self.ls_animatorLinkers lastObject].animationDuration = duration;
}

- (void)ls_animateWithWithAnimationKey:(NSString *)animationKey {
    [[self.ls_animatorLinkers firstObject] ls_animateWithAnimationKey:animationKey];
}

- (void)ls_executeCompletionActions {
    [[self.ls_animatorLinkers firstObject] ls_executeCompletionActions];
}

- (BOOL)ls_isEmptiedAfterTryToRemoveCurrentTurnLinker {
    if (self.ls_animatorLinkers.count) {
        [[self.ls_animatorLinkers firstObject] ls_executeAfterLinkerBlock];
        [self.ls_animatorLinkers removeObjectAtIndex:0];
    }
    
    if (self.ls_animatorLinkers.count) {
        return NO;
    } else {
        if (self.completeBlock) {
            self.completeBlock();
        }
        
        return YES;
    }
}

@end
