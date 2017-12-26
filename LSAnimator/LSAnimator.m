//
//  LSAnimator.m
//  LSAnimatorDemo
//
//  Created by Lision on 2017/12/26.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import "LSAnimator.h"
#import "LSAnimatorLinker.h"
#import "LSAnimatorChain.h"
#import "LSKeyframeAnimation.h"
#import "LSKeyframeAnimationFunctions.h"

#define force_inline __inline__ __attribute__((always_inline))

#define ls_degreesToRadians( degrees ) ( ( degrees ) / 180.f * M_PI )
#define ls_radiansToDegrees( radians ) ( ( radians ) * ( 180.f / M_PI ) )

static NSString * const kLSAnimatorKey = @"LSAnimatorKey";

typedef void (^LSAnimatorCompleteBlock)();

static force_inline NSString *LSAnimatorChainAnimationKey(NSInteger index) {
    return [NSString stringWithFormat:@"%@_%@", kLSAnimatorKey, @(index)];
}

@interface LSAnimator ()

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

@implementation LSAnimator

+ (instancetype)animatorWithView:(UIView *)view {
    return [[self alloc] initWithView:view];
}

- (instancetype)initWithView:(UIView *)view {
    return [self initWithLayer:view.layer];
}

+ (instancetype)animatorWithLayer:(CALayer *)layer {
    return [[self alloc] initWithLayer:layer];
}

- (instancetype)initWithLayer:(CALayer *)layer {
    if (self = [super init]) {
        _layer = layer;
    }
    
    return self;
}

#pragma mark - Properties
- (NSMutableArray<LSAnimatorChain *> *)ls_animatorChains {
    if (!_ls_animatorChains) {
        _ls_animatorChains = [NSMutableArray arrayWithObject:[LSAnimatorChain chainWithAnimator:self]];
    }
    
    return _ls_animatorChains;
}

#pragma mark - Methods
- (LSKeyframeAnimation *)ls_basicAnimationForKeyPath:(NSString *)keypath {
    LSKeyframeAnimation *animation = [LSKeyframeAnimation animationWithKeyPath:keypath];
    animation.repeatCount = 0;
    animation.autoreverses = NO;
    
    return animation;
}

- (void)ls_addAnimation:(LSKeyframeAnimation *)animation withAnimatorChain:(LSAnimatorChain *)animatorChain {
    [animatorChain addAnimation:animation];
}

- (void)ls_addAnimationKeyframeFunctionBlock:(LSKeyframeAnimationFunctionBlock)functionBlock {
    [self ls_addAnimationCalculationAction:^(__weak LSAnimator *animator, __weak LSAnimatorChain *animatorChain) {
        [animatorChain addAnimationFunctionBlock:functionBlock];
    }];
}

- (void)ls_addAnimationCalculationAction:(LSAnimationCalculationAction)action {
    [[self.ls_animatorChains lastObject] addAnimationCalculationAction:action];
}

- (void)ls_addAnimationCompletionAction:(LSAnimationCompletionAction)action {
    [[self.ls_animatorChains lastObject] addAnimationCompletionAction:action];
}

- (void)ls_updateAnchorWithPoint:(CGPoint)anchorPoint {
    LSAnimationCalculationAction action = ^void(__weak LSAnimator *animator, __weak LSAnimatorChain *animatorChain) {
        if (CGPointEqualToPoint(anchorPoint, animator.layer.anchorPoint)) {
            return;
        }
        CGPoint newPoint = CGPointMake(animator.layer.bounds.size.width * anchorPoint.x,
                                       animator.layer.bounds.size.height * anchorPoint.y);
        CGPoint oldPoint = CGPointMake(animator.layer.bounds.size.width * animator.layer.anchorPoint.x,
                                       animator.layer.bounds.size.height * animator.layer.anchorPoint.y);
        
        newPoint = CGPointApplyAffineTransform(newPoint, animator.layer.affineTransform);
        oldPoint = CGPointApplyAffineTransform(oldPoint, animator.layer.affineTransform);
        
        CGPoint position = animator.layer.position;
        
        position.x -= oldPoint.x;
        position.x += newPoint.x;
        
        position.y -= oldPoint.y;
        position.y += newPoint.y;
        
        animator.layer.position = position;
        animator.layer.anchorPoint = anchorPoint;
    };
    
    [[self.ls_animatorChains lastObject] updateAnchorWithAction:action];
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
    CGSize size = self.layer.bounds.size;
    CGPoint newPosition;
    newPosition.x = newOrigin.x + anchor.x * size.width;
    newPosition.y = newOrigin.y + anchor.y * size.height;
    
    return newPosition;
}

- (CGPoint)ls_newPositionFromNewCenter:(CGPoint)newCenter {
    CGPoint anchor = self.layer.anchorPoint;
    CGSize size = self.layer.bounds.size;
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
        [self.layer removeAnimationForKey:LSAnimatorChainAnimationKey([self.ls_animatorChains indexOfObject:animatorChain])];
        [self ls_chainLinkerDidFinishAnimationsWithAnimatorChain:animatorChain];
    }];
    [self ls_animateLinkWithAnimatorChain:animatorChain];
    [CATransaction commit];
    [self ls_executeAnimationCompletionActionsWithAnimatorChain:animatorChain];
}

- (void)ls_chainLinkerDidFinishAnimationsWithAnimatorChain:(LSAnimatorChain *)animatorChain {
    if ([animatorChain isEmptiedAfterTryToRemoveCurrentTurnLinker]) {
        [self.ls_animatorChains removeObject:animatorChain];
        if (!self.ls_animatorChains.count) {
            [self.ls_animatorChains addObject:[LSAnimatorChain chainWithAnimator:self]];
            
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
    
    [animatorChain animateWithAnimationKey:LSAnimatorChainAnimationKey([self.ls_animatorChains indexOfObject:animatorChain])];
}

- (void)ls_executeAnimationCompletionActionsWithAnimatorChain:(LSAnimatorChain *)animatorChain {
    [animatorChain executeCompletionActions];
}


#pragma mark - Animations
- (LSAnimatorRect)makeFrame {
    LSAnimatorRect animator = LSAnimatorRect(rect) {
        return self.makeOrigin(rect.origin.x, rect.origin.y).makeBounds(rect);
    };
    
    return animator;
}

- (LSAnimatorRect)makeBounds {
    LSAnimatorRect animator = LSAnimatorRect(rect) {
        return self.makeSize(rect.size.width, rect.size.height);
    };
    
    return animator;
}

- (LSAnimatorSize)makeSize {
    LSAnimatorSize animator = LSAnimatorSize(width, height) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.layer.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(width, height)];
            [weakSelf ls_addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, width, height);
            weakSelf.layer.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPoint)makeOrigin {
    LSAnimatorPoint animator = LSAnimatorPoint(x, y) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position"];
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(x, y)];
            positionAnimation.fromValue = [NSValue valueWithCGPoint:weakSelf.layer.position];
            positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(x, y)];
            weakSelf.layer.position = newPosition;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPoint)makePosition {
    LSAnimatorPoint animator = LSAnimatorPoint(x, y) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position"];
            CGPoint newPosition = [weakSelf ls_newPositionFromNewCenter:CGPointMake(x, y)];
            positionAnimation.fromValue = [NSValue valueWithCGPoint:weakSelf.layer.position];
            positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            weakSelf.layer.position = CGPointMake(x, y);
        }];
        
        return self;
    };
    return animator;
}

- (LSAnimatorFloat)makeX {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position.x"];
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(f, weakSelf.layer.frame.origin.y)];
            positionAnimation.fromValue = @(weakSelf.layer.position.x);
            positionAnimation.toValue = @(newPosition.x);
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(f, weakSelf.layer.frame.origin.y)];
            weakSelf.layer.position = newPosition;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)makeY {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position.y"];
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(weakSelf.layer.frame.origin.x, f)];
            positionAnimation.fromValue = @(weakSelf.layer.position.y);
            positionAnimation.toValue = @(newPosition.y);
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(weakSelf.layer.frame.origin.x, f)];
            weakSelf.layer.position = newPosition;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)makeWidth {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.layer.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(f, weakSelf.layer.frame.size.height)];
            [weakSelf ls_addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, f, weakSelf.layer.frame.size.height);
            weakSelf.layer.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)makeHeight {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.layer.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(weakSelf.layer.frame.size.width, f)];
            [weakSelf ls_addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, weakSelf.layer.frame.size.width, f);
            weakSelf.layer.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)makeOpacity {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *opacityAnimation = [weakSelf ls_basicAnimationForKeyPath:@"opacity"];
            opacityAnimation.fromValue = @(weakSelf.layer.opacity);
            opacityAnimation.toValue = @(f);
            [weakSelf ls_addAnimation:opacityAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            weakSelf.layer.opacity = f;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorColor)makeBackground {
    LSAnimatorColor animator = LSAnimatorColor(color) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *colorAnimation = [weakSelf ls_basicAnimationForKeyPath:@"backgroundColor"];
            colorAnimation.fromValue = [self ls_colorWithCGColor:weakSelf.layer.backgroundColor];
            colorAnimation.toValue = color;
            [weakSelf ls_addAnimation:colorAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            weakSelf.layer.backgroundColor = color.CGColor;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorColor)makeBorderColor {
    LSAnimatorColor animator = LSAnimatorColor(color) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *colorAnimation = [weakSelf ls_basicAnimationForKeyPath:@"borderColor"];
            UIColor *borderColor = (__bridge UIColor *)(weakSelf.layer.borderColor);
            colorAnimation.fromValue = borderColor;
            colorAnimation.toValue = color;
            [weakSelf ls_addAnimation:colorAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            weakSelf.layer.borderColor = color.CGColor;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)makeBorderWidth {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        f = MAX(0, f);
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *borderAnimation = [weakSelf ls_basicAnimationForKeyPath:@"borderWidth"];
            borderAnimation.fromValue = @(weakSelf.layer.borderWidth);
            borderAnimation.toValue = @(f);
            [weakSelf ls_addAnimation:borderAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            weakSelf.layer.borderWidth = f;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)makeCornerRadius {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        f = MAX(0, f);
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *cornerAnimation = [weakSelf ls_basicAnimationForKeyPath:@"cornerRadius"];
            cornerAnimation.fromValue = @(weakSelf.layer.cornerRadius);
            cornerAnimation.toValue = @(f);
            [weakSelf ls_addAnimation:cornerAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            weakSelf.layer.cornerRadius = f;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)makeScale {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *boundsAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds"];
            CGRect rect = CGRectMake(0, 0, MAX(weakSelf.layer.bounds.size.width*f, 0), MAX(weakSelf.layer.bounds.size.height*f, 0));
            boundsAnimation.fromValue = [NSValue valueWithCGRect:weakSelf.layer.bounds];
            boundsAnimation.toValue = [NSValue valueWithCGRect:rect];
            [weakSelf ls_addAnimation:boundsAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGRect rect = CGRectMake(0, 0, MAX(weakSelf.layer.bounds.size.width*f, 0), MAX(weakSelf.layer.bounds.size.height*f, 0));
            weakSelf.layer.bounds = rect;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)makeScaleX {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *boundsAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds"];
            CGRect rect = CGRectMake(0, 0, MAX(weakSelf.layer.bounds.size.width*f, 0), weakSelf.layer.bounds.size.height);
            boundsAnimation.fromValue = [NSValue valueWithCGRect:weakSelf.layer.bounds];
            boundsAnimation.toValue = [NSValue valueWithCGRect:rect];
            [weakSelf ls_addAnimation:boundsAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGRect rect = CGRectMake(0, 0, MAX(weakSelf.layer.bounds.size.width*f, 0), weakSelf.layer.bounds.size.height);
            weakSelf.layer.bounds = rect;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)makeScaleY {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *boundsAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds"];
            CGRect rect = CGRectMake(0, 0, weakSelf.layer.bounds.size.width, MAX(weakSelf.layer.bounds.size.height*f, 0));
            boundsAnimation.fromValue = [NSValue valueWithCGRect:weakSelf.layer.bounds];
            boundsAnimation.toValue = [NSValue valueWithCGRect:rect];
            [weakSelf ls_addAnimation:boundsAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGRect rect = CGRectMake(0, 0, weakSelf.layer.bounds.size.width, MAX(weakSelf.layer.bounds.size.height*f, 0));
            weakSelf.layer.bounds = rect;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPoint)makeAnchor {
    LSAnimatorPoint animator = LSAnimatorPoint(x, y) {
        [self ls_updateAnchorWithPoint:CGPointMake(x, y)];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)moveX {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position.x"];
            positionAnimation.fromValue = @(weakSelf.layer.position.x);
            positionAnimation.toValue = @(weakSelf.layer.position.x + f);
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGPoint position = weakSelf.layer.position;
            position.x += f;
            weakSelf.layer.position = position;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)moveY {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position.y"];
            positionAnimation.fromValue = @(weakSelf.layer.position.y);
            positionAnimation.toValue = @(weakSelf.layer.position.y + f);
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGPoint position = weakSelf.layer.position;
            position.y += f;
            weakSelf.layer.position = position;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPoint)moveXY {
    LSAnimatorPoint animator = LSAnimatorPoint(x, y) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position"];
            CGPoint oldOrigin = weakSelf.layer.frame.origin;
            CGPoint newPosition = [weakSelf ls_newPositionFromNewOrigin:CGPointMake(oldOrigin.x + x, oldOrigin.y + y)];
            positionAnimation.fromValue = [NSValue valueWithCGPoint:weakSelf.layer.position];
            positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
            [weakSelf ls_addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGPoint position = weakSelf.layer.position;
            position.x += x;
            position.y += y;
            weakSelf.layer.position = position;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPolarCoordinate)movePolar {
    LSAnimatorPolarCoordinate animator = LSAnimatorPolarCoordinate(radius, angle) {
        CGFloat x = radius * cosf(ls_degreesToRadians(angle));
        CGFloat y = -radius * sinf(ls_degreesToRadians(angle));
        
        return self.moveXY(x, y);
    };
    
    return animator;
}

- (LSAnimatorFloat)increWidth {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.layer.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(MAX(weakSelf.layer.bounds.size.width + f, 0), weakSelf.layer.bounds.size.height)];
            [weakSelf ls_addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, MAX(weakSelf.layer.bounds.size.width+f, 0), weakSelf.layer.bounds.size.height);
            weakSelf.layer.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)increHeight {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.layer.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(weakSelf.layer.bounds.size.width, MAX(weakSelf.layer.bounds.size.height + f, 0))];
            [weakSelf ls_addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, weakSelf.layer.bounds.size.width, MAX(weakSelf.layer.bounds.size.height+f, 0));
            weakSelf.layer.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorSize)increSize {
    LSAnimatorSize animator = LSAnimatorSize(width, height) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf ls_basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.layer.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(weakSelf.layer.bounds.size.width + width, MAX(weakSelf.layer.bounds.size.height + height, 0))];
            [weakSelf ls_addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, MAX(weakSelf.layer.bounds.size.width+width, 0), MAX(weakSelf.layer.bounds.size.height+height, 0));
            weakSelf.layer.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimator *)transformIdentity {
    [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
        LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
        CATransform3D transform = CATransform3DIdentity;
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
        [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
    }];
    [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
        CATransform3D transform = CATransform3DIdentity;
        weakSelf.layer.transform = transform;
    }];
    
    return self;
}

- (LSAnimatorDegrees)rotate {
    return [self rotateZ];
}

- (LSAnimatorDegrees)rotateX {
    LSAnimatorDegrees animator = LSAnimatorDegrees(angle) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *rotationAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform.rotation.x"];
            CATransform3D transform = weakSelf.layer.transform;
            CGFloat originalRotation = atan2(transform.m23, transform.m22);
            rotationAnimation.fromValue = @(originalRotation);
            rotationAnimation.toValue = @(originalRotation + ls_degreesToRadians(angle));
            [weakSelf ls_addAnimation:rotationAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            CGFloat originalRotation = atan2(transform.m23, transform.m22);
            CATransform3D xRotation = CATransform3DMakeRotation(ls_degreesToRadians(angle)+originalRotation, 1.0, 0, 0);
            weakSelf.layer.transform = xRotation;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorDegrees)rotateY {
    LSAnimatorDegrees animator = LSAnimatorDegrees(angle) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *rotationAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform.rotation.y"];
            CATransform3D transform = weakSelf.layer.transform;
            CGFloat originalRotation = atan2(transform.m31, transform.m33);
            rotationAnimation.fromValue = @(originalRotation);
            rotationAnimation.toValue = @(originalRotation + ls_degreesToRadians(angle));
            [weakSelf ls_addAnimation:rotationAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            CGFloat originalRotation = atan2(transform.m31, transform.m33);
            CATransform3D yRotation = CATransform3DMakeRotation(ls_degreesToRadians(angle)+originalRotation, 0, 1.0, 0);
            weakSelf.layer.transform = yRotation;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorDegrees)rotateZ {
    LSAnimatorDegrees animator = LSAnimatorDegrees(angle) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *rotationAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform.rotation.z"];
            CATransform3D transform = weakSelf.layer.transform;
            CGFloat originalRotation = atan2(transform.m12, transform.m11);
            rotationAnimation.fromValue = @(originalRotation);
            rotationAnimation.toValue = @(originalRotation + ls_degreesToRadians(angle));
            [weakSelf ls_addAnimation:rotationAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            CGFloat originalRotation = atan2(transform.m12, transform.m11);
            CATransform3D zRotation = CATransform3DMakeRotation(ls_degreesToRadians(angle) + originalRotation, 0, 0, 1.0);
            weakSelf.layer.transform = zRotation;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)transformX {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, f, 0, 0);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, f, 0, 0);
            weakSelf.layer.transform = transform;
        }];
        
        return self;
    };
    return animator;
}

- (LSAnimatorFloat)transformY {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, 0, f, 0);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, 0, f, 0);
            weakSelf.layer.transform = transform;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)transformZ {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, 0, 0, f);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, 0, 0, f);
            weakSelf.layer.transform = transform;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPoint)transformXY {
    LSAnimatorPoint animator = LSAnimatorPoint(x, y) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, x, y, 0);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, x, y, 0);
            weakSelf.layer.transform = transform;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)transformScale {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DScale(transform, f, f, 1);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DScale(transform, f, f, 1);
            weakSelf.layer.transform = transform;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)transformScaleX {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DScale(transform, f, 1, 1);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DScale(transform, f, 1, 1);
            weakSelf.layer.transform = transform;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)transformScaleY {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf ls_basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DScale(transform, 1, f, 1);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf ls_addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DScale(transform, 1, f, 1);
            weakSelf.layer.transform = transform;
        }];
        
        return self;
    };
    
    return animator;
}


#pragma mark - Bezier Paths
- (LSAnimatorBezierPath)moveOnPath {
    LSAnimatorBezierPath animator = LSAnimatorBezierPath(path) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *pathAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position"];
            pathAnimation.path = path.CGPath;
            [weakSelf ls_addAnimation:pathAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGPoint endPoint = path.currentPoint;
            weakSelf.layer.position = endPoint;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorBezierPath)moveAndRotateOnPath {
    LSAnimatorBezierPath animator = LSAnimatorBezierPath(path) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *pathAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position"];
            pathAnimation.path = path.CGPath;
            pathAnimation.rotationMode = kCAAnimationRotateAuto;
            [weakSelf ls_addAnimation:pathAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGPoint endPoint = path.currentPoint;
            weakSelf.layer.position = endPoint;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorBezierPath)moveAndReverseRotateOnPath {
    LSAnimatorBezierPath animator = LSAnimatorBezierPath(path) {
        [self ls_addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *pathAnimation = [weakSelf ls_basicAnimationForKeyPath:@"position"];
            pathAnimation.path = path.CGPath;
            pathAnimation.rotationMode = kCAAnimationRotateAutoReverse;
            [weakSelf ls_addAnimation:pathAnimation withAnimatorChain:animatorChain];
        }];
        [self ls_addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGPoint endPoint = path.currentPoint;
            weakSelf.layer.position = endPoint;
        }];
        
        return self;
    };
    
    return animator;
}


#pragma mark - Anchor
- (LSAnimator *)anchorDefault {
    return self.anchorCenter;
}

- (LSAnimator *)anchorCenter {
    [self ls_updateAnchorWithPoint:CGPointMake(0.5, 0.5)];
    
    return self;
}

- (LSAnimator *)anchorTop {
    [self ls_updateAnchorWithPoint:CGPointMake(0.5, 0.0)];
    
    return self;
}

- (LSAnimator *)anchorBottom {
    [self ls_updateAnchorWithPoint:CGPointMake(0.5, 1.0)];
    
    return self;
}

- (LSAnimator *)anchorLeft {
    [self ls_updateAnchorWithPoint:CGPointMake(0.0, 0.5)];
    
    return self;
}

- (LSAnimator *)anchorRight {
    [self ls_updateAnchorWithPoint:CGPointMake(1.0, 0.5)];
    
    return self;
}

- (LSAnimator *)anchorTopLeft {
    [self ls_updateAnchorWithPoint:CGPointMake(0.0, 0.0)];
    
    return self;
}

- (LSAnimator *)anchorTopRight {
    [self ls_updateAnchorWithPoint:CGPointMake(1.0, 0.0)];
    
    return self;
}

- (LSAnimator *)anchorBottomLeft {
    [self ls_updateAnchorWithPoint:CGPointMake(0.0, 1.0)];
    
    return self;
}

- (LSAnimator *)anchorBottomRight {
    [self ls_updateAnchorWithPoint:CGPointMake(1.0, 1.0)];
    
    return self;
}


#pragma mark - Animation Effect Functions
- (LSAnimator *)easeIn {
    return self.easeInQuad;
}

- (LSAnimator *)easeOut {
    return self.easeOutQuad;
}

- (LSAnimator *)easeInOut {
    return self.easeInOutQuad;
}

- (LSAnimator *)easeBack {
    return self.easeOutBack;
}

- (LSAnimator *)spring {
    return self.easeOutElastic;
}

- (LSAnimator *)bounce {
    return self.easeOutBounce;
}

- (LSAnimator *)easeInQuad {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInQuad(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutQuad {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutQuad(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutQuad {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutQuad(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInCubic {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInCubic(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutCubic {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutCubic(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutCubic {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutCubic(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInQuart {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInQuart(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutQuart {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutQuart(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutQuart {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutQuart(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInQuint {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInQuint(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutQuint {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutQuint(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutQuint {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutQuint(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInSine {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInSine(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutSine {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutSine(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutSine {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutSine(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInExpo {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInExpo(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutExpo {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutExpo(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutExpo {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutExpo(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInCirc {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInCirc(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutCirc {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutCirc(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutCirc {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutCirc(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInElastic {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInElastic(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutElastic {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutElastic(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutElastic {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutElastic(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInBack {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInBack(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutBack {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutBack(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutBack {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutBack(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInBounce {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInBounce(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutBounce {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutBounce(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutBounce {
    [self ls_addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutBounce(t, b, c, d);
    }];
    
    return self;
}


#pragma mark - Blocks
- (LSAnimatorBlock)preAnimationBlock {
    LSAnimatorBlock animator = LSAnimatorBlock(block) {
        [[self.ls_animatorChains lastObject] updateBeforeCurrentLinkerAnimationBlock:block];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorBlock)postAnimationBlock {
    LSAnimatorBlock animator = LSAnimatorBlock(block) {
        [[self.ls_animatorChains lastObject] updateAfterCurrentLinkerAnimationBlock:block];
        
        return self;
    };
    
    return animator;
}

- (LSFinalAnimatorCompletion)theFinalCompletion {
    LSFinalAnimatorCompletion animator = LSFinalAnimatorCompletion(block) {
        self.ls_finalCompleteBlock = block;
    };
    
    return animator;
}


#pragma mark - Animator Delay
- (LSAnimatorTimeInterval)delay {
    LSAnimatorTimeInterval animator = LSAnimatorTimeInterval(t) {
        [[self.ls_animatorChains lastObject] updateCurrentTurnLinkerAnimationsDelay:t];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorTimeInterval)wait {
    LSAnimatorTimeInterval animator = LSAnimatorTimeInterval(t) {
        return self.delay(t);
    };
    
    return animator;
}


#pragma mark - Animator Controls
- (LSAnimatorRepeatAnimation)repeat {
    LSAnimatorRepeatAnimation animator = LSAnimatorRepeatAnimation(duration, count) {
        [[self.ls_animatorChains lastObject] updateCurrentTurnLinkerAnimationsDuration:duration];
        [[self.ls_animatorChains lastObject] repeat:count andIsAnimation:NO];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorTimeInterval)thenAfter {
    LSAnimatorTimeInterval animator = LSAnimatorTimeInterval(t) {
        [[self.ls_animatorChains lastObject] thenAfter:t];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorAnimation)animate {
    LSAnimatorAnimation animator = LSAnimatorAnimation(duration) {
        [[self.ls_animatorChains lastObject] updateCurrentTurnLinkerAnimationsDuration:duration];
        [self ls_animateWithAnimatorChain:[self.ls_animatorChains lastObject]];
    };
    
    return animator;
}

- (LSAnimatorAnimationWithRepeat)animateWithRepeat {
    LSAnimatorAnimationWithRepeat animator = LSAnimatorAnimationWithRepeat(duration, count) {
        [[self.ls_animatorChains lastObject] updateCurrentTurnLinkerAnimationsDuration:duration];
        [[self.ls_animatorChains lastObject] repeat:count andIsAnimation:YES];
        [self ls_animateWithAnimatorChain:[self.ls_animatorChains lastObject]];
    };
    
    return animator;
}

- (LSAnimatorAnimationWithCompletion)animateWithCompletion {
    LSAnimatorAnimationWithCompletion animator = LSAnimatorAnimationWithCompletion(duration, completion) {
        [[self.ls_animatorChains lastObject] updateCurrentTurnLinkerAnimationsDuration:duration];
        [self.ls_animatorChains lastObject].completeBlock = completion;
        [self ls_animateWithAnimatorChain:[self.ls_animatorChains lastObject]];
    };
    
    return animator;
}


#pragma mark - Multi-chain
- (LSAnimator *)concurrent {
    [self.ls_animatorChains addObject:[LSAnimatorChain chainWithAnimator:self]];
    
    return self;
}

@end
