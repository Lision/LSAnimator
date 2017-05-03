//
//  UIView+LSAnimator.m
//  LSAnimator
//
//  Created by Lision on 2017/4/30.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+LSAnimator.h"
#import "LSKeyframeAnimationFunctions.h"
#import "LSKeyframeAnimation.h"
#import "LSAnimatorLinker.h"
#import "LSAnimatorChain.h"

#define force_inline __inline__ __attribute__((always_inline))

#define ls_degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )
#define ls_radiansToDegrees( radians ) ( ( radians ) * ( 180.0 / M_PI ) )

static NSString * const kLSAnimatorKey = @"LSAnimatorKey";

typedef void (^LSAnimatorCompleteBlock)();

static force_inline NSString *LSAnimatorChainAnimationKey(NSInteger index) {
    return [NSString stringWithFormat:@"%@_%@", kLSAnimatorKey, @(index)];
}

@interface UIView (LSAnimator_Private)

#pragma mark - Properties
@property (nonatomic, copy) LSAnimatorCompleteBlock ls_finalCompleteBlock;
@property (nonatomic, strong) NSMutableArray <LSAnimatorChain *> *ls_animatorChains;

#pragma mark - Methods
- (LSKeyframeAnimation *)ls_basicAnimationForKeyPath:(NSString *)keypath;

- (void)ls_addAnimation:(LSKeyframeAnimation *)animation withAnimatorChain:(LSAnimatorChain *)animatorChain;
- (void)ls_addAnimationCalculationAction:(LSAnimationCalculationAction)action;
- (void)ls_addAnimationCompletionAction:(LSAnimationCompletionAction)action;
- (void)ls_addAnimationKeyframeFunctionBlock:(LSKeyframeAnimationFunctionBlock)functionBlock;

- (void)ls_updateAnchorWithPoint:(CGPoint)anchorPoint;
- (CGPoint)ls_newPositionFromNewFrame:(CGRect)newRect;
- (CGPoint)ls_newPositionFromNewOrigin:(CGPoint)newOrigin;
- (CGPoint)ls_newPositionFromNewCenter:(CGPoint)newCenter;

- (void)ls_animateWithAnimatorChain:(LSAnimatorChain *)animatorChain;

@end

@implementation UIView (LSAnimator_Private)

#pragma mark - Properties
- (void)setLs_finalCompleteBlock:(LSAnimatorCompleteBlock)ls_finalCompleteBlock {
    objc_setAssociatedObject(self, @selector(ls_finalCompleteBlock), ls_finalCompleteBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (LSAnimatorCompleteBlock)ls_finalCompleteBlock {
    return objc_getAssociatedObject(self, @selector(ls_finalCompleteBlock));
}

- (void)setLs_animatorChains:(NSMutableArray<LSAnimatorChain *> *)ls_animatorChains {
    objc_setAssociatedObject(self, @selector(ls_animatorChains), ls_animatorChains, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray<LSAnimatorChain *> *)ls_animatorChains {
    NSMutableArray<LSAnimatorChain *> *ls_animatorChains = objc_getAssociatedObject(self, @selector(ls_animatorChains));
    if (!ls_animatorChains) {
        ls_animatorChains = [NSMutableArray arrayWithObject:[LSAnimatorChain chainWithView:self]];
        [self setLs_animatorChains:ls_animatorChains];
    }
    
    return ls_animatorChains;
}

#pragma mark - Methods
- (LSKeyframeAnimation *)ls_basicAnimationForKeyPath:(NSString *)keypath {
    LSKeyframeAnimation *animation = [LSKeyframeAnimation animationWithKeyPath:keypath];
    animation.repeatCount = 0;
    animation.autoreverses = NO;
    
    return animation;
}

- (void)ls_addAnimation:(LSKeyframeAnimation *)animation withAnimatorChain:(LSAnimatorChain *)animatorChain {
    [animatorChain ls_addAnimation:animation];
}

- (void)ls_addAnimationKeyframeFunctionBlock:(LSKeyframeAnimationFunctionBlock)functionBlock {
    [self ls_addAnimationCalculationAction:^(__weak UIView *view, __weak LSAnimatorChain *animatorChain) {
        [animatorChain ls_addAnimationFunctionBlock:functionBlock];
    }];
}

- (void)ls_addAnimationCalculationAction:(LSAnimationCalculationAction)action {
    [[self.ls_animatorChains lastObject] ls_addAnimationCalculationAction:action];
}

- (void)ls_addAnimationCompletionAction:(LSAnimationCompletionAction)action {
    [[self.ls_animatorChains lastObject] ls_addAnimationCompletionAction:action];
}

- (void)ls_updateAnchorWithPoint:(CGPoint)anchorPoint {
    LSAnimationCalculationAction action = ^void(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
        if (CGPointEqualToPoint(anchorPoint, weakSelf.layer.anchorPoint)) {
            return;
        }
        CGPoint newPoint = CGPointMake(weakSelf.bounds.size.width * anchorPoint.x,
                                       weakSelf.bounds.size.height * anchorPoint.y);
        CGPoint oldPoint = CGPointMake(weakSelf.bounds.size.width * weakSelf.layer.anchorPoint.x,
                                       weakSelf.bounds.size.height * weakSelf.layer.anchorPoint.y);
        
        newPoint = CGPointApplyAffineTransform(newPoint, weakSelf.transform);
        oldPoint = CGPointApplyAffineTransform(oldPoint, weakSelf.transform);
        
        CGPoint position = weakSelf.layer.position;
        
        position.x -= oldPoint.x;
        position.x += newPoint.x;
        
        position.y -= oldPoint.y;
        position.y += newPoint.y;
        
        weakSelf.layer.position = position;
        weakSelf.layer.anchorPoint = anchorPoint;
    };
    
    [[self.ls_animatorChains lastObject] ls_updateAnchorWithAction:action];
}

- (CGPoint)ls_newPositionFromNewFrame:(CGRect)newRect {
    CGPoint anchor = self.layer.anchorPoint;
    CGSize size = newRect.size;
    CGPoint newPosition;
    newPosition.x = newRect.origin.x + anchor.x * size.width;
    newPosition.y = newRect.origin.y + anchor.y * size.height;
    
    return newPosition;
}

- (CGPoint)ls_newPositionFromNewOrigin:(CGPoint)newOrigin {
    CGPoint anchor = self.layer.anchorPoint;
    CGSize size = self.bounds.size;
    CGPoint newPosition;
    newPosition.x = newOrigin.x + anchor.x * size.width;
    newPosition.y = newOrigin.y + anchor.y * size.height;
    
    return newPosition;
}

- (CGPoint)ls_newPositionFromNewCenter:(CGPoint)newCenter {
    CGPoint anchor = self.layer.anchorPoint;
    CGSize size = self.bounds.size;
    CGPoint newPosition;
    newPosition.x = newCenter.x + (anchor.x - 0.5) * size.width;
    newPosition.y = newCenter.y + (anchor.y - 0.5) * size.height;
    
    return newPosition;
}

- (void)ls_animateWithAnimatorChain:(LSAnimatorChain *)animatorChain {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setCompletionBlock:^{
        [self.layer removeAnimationForKey:LSAnimatorChainAnimationKey([self.ls_animatorChains indexOfObject:animatorChain])];
        [self ls_chainLinkerDidFinishAnimationsWithAnimatorChain:animatorChain];
    }];
    [self ls_animateLinkWithAnimatorChain:animatorChain];
    [CATransaction commit];
    [self ls_executeAnimationCompletionActionsWithAnimatorChain:animatorChain];
}

- (void)ls_chainLinkerDidFinishAnimationsWithAnimatorChain:(LSAnimatorChain *)animatorChain {
    if ([animatorChain ls_isEmptiedAfterTryToRemoveCurrentTurnLinker]) {
        [self.ls_animatorChains removeObject:animatorChain];
        if (!self.ls_animatorChains.count) {
            [self.ls_animatorChains addObject:[LSAnimatorChain chainWithView:self]];
            
            if (self.ls_finalCompleteBlock) {
                LSAnimatorCompleteBlock finalCompleteBlock = self.ls_finalCompleteBlock;
                self.ls_finalCompleteBlock = nil;
                finalCompleteBlock();
            }
        }
    } else {
        [self ls_animateWithAnimatorChain:animatorChain];
    }
}

- (void)ls_animateLinkWithAnimatorChain:(LSAnimatorChain *)animatorChain {
    NSAssert([self.ls_animatorChains containsObject:animatorChain], @"LSANIMATOR ERROR: ANIMATORCHAINS DO NOT CONTAINS OBJECT CURRENT ANIMATORCHAIN");
    
    [self ls_updateAnchorWithPoint:CGPointMake(0.5, 0.5)];
    [animatorChain ls_animateWithWithAnimationKey:LSAnimatorChainAnimationKey([self.ls_animatorChains indexOfObject:animatorChain])];
}

- (void)ls_executeAnimationCompletionActionsWithAnimatorChain:(LSAnimatorChain *)animatorChain {
    [animatorChain ls_executeCompletionActions];
}

@end

@implementation UIView (LSAnimator)

#pragma mark - Animator Kinds
- (LSAnimatorRect)ls_frame {
    LSAnimatorRect animator = LSAnimatorRect(rect) {
        return self.ls_origin(rect.origin.x, rect.origin.y).ls_bounds(rect);
    };
    
    return animator;
}

- (LSAnimatorRect)ls_bounds {
    LSAnimatorRect animator = LSAnimatorRect(rect) {
        return self.ls_size(rect.size.width, rect.size.height);
    };
    
    return animator;
}

- (LSAnimatorSize)ls_size {
    LSAnimatorSize animator = LSAnimatorSize(width, height) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.layer.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(width, height)];
            [weakSelf ls_addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, width, height);
            weakSelf.layer.bounds = bounds;
            weakSelf.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPoint)ls_origin {
    LSAnimatorPoint animator = LSAnimatorPoint(x, y) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position"];
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(x, y)];
            positionAnimation.fromValue = [NSValue valueWithCGPoint:weakSelf.layer.position];
            positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(x, y)];
            weakSelf.layer.position = newPosition;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPoint)ls_center {
    LSAnimatorPoint animator = LSAnimatorPoint(x, y) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position"];
            CGPoint newPosition = [weakSelf ls_newPositionFromNewCenter:CGPointMake(x, y)];
            positionAnimation.fromValue = [NSValue valueWithCGPoint:weakSelf.layer.position];
            positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            weakSelf.center = CGPointMake(x, y);
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_x {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position.x"];
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(f, weakSelf.layer.frame.origin.y)];
            positionAnimation.fromValue = @(weakSelf.layer.position.x);
            positionAnimation.toValue = @(newPosition.x);
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(f, weakSelf.layer.frame.origin.y)];
            weakSelf.layer.position = newPosition;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_y {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position.y"];
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(weakSelf.layer.frame.origin.x, f)];
            positionAnimation.fromValue = @(weakSelf.layer.position.y);
            positionAnimation.toValue = @(newPosition.y);
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(weakSelf.layer.frame.origin.x, f)];
            weakSelf.layer.position = newPosition;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_width {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.layer.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(f, weakSelf.frame.size.height)];
            [weakSelf ls_addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, f, weakSelf.frame.size.height);
            weakSelf.layer.bounds = bounds;
            weakSelf.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_height {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.layer.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(weakSelf.frame.size.width, f)];
            [weakSelf ls_addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, weakSelf.frame.size.width, f);
            weakSelf.layer.bounds = bounds;
            weakSelf.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_opacity {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *opacityAnimation = [weakSelf ls_basicAnimationForKeyPath:@"opacity"];
            opacityAnimation.fromValue = @(weakSelf.alpha);
            opacityAnimation.toValue = @(f);
            [weakSelf ls_addAnimation:opacityAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            weakSelf.alpha = f;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorColor)ls_background {
    LSAnimatorColor animator = LSAnimatorColor(color) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *colorAnimation = [weakSelf ls_basicAnimationForKeyPath:@"backgroundColor"];
            colorAnimation.fromValue = weakSelf.backgroundColor;
            colorAnimation.toValue = color;
            [weakSelf ls_addAnimation:colorAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            weakSelf.layer.backgroundColor = color.CGColor;
            weakSelf.backgroundColor = color;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorColor)ls_borderColor {
    LSAnimatorColor animator = LSAnimatorColor(color) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *colorAnimation = [weakSelf ls_basicAnimationForKeyPath:@"borderColor"];
            UIColor *borderColor = (__bridge UIColor *)(weakSelf.layer.borderColor);
            colorAnimation.fromValue = borderColor;
            colorAnimation.toValue = color;
            [weakSelf ls_addAnimation:colorAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            weakSelf.layer.borderColor = color.CGColor;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_borderWidth {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        f = MAX(0, f);
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *borderAnimation = [weakSelf ls_basicAnimationForKeyPath:@"borderWidth"];
            borderAnimation.fromValue = @(weakSelf.layer.borderWidth);
            borderAnimation.toValue = @(f);
            [weakSelf ls_addAnimation:borderAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            weakSelf.layer.borderWidth = f;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_cornerRadius {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        f = MAX(0, f);
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *cornerAnimation = [weakSelf ls_basicAnimationForKeyPath:@"cornerRadius"];
            cornerAnimation.fromValue = @(weakSelf.layer.cornerRadius);
            cornerAnimation.toValue = @(f);
            [weakSelf ls_addAnimation:cornerAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            weakSelf.layer.cornerRadius = f;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_scale {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *boundsAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds"];
            CGRect rect = CGRectMake(0, 0, MAX(weakSelf.bounds.size.width*f, 0), MAX(weakSelf.bounds.size.height*f, 0));
            boundsAnimation.fromValue = [NSValue valueWithCGRect:weakSelf.layer.bounds];
            boundsAnimation.toValue = [NSValue valueWithCGRect:rect];
            [weakSelf ls_addAnimation:boundsAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CGRect rect = CGRectMake(0, 0, MAX(weakSelf.bounds.size.width*f, 0), MAX(weakSelf.bounds.size.height*f, 0));
            weakSelf.layer.bounds = rect;
            weakSelf.bounds = rect;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_scaleX {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *boundsAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds"];
            CGRect rect = CGRectMake(0, 0, MAX(weakSelf.bounds.size.width*f, 0), weakSelf.bounds.size.height);
            boundsAnimation.fromValue = [NSValue valueWithCGRect:weakSelf.layer.bounds];
            boundsAnimation.toValue = [NSValue valueWithCGRect:rect];
            [weakSelf ls_addAnimation:boundsAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CGRect rect = CGRectMake(0, 0, MAX(weakSelf.bounds.size.width*f, 0), weakSelf.bounds.size.height);
            weakSelf.layer.bounds = rect;
            weakSelf.bounds = rect;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_scaleY {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *boundsAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds"];
            CGRect rect = CGRectMake(0, 0, weakSelf.bounds.size.width, MAX(weakSelf.bounds.size.height*f, 0));
            boundsAnimation.fromValue = [NSValue valueWithCGRect:weakSelf.layer.bounds];
            boundsAnimation.toValue = [NSValue valueWithCGRect:rect];
            [weakSelf ls_addAnimation:boundsAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CGRect rect = CGRectMake(0, 0, weakSelf.bounds.size.width, MAX(weakSelf.bounds.size.height*f, 0));
            weakSelf.layer.bounds = rect;
            weakSelf.bounds = rect;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPoint)ls_anchor {
    LSAnimatorPoint animator = LSAnimatorPoint(x, y) {
        [self ls_updateAnchorWithPoint:CGPointMake(x, y)];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_moveX {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position.x"];
            positionAnimation.fromValue = @(weakSelf.layer.position.x);
            positionAnimation.toValue = @(weakSelf.layer.position.x + f);
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CGPoint position = weakSelf.layer.position;
            position.x += f;
            weakSelf.layer.position = position;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_moveY {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position.y"];
            positionAnimation.fromValue = @(weakSelf.layer.position.y);
            positionAnimation.toValue = @(weakSelf.layer.position.y + f);
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CGPoint position = weakSelf.layer.position;
            position.y += f;
            weakSelf.layer.position = position;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPoint)ls_moveXY {
    LSAnimatorPoint animator = LSAnimatorPoint(x, y) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position"];
            CGPoint oldOrigin = weakSelf.layer.frame.origin;
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(oldOrigin.x + x, oldOrigin.y + y)];
            positionAnimation.fromValue = [NSValue valueWithCGPoint:weakSelf.layer.position];
            positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CGPoint position = weakSelf.layer.position;
            position.x +=x; position.y += y;
            weakSelf.layer.position = position;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPolarCoordinate)ls_movePolar {
    LSAnimatorPolarCoordinate animator = LSAnimatorPolarCoordinate(radius, angle) {
        CGFloat x = radius * cosf(ls_degreesToRadians(angle));
        CGFloat y = -radius * sinf(ls_degreesToRadians(angle));
        
        return self.ls_moveXY(x, y);
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_increWidth {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.layer.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(MAX(weakSelf.bounds.size.width + f, 0), weakSelf.bounds.size.height)];
            [weakSelf ls_addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, MAX(weakSelf.bounds.size.width+f, 0), weakSelf.bounds.size.height);
            weakSelf.layer.bounds = bounds;
            weakSelf.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_increHeight {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.layer.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(weakSelf.bounds.size.width, MAX(weakSelf.bounds.size.height + f, 0))];
            [weakSelf ls_addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, weakSelf.bounds.size.width, MAX(weakSelf.bounds.size.height+f, 0));
            weakSelf.layer.bounds = bounds;
            weakSelf.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorSize)ls_increSize {
    LSAnimatorSize animator = LSAnimatorSize(width, height) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.layer.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(weakSelf.bounds.size.width + width, MAX(weakSelf.bounds.size.height + height, 0))];
            [weakSelf ls_addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, MAX(weakSelf.bounds.size.width+width, 0), MAX(weakSelf.bounds.size.height+height, 0));
            weakSelf.layer.bounds = bounds;
            weakSelf.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (UIView *)ls_transformIdentity {
    [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
        LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
        CATransform3D transform = CATransform3DIdentity;
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
        [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
    }];
    [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
        CATransform3D transform = CATransform3DIdentity;
        weakSelf.layer.transform = transform;
    }];
    
    return self;
}

- (LSAnimatorDegrees)ls_rotate {
    return [self ls_rotateZ];
}

- (LSAnimatorDegrees)ls_rotateX {
    LSAnimatorDegrees animator = LSAnimatorDegrees(angle) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *rotationAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform.rotation.x"];
            CATransform3D transform = weakSelf.layer.transform;
            CGFloat originalRotation = atan2(transform.m23, transform.m22);
            rotationAnimation.fromValue = @(originalRotation);
            rotationAnimation.toValue = @(originalRotation + ls_degreesToRadians(angle));
            [weakSelf ls_addAnimation:rotationAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            CGFloat originalRotation = atan2(transform.m23, transform.m22);
            CATransform3D xRotation = CATransform3DMakeRotation(ls_degreesToRadians(angle)+originalRotation, 1.0, 0, 0);
            weakSelf.layer.transform = xRotation;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorDegrees)ls_rotateY {
    LSAnimatorDegrees animator = LSAnimatorDegrees(angle) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *rotationAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform.rotation.y"];
            CATransform3D transform = weakSelf.layer.transform;
            CGFloat originalRotation = atan2(transform.m31, transform.m33);
            rotationAnimation.fromValue = @(originalRotation);
            rotationAnimation.toValue = @(originalRotation + ls_degreesToRadians(angle));
            [weakSelf ls_addAnimation:rotationAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            CGFloat originalRotation = atan2(transform.m31, transform.m33);
            CATransform3D yRotation = CATransform3DMakeRotation(ls_degreesToRadians(angle)+originalRotation, 0, 1.0, 0);
            weakSelf.layer.transform = yRotation;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorDegrees)ls_rotateZ {
    LSAnimatorDegrees animator = LSAnimatorDegrees(angle) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *rotationAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform.rotation.z"];
            CATransform3D transform = weakSelf.layer.transform;
            CGFloat originalRotation = atan2(transform.m12, transform.m11);
            rotationAnimation.fromValue = @(originalRotation);
            rotationAnimation.toValue = @(originalRotation + ls_degreesToRadians(angle));
            [weakSelf ls_addAnimation:rotationAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            CGFloat originalRotation = atan2(transform.m12, transform.m11);
            CATransform3D zRotation = CATransform3DMakeRotation(ls_degreesToRadians(angle) + originalRotation, 0, 0, 1.0);
            weakSelf.layer.transform = zRotation;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_transformX {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, f, 0, 0);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, f, 0, 0);
            weakSelf.layer.transform = transform;
        }];
        
        return self;
    };
    return animator;
}

- (LSAnimatorFloat)ls_transformY {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, 0, f, 0);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, 0, f, 0);
            weakSelf.layer.transform = transform;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_transformZ {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, 0, 0, f);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, 0, 0, f);
            weakSelf.layer.transform = transform;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPoint)ls_transformXY {
    LSAnimatorPoint animator = LSAnimatorPoint(x, y) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, x, y, 0);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, x, y, 0);
            weakSelf.layer.transform = transform;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_transformScale {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DScale(transform, f, f, 1);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DScale(transform, f, f, 1);
            weakSelf.layer.transform = transform;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_transformScaleX {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DScale(transform, f, 1, 1);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DScale(transform, f, 1, 1);
            weakSelf.layer.transform = transform;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)ls_transformScaleY {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DScale(transform, 1, f, 1);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DScale(transform, 1, f, 1);
            weakSelf.layer.transform = transform;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorBezierPath)ls_moveOnPath {
    LSAnimatorBezierPath animator = LSAnimatorBezierPath(path) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *pathAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position"];
            pathAnimation.path = path.CGPath;
            [weakSelf ls_addAnimation:pathAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CGPoint endPoint = path.currentPoint;
            weakSelf.layer.position = endPoint;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorBezierPath)ls_moveAndRotateOnPath {
    LSAnimatorBezierPath animator = LSAnimatorBezierPath(path) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *pathAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position"];
            pathAnimation.path = path.CGPath;
            pathAnimation.rotationMode = kCAAnimationRotateAuto;
            [weakSelf ls_addAnimation:pathAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CGPoint endPoint = path.currentPoint;
            weakSelf.layer.position = endPoint;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorBezierPath)ls_moveAndReverseRotateOnPath {
    LSAnimatorBezierPath animator = LSAnimatorBezierPath(path) {
        [self ls_addAnimationCalculationAction:^(__weak UIView *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *pathAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position"];
            pathAnimation.path = path.CGPath;
            pathAnimation.rotationMode = kCAAnimationRotateAutoReverse;
            [weakSelf ls_addAnimation:pathAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak UIView *weakSelf) {
            CGPoint endPoint = path.currentPoint;
            weakSelf.layer.position = endPoint;
        }];
        
        return self;
    };
    
    return animator;
}

- (UIView *)ls_anchorDefault {
    return self.ls_anchorCenter;
}

- (UIView *)ls_anchorCenter {
    [self ls_updateAnchorWithPoint:CGPointMake(0.5, 0.5)];
    
    return self;
}

- (UIView *)ls_anchorTop {
    [self ls_updateAnchorWithPoint:CGPointMake(0.5, 0.0)];
    
    return self;
}

- (UIView *)ls_anchorBottom {
    [self ls_updateAnchorWithPoint:CGPointMake(0.5, 1.0)];
    
    return self;
}

- (UIView *)ls_anchorLeft {
    [self ls_updateAnchorWithPoint:CGPointMake(0.0, 0.5)];
    
    return self;
}

- (UIView *)ls_anchorRight {
    [self ls_updateAnchorWithPoint:CGPointMake(1.0, 0.5)];
    
    return self;
}

- (UIView *)ls_anchorTopLeft {
    [self ls_updateAnchorWithPoint:CGPointMake(0.0, 0.0)];
    
    return self;
}

- (UIView *)ls_anchorTopRight {
    [self ls_updateAnchorWithPoint:CGPointMake(1.0, 0.0)];
    
    return self;
}

- (UIView *)ls_anchorBottomLeft {
    [self ls_updateAnchorWithPoint:CGPointMake(0.0, 1.0)];
    
    return self;
}

- (UIView *)ls_anchorBottomRight {
    [self ls_updateAnchorWithPoint:CGPointMake(1.0, 1.0)];
    
    return self;
}

#pragma mark - Animator Effects
- (UIView *)ls_easeIn {
    return self.ls_easeInQuad;
}

- (UIView *)ls_easeOut {
    return self.ls_easeOutQuad;
}

- (UIView *)ls_easeInOut {
    return self.ls_easeInOutQuad;
}

- (UIView *)ls_easeBack {
    return self.ls_easeOutBack;
}

- (UIView *)ls_spring {
    return self.ls_easeOutElastic;
}

- (UIView *)ls_bounce {
    return self.ls_easeOutBounce;
}

- (UIView *)ls_easeInQuad {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInQuad(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeOutQuad {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutQuad(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInOutQuad {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutQuad(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInCubic {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInCubic(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeOutCubic {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutCubic(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInOutCubic {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutCubic(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInQuart {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInQuart(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeOutQuart {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutQuart(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInOutQuart {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutQuart(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInQuint {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInQuint(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeOutQuint {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutQuint(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInOutQuint {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutQuint(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInSine {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInSine(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeOutSine {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutSine(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInOutSine {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutSine(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInExpo {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInExpo(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeOutExpo {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutExpo(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInOutExpo {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutExpo(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInCirc {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInCirc(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeOutCirc {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutCirc(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInOutCirc {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutCirc(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInElastic {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInElastic(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeOutElastic {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutElastic(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInOutElastic {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutElastic(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInBack {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInBack(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeOutBack {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutBack(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInOutBack {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutBack(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInBounce {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInBounce(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeOutBounce {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutBounce(t, b, c, d);
    }];
    
    return self;
}

- (UIView *)ls_easeInOutBounce {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutBounce(t, b, c, d);
    }];
    
    return self;
}

#pragma mark - Blocks
- (LSAnimatorBlock)ls_preAnimationBlock {
    LSAnimatorBlock animator = LSAnimatorBlock(block) {
        [[self.ls_animatorChains lastObject] ls_updateBeforeCurrentLinkerAnimationBlock:block];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorBlock)ls_postAnimationBlock {
    LSAnimatorBlock animator = LSAnimatorBlock(block) {
        [[self.ls_animatorChains lastObject] ls_updateAfterCurrentLinkerAnimationBlock:block];
        
        return self;
    };
    
    return animator;
}

- (LSFinalAnimatorCompletion)ls_theFinalCompletion {
    LSFinalAnimatorCompletion animator = LSFinalAnimatorCompletion(block) {
        self.ls_finalCompleteBlock = block;
    };
    
    return animator;
}

- (LSAnimatorTimeInterval)ls_delay {
    LSAnimatorTimeInterval animator = LSAnimatorTimeInterval(t) {
        [[self.ls_animatorChains lastObject] ls_updateCurrentTurnLinkerAnimationsDelay:t];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorTimeInterval)ls_wait {
    LSAnimatorTimeInterval animator = LSAnimatorTimeInterval(t) {
        return self.ls_delay(t);
    };
    
    return animator;
}

#pragma mark - Animator Controls
- (LSAnimatorRepeatAnimation)ls_repeat {
    LSAnimatorRepeatAnimation animator = LSAnimatorRepeatAnimation(duration, count) {
        [[self.ls_animatorChains lastObject] ls_updateCurrentTurnLinkerAnimationsDuration:duration];
        [[self.ls_animatorChains lastObject] ls_repeat:count andIsAnimation:NO];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorTimeInterval)ls_thenAfter {
    LSAnimatorTimeInterval animator = LSAnimatorTimeInterval(t) {
        [[self.ls_animatorChains lastObject] ls_thenAfter:t];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorAnimation)ls_animate {
    LSAnimatorAnimation animator = LSAnimatorAnimation(duration) {
        [[self.ls_animatorChains lastObject] ls_updateCurrentTurnLinkerAnimationsDuration:duration];
        [self ls_animateWithAnimatorChain:[self.ls_animatorChains lastObject]];
    };
    
    return animator;
}

- (LSAnimatorAnimationWithRepeat)ls_animateWithRepeat {
    LSAnimatorAnimationWithRepeat animator = LSAnimatorAnimationWithRepeat(duration, count) {
        [[self.ls_animatorChains lastObject] ls_updateCurrentTurnLinkerAnimationsDuration:duration];
        [[self.ls_animatorChains lastObject] ls_repeat:count andIsAnimation:YES];
        [self ls_animateWithAnimatorChain:[self.ls_animatorChains lastObject]];
    };
    
    return animator;
}

- (LSAnimatorAnimationWithCompletion)ls_animateWithCompletion {
    LSAnimatorAnimationWithCompletion animator = LSAnimatorAnimationWithCompletion(duration, completion) {
        [[self.ls_animatorChains lastObject] ls_updateCurrentTurnLinkerAnimationsDuration:duration];
        [self.ls_animatorChains lastObject].completeBlock = completion;
        [self ls_animateWithAnimatorChain:[self.ls_animatorChains lastObject]];
    };
    
    return animator;
}

- (UIView *)ls_concurrent {
    [self.ls_animatorChains addObject:[LSAnimatorChain chainWithView:self]];
    
    return self;
}

@end
