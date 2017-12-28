//
//  LSAnimatorChain.m
//  LSAnimator
//
//  Created by Lision on 2017/4/30.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import "LSAnimatorChain.h"
#import "LSAnimator.h"

@interface LSAnimatorChain ()

@property (nonatomic, strong) NSMutableArray <LSAnimatorLinker *> *animatorLinkers;

@end

@implementation LSAnimatorChain

+ (instancetype)chainWithAnimator:(LSAnimator *)animator {
    return [[self alloc] initWithAnimator:animator];
}

- (instancetype)initWithAnimator:(LSAnimator *)animator {
    if (self = [super init]) {
        _animator = animator;
    }
    
    return self;
}

- (NSMutableArray<LSAnimatorLinker *> *)animatorLinkers {
    if (!_animatorLinkers) {
        _animatorLinkers = [NSMutableArray arrayWithObject:[LSAnimatorLinker linkerWithAnimator:self.animator andAnimatorChain:self]];
    }
    
    return _animatorLinkers;
}

- (void)updateAnchorWithAction:(LSAnimationCalculationAction)action {
    [self.animatorLinkers lastObject].anchorCalculationAction = action;
}

- (void)addAnimation:(LSKeyframeAnimation *)animation {
    [[self.animatorLinkers firstObject] addAnimation:animation];
}

- (void)addAnimationFunctionBlock:(LSKeyframeAnimationFunctionBlock)functionBlock {
    [[self.animatorLinkers firstObject] addAnimationFunctionBlock:functionBlock];
}

- (void)addAnimationCalculationAction:(LSAnimationCalculationAction)action {
    [[self.animatorLinkers lastObject] addAnimationCalculationAction:action];
}

- (void)addAnimationCompletionAction:(LSAnimationCompletionAction)action {
    [[self.animatorLinkers lastObject] addAnimationCompletionAction:action];
}

- (void)updateBeforeCurrentLinkerAnimationBlock:(LSAnimatorLinkerBlock)block {
    [self.animatorLinkers lastObject].beforelinkerBlock = block;
}

- (void)updateAfterCurrentLinkerAnimationBlock:(LSAnimatorLinkerBlock)block {
    [self.animatorLinkers lastObject].afterLinkerBlock = block;
}

- (void)thenAfter:(NSTimeInterval)time {
    [self updateCurrentTurnLinkerAnimationsDuration:time];
    [self.animatorLinkers addObject:[LSAnimatorLinker linkerWithAnimator:self.animator andAnimatorChain:self]];
}

- (void)repeat:(NSInteger)count andIsAnimation:(BOOL)isAnimation {
    for (NSInteger index = 0; index < count - 1; index++) {
        LSAnimatorLinker *animatorLinker = [[self.animatorLinkers lastObject] copy];
        [self.animatorLinkers addObject:animatorLinker];
    }
    
    if (!isAnimation) {
        [self.animatorLinkers addObject:[LSAnimatorLinker linkerWithAnimator:self.animator andAnimatorChain:self]];
    }
}

- (void)updateCurrentTurnLinkerAnimationsDelay:(NSTimeInterval)delay {
    [self.animatorLinkers lastObject].animationDelay = delay;
}

- (void)updateCurrentTurnLinkerAnimationsDuration:(NSTimeInterval)duration {
    [self.animatorLinkers lastObject].animationDuration = duration;
}

- (void)animateWithAnimationKey:(NSString *)animationKey {
    [[self.animatorLinkers firstObject] animateWithAnimationKey:animationKey];
}

- (void)executeCompletionActions {
    [[self.animatorLinkers firstObject] executeCompletionActions];
}

- (BOOL)isEmptiedAfterTryToRemoveCurrentTurnLinker {
    if (self.animatorLinkers.count) {
        [[self.animatorLinkers firstObject] executeAfterLinkerBlock];
        [self.animatorLinkers removeObjectAtIndex:0];
    }
    
    if (self.animatorLinkers.count) {
        return NO;
    } else {
        if (self.completeBlock) {
            self.completeBlock();
        }
        
        return YES;
    }
}

@end
