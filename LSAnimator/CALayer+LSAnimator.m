//
//  CALayer+LSCAAnimator.m
//  LSCAAnimatorDemo
//
//  Created by 谢俊逸 on 07/05/2017.
//  Copyright © 2017 Lision. All rights reserved.
//

#import <objc/runtime.h>
#import "CALayer+LSAnimator.h"
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

@interface CALayer (LSAnimator_Private)

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

- (UIColor *)ls_colorWithCGColor:(CGColorRef)cgColor;

- (void)ls_animateWithAnimatorChain:(LSAnimatorChain *)animatorChain;

@end

@implementation CALayer (LSAnimator_Private)

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
        ls_animatorChains = [NSMutableArray arrayWithObject:[LSAnimatorChain chainWithLayer:self]];
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
    [self ls_addAnimationCalculationAction:^(__weak CALayer *view, __weak LSAnimatorChain *animatorChain) {
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
    LSAnimationCalculationAction action = ^void(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
        if (CGPointEqualToPoint(anchorPoint, weakSelf.anchorPoint)) {
            return;
        }
        CGPoint newPoint = CGPointMake(weakSelf.bounds.size.width * anchorPoint.x,
                                       weakSelf.bounds.size.height * anchorPoint.y);
        CGPoint oldPoint = CGPointMake(weakSelf.bounds.size.width * weakSelf.anchorPoint.x,
                                       weakSelf.bounds.size.height * weakSelf.anchorPoint.y);
        
        newPoint = CGPointApplyAffineTransform(newPoint, weakSelf.affineTransform);
        oldPoint = CGPointApplyAffineTransform(oldPoint, weakSelf.affineTransform);
        
        CGPoint position = weakSelf.position;
        
        position.x -= oldPoint.x;
        position.x += newPoint.x;
        
        position.y -= oldPoint.y;
        position.y += newPoint.y;
        
        weakSelf.position = position;
        weakSelf.anchorPoint = anchorPoint;
    };
    
    [[self.ls_animatorChains lastObject] ls_updateAnchorWithAction:action];
}

- (CGPoint)ls_newPositionFromNewFrame:(CGRect)newRect {
    CGPoint anchor = self.anchorPoint;
    CGSize size = newRect.size;
    CGPoint newPosition;
    newPosition.x = newRect.origin.x + anchor.x * size.width;
    newPosition.y = newRect.origin.y + anchor.y * size.height;
    
    return newPosition;
}

- (CGPoint)ls_newPositionFromNewOrigin:(CGPoint)newOrigin {
    CGPoint anchor = self.anchorPoint;
    CGSize size = self.bounds.size;
    CGPoint newPosition;
    newPosition.x = newOrigin.x + anchor.x * size.width;
    newPosition.y = newOrigin.y + anchor.y * size.height;
    
    return newPosition;
}

- (CGPoint)ls_newPositionFromNewCenter:(CGPoint)newCenter {
    CGPoint anchor = self.anchorPoint;
    CGSize size = self.bounds.size;
    CGPoint newPosition;
    newPosition.x = newCenter.x + (anchor.x - 0.5) * size.width;
    newPosition.y = newCenter.y + (anchor.y - 0.5) * size.height;
    
    return newPosition;
}

- (UIColor *)ls_colorWithCGColor:(CGColorRef)cgColor {
    const CGFloat *components = CGColorGetComponents(cgColor);
    if (!components) return nil;
    
    return [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:components[3]];
}

- (void)ls_animateWithAnimatorChain:(LSAnimatorChain *)animatorChain {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setCompletionBlock:^{
        [self removeAnimationForKey:LSAnimatorChainAnimationKey([self.ls_animatorChains indexOfObject:animatorChain])];
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
            [self.ls_animatorChains addObject:[LSAnimatorChain chainWithLayer:self]];
            
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
    
    [animatorChain ls_animateWithWithAnimationKey:LSAnimatorChainAnimationKey([self.ls_animatorChains indexOfObject:animatorChain])];
}

- (void)ls_executeAnimationCompletionActionsWithAnimatorChain:(LSAnimatorChain *)animatorChain {
    [animatorChain ls_executeCompletionActions];
}

@end

@implementation CALayer (LSAnimator)

#pragma mark - Animations
- (LSCAAnimatorRect)ls_frame {
    LSCAAnimatorRect animator = LSCAAnimatorRect(rect) {
        return self.ls_origin(rect.origin.x, rect.origin.y).ls_bounds(rect);
    };
    
    return animator;
}

- (LSCAAnimatorRect)ls_bounds {
    LSCAAnimatorRect animator = LSCAAnimatorRect(rect) {
        return self.ls_size(rect.size.width, rect.size.height);
    };
    
    return animator;
}

- (LSCAAnimatorSize)ls_size {
    LSCAAnimatorSize animator = LSCAAnimatorSize(width, height) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(width, height)];
            [weakSelf ls_addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, width, height);
            weakSelf.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorPoint)ls_origin {
    LSCAAnimatorPoint animator = LSCAAnimatorPoint(x, y) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position"];
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(x, y)];
            positionAnimation.fromValue = [NSValue valueWithCGPoint:weakSelf.position];
            positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(x, y)];
            weakSelf.position = newPosition;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorPoint)ls_position {
    LSCAAnimatorPoint animator = LSCAAnimatorPoint(x, y) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position"];
            CGPoint newPosition = [weakSelf ls_newPositionFromNewCenter:CGPointMake(x, y)];
            positionAnimation.fromValue = [NSValue valueWithCGPoint:weakSelf.position];
            positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            weakSelf.position = CGPointMake(x, y);
        }];
        
        return self;
    };
    return animator;
}

- (LSCAAnimatorFloat)ls_x {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position.x"];
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(f, weakSelf.frame.origin.y)];
            positionAnimation.fromValue = @(weakSelf.position.x);
            positionAnimation.toValue = @(newPosition.x);
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(f, weakSelf.frame.origin.y)];
            weakSelf.position = newPosition;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorFloat)ls_y {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position.y"];
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(weakSelf.frame.origin.x, f)];
            positionAnimation.fromValue = @(weakSelf.position.y);
            positionAnimation.toValue = @(newPosition.y);
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(weakSelf.frame.origin.x, f)];
            weakSelf.position = newPosition;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorFloat)ls_width {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(f, weakSelf.frame.size.height)];
            [weakSelf ls_addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, f, weakSelf.frame.size.height);
            weakSelf.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorFloat)ls_height {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(weakSelf.frame.size.width, f)];
            [weakSelf ls_addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, weakSelf.frame.size.width, f);
            weakSelf.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorFloat)ls_opacity {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *opacityAnimation = [weakSelf ls_basicAnimationForKeyPath:@"opacity"];
            opacityAnimation.fromValue = @(weakSelf.opacity);
            opacityAnimation.toValue = @(f);
            [weakSelf ls_addAnimation:opacityAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            weakSelf.opacity = f;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorColor)ls_background {
    LSCAAnimatorColor animator = LSCAAnimatorColor(color) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *colorAnimation = [weakSelf ls_basicAnimationForKeyPath:@"backgroundColor"];
            colorAnimation.fromValue = [self ls_colorWithCGColor:weakSelf.backgroundColor];
            colorAnimation.toValue = color;
            [weakSelf ls_addAnimation:colorAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            weakSelf.backgroundColor = color.CGColor;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorColor)ls_borderColor {
    LSCAAnimatorColor animator = LSCAAnimatorColor(color) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *colorAnimation = [weakSelf ls_basicAnimationForKeyPath:@"borderColor"];
            UIColor *borderColor = (__bridge UIColor *)(weakSelf.borderColor);
            colorAnimation.fromValue = borderColor;
            colorAnimation.toValue = color;
            [weakSelf ls_addAnimation:colorAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            weakSelf.borderColor = color.CGColor;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorFloat)ls_borderWidth {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        f = MAX(0, f);
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *borderAnimation = [weakSelf ls_basicAnimationForKeyPath:@"borderWidth"];
            borderAnimation.fromValue = @(weakSelf.borderWidth);
            borderAnimation.toValue = @(f);
            [weakSelf ls_addAnimation:borderAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            weakSelf.borderWidth = f;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorFloat)ls_cornerRadius {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        f = MAX(0, f);
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *cornerAnimation = [weakSelf ls_basicAnimationForKeyPath:@"cornerRadius"];
            cornerAnimation.fromValue = @(weakSelf.cornerRadius);
            cornerAnimation.toValue = @(f);
            [weakSelf ls_addAnimation:cornerAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            weakSelf.cornerRadius = f;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorFloat)ls_scale {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *boundsAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds"];
            CGRect rect = CGRectMake(0, 0, MAX(weakSelf.bounds.size.width*f, 0), MAX(weakSelf.bounds.size.height*f, 0));
            boundsAnimation.fromValue = [NSValue valueWithCGRect:weakSelf.bounds];
            boundsAnimation.toValue = [NSValue valueWithCGRect:rect];
            [weakSelf ls_addAnimation:boundsAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CGRect rect = CGRectMake(0, 0, MAX(weakSelf.bounds.size.width*f, 0), MAX(weakSelf.bounds.size.height*f, 0));
            weakSelf.bounds = rect;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorFloat)ls_scaleX {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *boundsAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds"];
            CGRect rect = CGRectMake(0, 0, MAX(weakSelf.bounds.size.width*f, 0), weakSelf.bounds.size.height);
            boundsAnimation.fromValue = [NSValue valueWithCGRect:weakSelf.bounds];
            boundsAnimation.toValue = [NSValue valueWithCGRect:rect];
            [weakSelf ls_addAnimation:boundsAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CGRect rect = CGRectMake(0, 0, MAX(weakSelf.bounds.size.width*f, 0), weakSelf.bounds.size.height);
            weakSelf.bounds = rect;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorFloat)ls_scaleY {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *boundsAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds"];
            CGRect rect = CGRectMake(0, 0, weakSelf.bounds.size.width, MAX(weakSelf.bounds.size.height*f, 0));
            boundsAnimation.fromValue = [NSValue valueWithCGRect:weakSelf.bounds];
            boundsAnimation.toValue = [NSValue valueWithCGRect:rect];
            [weakSelf ls_addAnimation:boundsAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CGRect rect = CGRectMake(0, 0, weakSelf.bounds.size.width, MAX(weakSelf.bounds.size.height*f, 0));
            weakSelf.bounds = rect;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorPoint)ls_anchor {
    LSCAAnimatorPoint animator = LSCAAnimatorPoint(x, y) {
        [self ls_updateAnchorWithPoint:CGPointMake(x, y)];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorFloat)ls_moveX {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position.x"];
            positionAnimation.fromValue = @(weakSelf.position.x);
            positionAnimation.toValue = @(weakSelf.position.x + f);
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CGPoint position = weakSelf.position;
            position.x += f;
            weakSelf.position = position;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorFloat)ls_moveY {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position.y"];
            positionAnimation.fromValue = @(weakSelf.position.y);
            positionAnimation.toValue = @(weakSelf.position.y + f);
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CGPoint position = weakSelf.position;
            position.y += f;
            weakSelf.position = position;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorPoint)ls_moveXY {
    LSCAAnimatorPoint animator = LSCAAnimatorPoint(x, y) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position"];
            CGPoint oldOrigin = weakSelf.frame.origin;
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(oldOrigin.x + x, oldOrigin.y + y)];
            positionAnimation.fromValue = [NSValue valueWithCGPoint:weakSelf.position];
            positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CGPoint position = weakSelf.position;
            position.x +=x; position.y += y;
            weakSelf.position = position;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorPolarCoordinate)ls_movePolar {
    LSCAAnimatorPolarCoordinate animator = LSCAAnimatorPolarCoordinate(radius, angle) {
        CGFloat x = radius * cosf(ls_degreesToRadians(angle));
        CGFloat y = -radius * sinf(ls_degreesToRadians(angle));
        
        return self.ls_moveXY(x, y);
    };
    
    return animator;
}

- (LSCAAnimatorFloat)ls_increWidth {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(MAX(weakSelf.bounds.size.width + f, 0), weakSelf.bounds.size.height)];
            [weakSelf ls_addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, MAX(weakSelf.bounds.size.width+f, 0), weakSelf.bounds.size.height);
            weakSelf.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorFloat)ls_increHeight {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(weakSelf.bounds.size.width, MAX(weakSelf.bounds.size.height + f, 0))];
            [weakSelf ls_addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, weakSelf.bounds.size.width, MAX(weakSelf.bounds.size.height+f, 0));
            weakSelf.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorSize)ls_increSize {
    LSCAAnimatorSize animator = LSCAAnimatorSize(width, height) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(weakSelf.bounds.size.width + width, MAX(weakSelf.bounds.size.height + height, 0))];
            [weakSelf ls_addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, MAX(weakSelf.bounds.size.width+width, 0), MAX(weakSelf.bounds.size.height+height, 0));
            weakSelf.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (CALayer *)ls_transformIdentity {
    [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
        LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
        CATransform3D transform = CATransform3DIdentity;
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.transform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
        [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
    }];
    [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
        CATransform3D transform = CATransform3DIdentity;
        weakSelf.transform = transform;
    }];
    
    return self;
}

- (LSCAAnimatorDegrees)ls_rotate {
    return [self ls_rotateZ];
}

- (LSCAAnimatorDegrees)ls_rotateX {
    LSCAAnimatorDegrees animator = LSCAAnimatorDegrees(angle) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *rotationAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform.rotation.x"];
            CATransform3D transform = weakSelf.transform;
            CGFloat originalRotation = atan2(transform.m23, transform.m22);
            rotationAnimation.fromValue = @(originalRotation);
            rotationAnimation.toValue = @(originalRotation + ls_degreesToRadians(angle));
            [weakSelf ls_addAnimation:rotationAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CATransform3D transform = weakSelf.transform;
            CGFloat originalRotation = atan2(transform.m23, transform.m22);
            CATransform3D xRotation = CATransform3DMakeRotation(ls_degreesToRadians(angle)+originalRotation, 1.0, 0, 0);
            weakSelf.transform = xRotation;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorDegrees)ls_rotateY {
    LSCAAnimatorDegrees animator = LSCAAnimatorDegrees(angle) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *rotationAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform.rotation.y"];
            CATransform3D transform = weakSelf.transform;
            CGFloat originalRotation = atan2(transform.m31, transform.m33);
            rotationAnimation.fromValue = @(originalRotation);
            rotationAnimation.toValue = @(originalRotation + ls_degreesToRadians(angle));
            [weakSelf ls_addAnimation:rotationAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CATransform3D transform = weakSelf.transform;
            CGFloat originalRotation = atan2(transform.m31, transform.m33);
            CATransform3D yRotation = CATransform3DMakeRotation(ls_degreesToRadians(angle)+originalRotation, 0, 1.0, 0);
            weakSelf.transform = yRotation;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorDegrees)ls_rotateZ {
    LSCAAnimatorDegrees animator = LSCAAnimatorDegrees(angle) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *rotationAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform.rotation.z"];
            CATransform3D transform = weakSelf.transform;
            CGFloat originalRotation = atan2(transform.m12, transform.m11);
            rotationAnimation.fromValue = @(originalRotation);
            rotationAnimation.toValue = @(originalRotation + ls_degreesToRadians(angle));
            [weakSelf ls_addAnimation:rotationAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CATransform3D transform = weakSelf.transform;
            CGFloat originalRotation = atan2(transform.m12, transform.m11);
            CATransform3D zRotation = CATransform3DMakeRotation(ls_degreesToRadians(angle) + originalRotation, 0, 0, 1.0);
            weakSelf.transform = zRotation;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorFloat)ls_transformX {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.transform;
            transform = CATransform3DTranslate(transform, f, 0, 0);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CATransform3D transform = weakSelf.transform;
            transform = CATransform3DTranslate(transform, f, 0, 0);
            weakSelf.transform = transform;
        }];
        
        return self;
    };
    return animator;
}

- (LSCAAnimatorFloat)ls_transformY {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.transform;
            transform = CATransform3DTranslate(transform, 0, f, 0);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CATransform3D transform = weakSelf.transform;
            transform = CATransform3DTranslate(transform, 0, f, 0);
            weakSelf.transform = transform;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorFloat)ls_transformZ {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.transform;
            transform = CATransform3DTranslate(transform, 0, 0, f);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CATransform3D transform = weakSelf.transform;
            transform = CATransform3DTranslate(transform, 0, 0, f);
            weakSelf.transform = transform;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorPoint)ls_transformXY {
    LSCAAnimatorPoint animator = LSCAAnimatorPoint(x, y) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.transform;
            transform = CATransform3DTranslate(transform, x, y, 0);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CATransform3D transform = weakSelf.transform;
            transform = CATransform3DTranslate(transform, x, y, 0);
            weakSelf.transform = transform;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorFloat)ls_transformScale {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.transform;
            transform = CATransform3DScale(transform, f, f, 1);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CATransform3D transform = weakSelf.transform;
            transform = CATransform3DScale(transform, f, f, 1);
            weakSelf.transform = transform;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorFloat)ls_transformScaleX {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.transform;
            transform = CATransform3DScale(transform, f, 1, 1);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CATransform3D transform = weakSelf.transform;
            transform = CATransform3DScale(transform, f, 1, 1);
            weakSelf.transform = transform;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorFloat)ls_transformScaleY {
    LSCAAnimatorFloat animator = LSCAAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.transform;
            transform = CATransform3DScale(transform, 1, f, 1);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CATransform3D transform = weakSelf.transform;
            transform = CATransform3DScale(transform, 1, f, 1);
            weakSelf.transform = transform;
        }];
        
        return self;
    };
    
    return animator;
}


#pragma mark - Bezier Paths
- (LSCAAnimatorBezierPath)ls_moveOnPath {
    LSCAAnimatorBezierPath animator = LSCAAnimatorBezierPath(path) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *pathAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position"];
            pathAnimation.path = path.CGPath;
            [weakSelf ls_addAnimation:pathAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CGPoint endPoint = path.currentPoint;
            weakSelf.position = endPoint;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorBezierPath)ls_moveAndRotateOnPath {
    LSCAAnimatorBezierPath animator = LSCAAnimatorBezierPath(path) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *pathAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position"];
            pathAnimation.path = path.CGPath;
            pathAnimation.rotationMode = kCAAnimationRotateAuto;
            [weakSelf ls_addAnimation:pathAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CGPoint endPoint = path.currentPoint;
            weakSelf.position = endPoint;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorBezierPath)ls_moveAndReverseRotateOnPath {
    LSCAAnimatorBezierPath animator = LSCAAnimatorBezierPath(path) {
        [self ls_addAnimationCalculationAction:^(__weak CALayer *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *pathAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position"];
            pathAnimation.path = path.CGPath;
            pathAnimation.rotationMode = kCAAnimationRotateAutoReverse;
            [weakSelf ls_addAnimation:pathAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak CALayer *weakSelf) {
            CGPoint endPoint = path.currentPoint;
            weakSelf.position = endPoint;
        }];
        
        return self;
    };
    
    return animator;
}


#pragma mark - Anchor
- (CALayer *)ls_anchorDefault {
    return self.ls_anchorCenter;
}

- (CALayer *)ls_anchorCenter {
    [self ls_updateAnchorWithPoint:CGPointMake(0.5, 0.5)];
    
    return self;
}

- (CALayer *)ls_anchorTop {
    [self ls_updateAnchorWithPoint:CGPointMake(0.5, 0.0)];
    
    return self;
}

- (CALayer *)ls_anchorBottom {
    [self ls_updateAnchorWithPoint:CGPointMake(0.5, 1.0)];
    
    return self;
}

- (CALayer *)ls_anchorLeft {
    [self ls_updateAnchorWithPoint:CGPointMake(0.0, 0.5)];
    
    return self;
}

- (CALayer *)ls_anchorRight {
    [self ls_updateAnchorWithPoint:CGPointMake(1.0, 0.5)];
    
    return self;
}

- (CALayer *)ls_anchorTopLeft {
    [self ls_updateAnchorWithPoint:CGPointMake(0.0, 0.0)];
    
    return self;
}

- (CALayer *)ls_anchorTopRight {
    [self ls_updateAnchorWithPoint:CGPointMake(1.0, 0.0)];
    
    return self;
}

- (CALayer *)ls_anchorBottomLeft {
    [self ls_updateAnchorWithPoint:CGPointMake(0.0, 1.0)];
    
    return self;
}

- (CALayer *)ls_anchorBottomRight {
    [self ls_updateAnchorWithPoint:CGPointMake(1.0, 1.0)];
    
    return self;
}


#pragma mark - Animation Effect Functions
- (CALayer *)ls_easeIn {
    return self.ls_easeInQuad;
}

- (CALayer *)ls_easeOut {
    return self.ls_easeOutQuad;
}

- (CALayer *)ls_easeInOut {
    return self.ls_easeInOutQuad;
}

- (CALayer *)ls_easeBack {
    return self.ls_easeOutBack;
}

- (CALayer *)ls_spring {
    return self.ls_easeOutElastic;
}

- (CALayer *)ls_bounce {
    return self.ls_easeOutBounce;
}

- (CALayer *)ls_easeInQuad {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInQuad(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeOutQuad {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutQuad(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInOutQuad {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutQuad(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInCubic {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInCubic(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeOutCubic {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutCubic(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInOutCubic {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutCubic(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInQuart {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInQuart(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeOutQuart {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutQuart(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInOutQuart {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutQuart(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInQuint {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInQuint(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeOutQuint {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutQuint(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInOutQuint {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutQuint(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInSine {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInSine(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeOutSine {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutSine(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInOutSine {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutSine(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInExpo {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInExpo(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeOutExpo {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutExpo(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInOutExpo {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutExpo(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInCirc {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInCirc(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeOutCirc {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutCirc(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInOutCirc {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutCirc(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInElastic {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInElastic(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeOutElastic {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutElastic(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInOutElastic {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutElastic(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInBack {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInBack(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeOutBack {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutBack(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInOutBack {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutBack(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInBounce {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInBounce(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeOutBounce {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutBounce(t, b, c, d);
    }];
    
    return self;
}

- (CALayer *)ls_easeInOutBounce {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutBounce(t, b, c, d);
    }];
    
    return self;
}


#pragma mark - Blocks
- (LSCAAnimatorBlock)ls_preAnimationBlock {
    LSCAAnimatorBlock animator = LSCAAnimatorBlock(block) {
        [[self.ls_animatorChains lastObject] ls_updateBeforeCurrentLinkerAnimationBlock:block];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorBlock)ls_postAnimationBlock {
    LSCAAnimatorBlock animator = LSCAAnimatorBlock(block) {
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


#pragma mark - Animator Delay
- (LSCAAnimatorTimeInterval)ls_delay {
    LSCAAnimatorTimeInterval animator = LSCAAnimatorTimeInterval(t) {
        [[self.ls_animatorChains lastObject] ls_updateCurrentTurnLinkerAnimationsDelay:t];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorTimeInterval)ls_wait {
    LSCAAnimatorTimeInterval animator = LSCAAnimatorTimeInterval(t) {
        return self.ls_delay(t);
    };
    
    return animator;
}


#pragma mark - Animator Controls
- (LSCAAnimatorRepeatAnimation)ls_repeat {
    LSCAAnimatorRepeatAnimation animator = LSCAAnimatorRepeatAnimation(duration, count) {
        [[self.ls_animatorChains lastObject] ls_updateCurrentTurnLinkerAnimationsDuration:duration];
        [[self.ls_animatorChains lastObject] ls_repeat:count andIsAnimation:NO];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorTimeInterval)ls_thenAfter {
    LSCAAnimatorTimeInterval animator = LSCAAnimatorTimeInterval(t) {
        [[self.ls_animatorChains lastObject] ls_thenAfter:t];
        
        return self;
    };
    
    return animator;
}

- (LSCAAnimatorAnimation)ls_animate {
    LSCAAnimatorAnimation animator = LSCAAnimatorAnimation(duration) {
        [[self.ls_animatorChains lastObject] ls_updateCurrentTurnLinkerAnimationsDuration:duration];
        [self ls_animateWithAnimatorChain:[self.ls_animatorChains lastObject]];
    };
    
    return animator;
}

- (LSCAAnimatorAnimationWithRepeat)ls_animateWithRepeat {
    LSCAAnimatorAnimationWithRepeat animator = LSCAAnimatorAnimationWithRepeat(duration, count) {
        [[self.ls_animatorChains lastObject] ls_updateCurrentTurnLinkerAnimationsDuration:duration];
        [[self.ls_animatorChains lastObject] ls_repeat:count andIsAnimation:YES];
        [self ls_animateWithAnimatorChain:[self.ls_animatorChains lastObject]];
    };
    
    return animator;
}

- (LSCAAnimatorAnimationWithCompletion)ls_animateWithCompletion {
    LSCAAnimatorAnimationWithCompletion animator = LSCAAnimatorAnimationWithCompletion(duration, completion) {
        [[self.ls_animatorChains lastObject] ls_updateCurrentTurnLinkerAnimationsDuration:duration];
        [self.ls_animatorChains lastObject].completeBlock = completion;
        [self ls_animateWithAnimatorChain:[self.ls_animatorChains lastObject]];
    };
    
    return animator;
}


#pragma mark - Multi-chain
- (CALayer *)ls_concurrent {
    [self.ls_animatorChains addObject:[LSAnimatorChain chainWithLayer:self]];
    
    return self;
}

@end
