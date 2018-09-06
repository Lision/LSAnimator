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

#define LSDegreesToRadians( degrees ) ( ( degrees ) / 180.f * M_PI )
#define LSRadiansToDegrees( radians ) ( ( radians ) * ( 180.f / M_PI ) )

static NSString * const kLSAnimatorKey = @"LSAnimatorKey";

typedef void (^LSAnimatorCompleteBlock)(void);

NS_INLINE NSString *LSAnimatorChainAnimationKey(NSInteger index) {
    return [NSString stringWithFormat:@"%@_%@", kLSAnimatorKey, @(index)];
}

@interface LSAnimator ()

#pragma mark - Properties
@property (nonatomic, copy) LSAnimatorCompleteBlock finalCompleteBlock;
@property (nonatomic, strong) NSMutableArray <LSAnimatorChain *> *animatorChains;

#pragma mark - Methods
- (LSKeyframeAnimation *)basicAnimationForKeyPath:(NSString *)keypath;

- (void)addAnimation:(LSKeyframeAnimation *)animation withAnimatorChain:(LSAnimatorChain *)animatorChain;
- (void)addAnimationCalculationAction:(LSAnimationCalculationAction)action;
- (void)addAnimationCompletionAction:(LSAnimationCompletionAction)action;
- (void)addAnimationKeyframeFunctionBlock:(LSKeyframeAnimationFunctionBlock)functionBlock;

- (void)updateAnchorWithPoint:(CGPoint)anchorPoint;
- (CGPoint)newPositionFromNewFrame:(CGRect)newRect;
- (CGPoint)newPositionFromNewOrigin:(CGPoint)newOrigin;
- (CGPoint)newPositionFromNewCenter:(CGPoint)newCenter;

- (UIColor *)colorWithCGColor:(CGColorRef)cgColor;

- (void)animateWithAnimatorChain:(LSAnimatorChain *)animatorChain;

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
- (NSMutableArray<LSAnimatorChain *> *)animatorChains {
    if (!_animatorChains) {
        _animatorChains = [NSMutableArray arrayWithObject:[LSAnimatorChain chainWithAnimator:self]];
    }
    
    return _animatorChains;
}

#pragma mark - Methods
- (LSKeyframeAnimation *)basicAnimationForKeyPath:(NSString *)keypath {
    LSKeyframeAnimation *animation = [LSKeyframeAnimation animationWithKeyPath:keypath];
    animation.repeatCount = 0;
    animation.autoreverses = NO;
    
    return animation;
}

- (void)addAnimation:(LSKeyframeAnimation *)animation withAnimatorChain:(LSAnimatorChain *)animatorChain {
    [animatorChain addAnimation:animation];
}

- (void)addAnimationKeyframeFunctionBlock:(LSKeyframeAnimationFunctionBlock)functionBlock {
    [self addAnimationCalculationAction:^(__weak LSAnimator *animator, __weak LSAnimatorChain *animatorChain) {
        [animatorChain addAnimationFunctionBlock:functionBlock];
    }];
}

- (void)addAnimationCalculationAction:(LSAnimationCalculationAction)action {
    [[self.animatorChains lastObject] addAnimationCalculationAction:action];
}

- (void)addAnimationCompletionAction:(LSAnimationCompletionAction)action {
    [[self.animatorChains lastObject] addAnimationCompletionAction:action];
}

- (void)updateAnchorWithPoint:(CGPoint)anchorPoint {
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
    
    [[self.animatorChains lastObject] updateAnchorWithAction:action];
}

- (CGPoint)newPositionFromNewFrame:(CGRect)newRect {
    CGPoint anchor = self.layer.anchorPoint;
    CGSize size = newRect.size;
    CGPoint newPosition;
    newPosition.x = newRect.origin.x + anchor.x * size.width;
    newPosition.y = newRect.origin.y + anchor.y * size.height;
    
    return newPosition;
}

- (CGPoint)newPositionFromNewOrigin:(CGPoint)newOrigin {
    CGPoint anchor = self.layer.anchorPoint;
    CGSize size = self.layer.bounds.size;
    CGPoint newPosition;
    newPosition.x = newOrigin.x + anchor.x * size.width;
    newPosition.y = newOrigin.y + anchor.y * size.height;
    
    return newPosition;
}

- (CGPoint)newPositionFromNewCenter:(CGPoint)newCenter {
    CGPoint anchor = self.layer.anchorPoint;
    CGSize size = self.layer.bounds.size;
    CGPoint newPosition;
    newPosition.x = newCenter.x + (anchor.x - 0.5) * size.width;
    newPosition.y = newCenter.y + (anchor.y - 0.5) * size.height;
    
    return newPosition;
}

- (UIColor *)colorWithCGColor:(CGColorRef)cgColor {
    CGColorSpaceRef deviceRGBColorSpace = CGColorSpaceCreateDeviceRGB();
    if (!deviceRGBColorSpace) return nil;

    BOOL isRGBColor = (CGColorGetColorSpace(cgColor) == deviceRGBColorSpace);
    if (!isRGBColor) {
        cgColor = CGColorCreateCopyByMatchingToColorSpace(deviceRGBColorSpace, kCGRenderingIntentDefault, cgColor, NULL);
    }
    CGColorSpaceRelease(deviceRGBColorSpace);
    
    const CGFloat *components = CGColorGetComponents(cgColor);
    if (!isRGBColor) {
        CGColorRelease(cgColor);
    }
    if (!components) return nil;
    
    return [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:components[3]];
}

- (void)animateWithAnimatorChain:(LSAnimatorChain *)animatorChain {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setCompletionBlock:^{
        [self.layer removeAnimationForKey:LSAnimatorChainAnimationKey([self.animatorChains indexOfObject:animatorChain])];
        [self chainLinkerDidFinishAnimationsWithAnimatorChain:animatorChain];
    }];
    [self animateLinkWithAnimatorChain:animatorChain];
    [CATransaction commit];
    [self executeAnimationCompletionActionsWithAnimatorChain:animatorChain];
}

- (void)chainLinkerDidFinishAnimationsWithAnimatorChain:(LSAnimatorChain *)animatorChain {
    if ([animatorChain isEmptiedAfterTryToRemoveCurrentTurnLinker]) {
        [self.animatorChains removeObject:animatorChain];
        if (!self.animatorChains.count) {
            [self.animatorChains addObject:[LSAnimatorChain chainWithAnimator:self]];
            
            if (self.finalCompleteBlock) {
                LSAnimatorCompleteBlock finalCompleteBlock = self.finalCompleteBlock;
                self.finalCompleteBlock = nil;
                finalCompleteBlock();
            }
        }
    } else {
        [self animateWithAnimatorChain:animatorChain];
    }
}

- (void)animateLinkWithAnimatorChain:(LSAnimatorChain *)animatorChain {
    NSAssert([self.animatorChains containsObject:animatorChain], @"LSANIMATOR ERROR: ANIMATORCHAINS DO NOT CONTAINS OBJECT CURRENT ANIMATORCHAIN");
    
    [animatorChain animateWithAnimationKey:LSAnimatorChainAnimationKey([self.animatorChains indexOfObject:animatorChain])];
}

- (void)executeAnimationCompletionActionsWithAnimatorChain:(LSAnimatorChain *)animatorChain {
    [animatorChain executeCompletionActions];
}


#pragma mark - Animations
- (LSAnimatorRect)makeFrame {
    LSAnimatorRect animator = LSAnimatorRect(rect) {
        CGPoint newPosition = [self newPositionFromNewFrame:rect];
        return self.makeBounds(rect).makePosition(newPosition.x, newPosition.y);
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
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.layer.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(width, height)];
            [weakSelf addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, width, height);
            weakSelf.layer.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPoint)makeOrigin {
    LSAnimatorPoint animator = LSAnimatorPoint(x, y) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf basicAnimationForKeyPath:@"position"];
            CGPoint newPosition = [weakSelf newPositionFromNewOrigin:CGPointMake(x, y)];
            positionAnimation.fromValue = [NSValue valueWithCGPoint:weakSelf.layer.position];
            positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
            [weakSelf addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGPoint newPosition = [weakSelf newPositionFromNewOrigin:CGPointMake(x, y)];
            weakSelf.layer.position = newPosition;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPoint)makePosition {
    LSAnimatorPoint animator = LSAnimatorPoint(x, y) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf basicAnimationForKeyPath:@"position"];
            CGPoint newPosition = [weakSelf newPositionFromNewCenter:CGPointMake(x, y)];
            positionAnimation.fromValue = [NSValue valueWithCGPoint:weakSelf.layer.position];
            positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
            [weakSelf addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            weakSelf.layer.position = CGPointMake(x, y);
        }];
        
        return self;
    };
    return animator;
}

- (LSAnimatorFloat)makeX {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf basicAnimationForKeyPath:@"position.x"];
            CGPoint newPosition = [weakSelf newPositionFromNewOrigin:CGPointMake(f, weakSelf.layer.frame.origin.y)];
            positionAnimation.fromValue = @(weakSelf.layer.position.x);
            positionAnimation.toValue = @(newPosition.x);
            [weakSelf addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGPoint newPosition = [weakSelf newPositionFromNewOrigin:CGPointMake(f, weakSelf.layer.frame.origin.y)];
            weakSelf.layer.position = newPosition;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)makeY {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf basicAnimationForKeyPath:@"position.y"];
            CGPoint newPosition = [weakSelf newPositionFromNewOrigin:CGPointMake(weakSelf.layer.frame.origin.x, f)];
            positionAnimation.fromValue = @(weakSelf.layer.position.y);
            positionAnimation.toValue = @(newPosition.y);
            [weakSelf addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGPoint newPosition = [weakSelf newPositionFromNewOrigin:CGPointMake(weakSelf.layer.frame.origin.x, f)];
            weakSelf.layer.position = newPosition;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)makeWidth {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.layer.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(f, weakSelf.layer.frame.size.height)];
            [weakSelf addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, f, weakSelf.layer.frame.size.height);
            weakSelf.layer.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)makeHeight {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.layer.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(weakSelf.layer.frame.size.width, f)];
            [weakSelf addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, weakSelf.layer.frame.size.width, f);
            weakSelf.layer.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)makeOpacity {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *opacityAnimation = [weakSelf basicAnimationForKeyPath:@"opacity"];
            opacityAnimation.fromValue = @(weakSelf.layer.opacity);
            opacityAnimation.toValue = @(f);
            [weakSelf addAnimation:opacityAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            weakSelf.layer.opacity = f;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorColor)makeBackground {
    LSAnimatorColor animator = LSAnimatorColor(color) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *colorAnimation = [weakSelf basicAnimationForKeyPath:@"backgroundColor"];
            colorAnimation.fromValue = [weakSelf colorWithCGColor:weakSelf.layer.backgroundColor];
            colorAnimation.toValue = color;
            [weakSelf addAnimation:colorAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            weakSelf.layer.backgroundColor = color.CGColor;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorColor)makeBorderColor {
    LSAnimatorColor animator = LSAnimatorColor(color) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *colorAnimation = [weakSelf basicAnimationForKeyPath:@"borderColor"];
            UIColor *borderColor = (__bridge UIColor *)(weakSelf.layer.borderColor);
            colorAnimation.fromValue = borderColor;
            colorAnimation.toValue = color;
            [weakSelf addAnimation:colorAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            weakSelf.layer.borderColor = color.CGColor;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)makeBorderWidth {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        f = MAX(0, f);
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *borderAnimation = [weakSelf basicAnimationForKeyPath:@"borderWidth"];
            borderAnimation.fromValue = @(weakSelf.layer.borderWidth);
            borderAnimation.toValue = @(f);
            [weakSelf addAnimation:borderAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            weakSelf.layer.borderWidth = f;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)makeCornerRadius {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        f = MAX(0, f);
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *cornerAnimation = [weakSelf basicAnimationForKeyPath:@"cornerRadius"];
            cornerAnimation.fromValue = @(weakSelf.layer.cornerRadius);
            cornerAnimation.toValue = @(f);
            [weakSelf addAnimation:cornerAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            weakSelf.layer.cornerRadius = f;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)makeScale {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *boundsAnimation = [weakSelf basicAnimationForKeyPath:@"bounds"];
            CGRect rect = CGRectMake(0, 0, MAX(weakSelf.layer.bounds.size.width*f, 0), MAX(weakSelf.layer.bounds.size.height*f, 0));
            boundsAnimation.fromValue = [NSValue valueWithCGRect:weakSelf.layer.bounds];
            boundsAnimation.toValue = [NSValue valueWithCGRect:rect];
            [weakSelf addAnimation:boundsAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGRect rect = CGRectMake(0, 0, MAX(weakSelf.layer.bounds.size.width*f, 0), MAX(weakSelf.layer.bounds.size.height*f, 0));
            weakSelf.layer.bounds = rect;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)makeScaleX {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *boundsAnimation = [weakSelf basicAnimationForKeyPath:@"bounds"];
            CGRect rect = CGRectMake(0, 0, MAX(weakSelf.layer.bounds.size.width*f, 0), weakSelf.layer.bounds.size.height);
            boundsAnimation.fromValue = [NSValue valueWithCGRect:weakSelf.layer.bounds];
            boundsAnimation.toValue = [NSValue valueWithCGRect:rect];
            [weakSelf addAnimation:boundsAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGRect rect = CGRectMake(0, 0, MAX(weakSelf.layer.bounds.size.width*f, 0), weakSelf.layer.bounds.size.height);
            weakSelf.layer.bounds = rect;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)makeScaleY {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *boundsAnimation = [weakSelf basicAnimationForKeyPath:@"bounds"];
            CGRect rect = CGRectMake(0, 0, weakSelf.layer.bounds.size.width, MAX(weakSelf.layer.bounds.size.height*f, 0));
            boundsAnimation.fromValue = [NSValue valueWithCGRect:weakSelf.layer.bounds];
            boundsAnimation.toValue = [NSValue valueWithCGRect:rect];
            [weakSelf addAnimation:boundsAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGRect rect = CGRectMake(0, 0, weakSelf.layer.bounds.size.width, MAX(weakSelf.layer.bounds.size.height*f, 0));
            weakSelf.layer.bounds = rect;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorPoint)makeAnchor {
    LSAnimatorPoint animator = LSAnimatorPoint(x, y) {
        [self updateAnchorWithPoint:CGPointMake(x, y)];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)moveX {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf basicAnimationForKeyPath:@"position.x"];
            positionAnimation.fromValue = @(weakSelf.layer.position.x);
            positionAnimation.toValue = @(weakSelf.layer.position.x + f);
            [weakSelf addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
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
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf basicAnimationForKeyPath:@"position.y"];
            positionAnimation.fromValue = @(weakSelf.layer.position.y);
            positionAnimation.toValue = @(weakSelf.layer.position.y + f);
            [weakSelf addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
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
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *positionAnimation = [weakSelf basicAnimationForKeyPath:@"position"];
            CGPoint oldOrigin = weakSelf.layer.frame.origin;
            CGPoint newPosition = [weakSelf newPositionFromNewOrigin:CGPointMake(oldOrigin.x + x, oldOrigin.y + y)];
            positionAnimation.fromValue = [NSValue valueWithCGPoint:weakSelf.layer.position];
            positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
            [weakSelf addAnimation:positionAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
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
        CGFloat x = radius * cosf(LSDegreesToRadians(angle));
        CGFloat y = -radius * sinf(LSDegreesToRadians(angle));
        
        return self.moveXY(x, y);
    };
    
    return animator;
}

- (LSAnimatorFloat)increWidth {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.layer.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(MAX(weakSelf.layer.bounds.size.width + f, 0), weakSelf.layer.bounds.size.height)];
            [weakSelf addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, MAX(weakSelf.layer.bounds.size.width+f, 0), weakSelf.layer.bounds.size.height);
            weakSelf.layer.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)increHeight {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.layer.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(weakSelf.layer.bounds.size.width, MAX(weakSelf.layer.bounds.size.height + f, 0))];
            [weakSelf addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, weakSelf.layer.bounds.size.width, MAX(weakSelf.layer.bounds.size.height+f, 0));
            weakSelf.layer.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorSize)increSize {
    LSAnimatorSize animator = LSAnimatorSize(width, height) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *sizeAnimation = [weakSelf basicAnimationForKeyPath:@"bounds.size"];
            sizeAnimation.fromValue = [NSValue valueWithCGSize:weakSelf.layer.bounds.size];
            sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(weakSelf.layer.bounds.size.width + width, MAX(weakSelf.layer.bounds.size.height + height, 0))];
            [weakSelf addAnimation:sizeAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGRect bounds = CGRectMake(0, 0, MAX(weakSelf.layer.bounds.size.width+width, 0), MAX(weakSelf.layer.bounds.size.height+height, 0));
            weakSelf.layer.bounds = bounds;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimator *)transformIdentity {
    [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
        LSKeyframeAnimation *transformAnimation = [weakSelf basicAnimationForKeyPath:@"transform"];
        CATransform3D transform = CATransform3DIdentity;
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
        [weakSelf addAnimation:transformAnimation withAnimatorChain:animatorChain];
    }];
    [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
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
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *rotationAnimation = [weakSelf basicAnimationForKeyPath:@"transform.rotation.x"];
            CATransform3D transform = weakSelf.layer.transform;
            CGFloat originalRotation = atan2(transform.m23, transform.m22);
            rotationAnimation.fromValue = @(originalRotation);
            rotationAnimation.toValue = @(originalRotation + LSDegreesToRadians(angle));
            [weakSelf addAnimation:rotationAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            CGFloat originalRotation = atan2(transform.m23, transform.m22);
            CATransform3D xRotation = CATransform3DMakeRotation(LSDegreesToRadians(angle)+originalRotation, 1.0, 0, 0);
            weakSelf.layer.transform = xRotation;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorDegrees)rotateY {
    LSAnimatorDegrees animator = LSAnimatorDegrees(angle) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *rotationAnimation = [weakSelf basicAnimationForKeyPath:@"transform.rotation.y"];
            CATransform3D transform = weakSelf.layer.transform;
            CGFloat originalRotation = atan2(transform.m31, transform.m33);
            rotationAnimation.fromValue = @(originalRotation);
            rotationAnimation.toValue = @(originalRotation + LSDegreesToRadians(angle));
            [weakSelf addAnimation:rotationAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            CGFloat originalRotation = atan2(transform.m31, transform.m33);
            CATransform3D yRotation = CATransform3DMakeRotation(LSDegreesToRadians(angle)+originalRotation, 0, 1.0, 0);
            weakSelf.layer.transform = yRotation;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorDegrees)rotateZ {
    LSAnimatorDegrees animator = LSAnimatorDegrees(angle) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *rotationAnimation = [weakSelf basicAnimationForKeyPath:@"transform.rotation.z"];
            CATransform3D transform = weakSelf.layer.transform;
            CGFloat originalRotation = atan2(transform.m12, transform.m11);
            rotationAnimation.fromValue = @(originalRotation);
            rotationAnimation.toValue = @(originalRotation + LSDegreesToRadians(angle));
            [weakSelf addAnimation:rotationAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CATransform3D transform = weakSelf.layer.transform;
            CGFloat originalRotation = atan2(transform.m12, transform.m11);
            CATransform3D zRotation = CATransform3DMakeRotation(LSDegreesToRadians(angle) + originalRotation, 0, 0, 1.0);
            weakSelf.layer.transform = zRotation;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorFloat)transformX {
    LSAnimatorFloat animator = LSAnimatorFloat(f) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, f, 0, 0);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
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
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, 0, f, 0);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
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
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, 0, 0, f);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
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
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DTranslate(transform, x, y, 0);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
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
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DScale(transform, f, f, 1);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
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
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DScale(transform, f, 1, 1);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
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
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *transformAnimation = [weakSelf basicAnimationForKeyPath:@"transform"];
            CATransform3D transform = weakSelf.layer.transform;
            transform = CATransform3DScale(transform, 1, f, 1);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:weakSelf.layer.transform];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
            [weakSelf addAnimation:transformAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
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
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *pathAnimation = [weakSelf basicAnimationForKeyPath:@"position"];
            pathAnimation.path = path.CGPath;
            [weakSelf addAnimation:pathAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGPoint endPoint = path.currentPoint;
            weakSelf.layer.position = endPoint;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorBezierPath)moveAndRotateOnPath {
    LSAnimatorBezierPath animator = LSAnimatorBezierPath(path) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *pathAnimation = [weakSelf basicAnimationForKeyPath:@"position"];
            pathAnimation.path = path.CGPath;
            pathAnimation.rotationMode = kCAAnimationRotateAuto;
            [weakSelf addAnimation:pathAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
            CGPoint endPoint = path.currentPoint;
            weakSelf.layer.position = endPoint;
        }];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorBezierPath)moveAndReverseRotateOnPath {
    LSAnimatorBezierPath animator = LSAnimatorBezierPath(path) {
        [self addAnimationCalculationAction:^(__weak LSAnimator *weakSelf, __weak LSAnimatorChain *animatorChain) {
            LSKeyframeAnimation *pathAnimation = [weakSelf basicAnimationForKeyPath:@"position"];
            pathAnimation.path = path.CGPath;
            pathAnimation.rotationMode = kCAAnimationRotateAutoReverse;
            [weakSelf addAnimation:pathAnimation withAnimatorChain:animatorChain];
        }];
        [self addAnimationCompletionAction:^(__weak LSAnimator *weakSelf) {
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
    [self updateAnchorWithPoint:CGPointMake(0.5, 0.5)];
    
    return self;
}

- (LSAnimator *)anchorTop {
    [self updateAnchorWithPoint:CGPointMake(0.5, 0.0)];
    
    return self;
}

- (LSAnimator *)anchorBottom {
    [self updateAnchorWithPoint:CGPointMake(0.5, 1.0)];
    
    return self;
}

- (LSAnimator *)anchorLeft {
    [self updateAnchorWithPoint:CGPointMake(0.0, 0.5)];
    
    return self;
}

- (LSAnimator *)anchorRight {
    [self updateAnchorWithPoint:CGPointMake(1.0, 0.5)];
    
    return self;
}

- (LSAnimator *)anchorTopLeft {
    [self updateAnchorWithPoint:CGPointMake(0.0, 0.0)];
    
    return self;
}

- (LSAnimator *)anchorTopRight {
    [self updateAnchorWithPoint:CGPointMake(1.0, 0.0)];
    
    return self;
}

- (LSAnimator *)anchorBottomLeft {
    [self updateAnchorWithPoint:CGPointMake(0.0, 1.0)];
    
    return self;
}

- (LSAnimator *)anchorBottomRight {
    [self updateAnchorWithPoint:CGPointMake(1.0, 1.0)];
    
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
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInQuad(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutQuad {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutQuad(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutQuad {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutQuad(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInCubic {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInCubic(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutCubic {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutCubic(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutCubic {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutCubic(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInQuart {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInQuart(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutQuart {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutQuart(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutQuart {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutQuart(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInQuint {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInQuint(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutQuint {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutQuint(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutQuint {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutQuint(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInSine {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInSine(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutSine {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutSine(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutSine {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutSine(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInExpo {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInExpo(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutExpo {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutExpo(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutExpo {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutExpo(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInCirc {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInCirc(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutCirc {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutCirc(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutCirc {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutCirc(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInElastic {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInElastic(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutElastic {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutElastic(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutElastic {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutElastic(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInBack {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInBack(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutBack {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutBack(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutBack {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutBack(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInBounce {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInBounce(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeOutBounce {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseOutBounce(t, b, c, d);
    }];
    
    return self;
}

- (LSAnimator *)easeInOutBounce {
    [self addAnimationKeyframeFunctionBlock:^double(double t, double b, double c, double d) {
        return LSKeyframeAnimationFunctionEaseInOutBounce(t, b, c, d);
    }];
    
    return self;
}


#pragma mark - Blocks
- (LSAnimatorBlock)preAnimationBlock {
    LSAnimatorBlock animator = LSAnimatorBlock(block) {
        [[self.animatorChains lastObject] updateBeforeCurrentLinkerAnimationBlock:block];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorBlock)postAnimationBlock {
    LSAnimatorBlock animator = LSAnimatorBlock(block) {
        [[self.animatorChains lastObject] updateAfterCurrentLinkerAnimationBlock:block];
        
        return self;
    };
    
    return animator;
}

- (LSFinalAnimatorCompletion)theFinalCompletion {
    LSFinalAnimatorCompletion animator = LSFinalAnimatorCompletion(block) {
        self.finalCompleteBlock = block;
    };
    
    return animator;
}


#pragma mark - Animator Delay
- (LSAnimatorTimeInterval)delay {
    LSAnimatorTimeInterval animator = LSAnimatorTimeInterval(t) {
        [[self.animatorChains lastObject] updateCurrentTurnLinkerAnimationsDelay:t];
        
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
        [[self.animatorChains lastObject] updateCurrentTurnLinkerAnimationsDuration:duration];
        [[self.animatorChains lastObject] repeat:count andIsAnimation:NO];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorTimeInterval)thenAfter {
    LSAnimatorTimeInterval animator = LSAnimatorTimeInterval(t) {
        [[self.animatorChains lastObject] thenAfter:t];
        
        return self;
    };
    
    return animator;
}

- (LSAnimatorAnimation)animate {
    LSAnimatorAnimation animator = LSAnimatorAnimation(duration) {
        [[self.animatorChains lastObject] updateCurrentTurnLinkerAnimationsDuration:duration];
        [self animateWithAnimatorChain:[self.animatorChains lastObject]];
    };
    
    return animator;
}

- (LSAnimatorAnimationWithRepeat)animateWithRepeat {
    LSAnimatorAnimationWithRepeat animator = LSAnimatorAnimationWithRepeat(duration, count) {
        [[self.animatorChains lastObject] updateCurrentTurnLinkerAnimationsDuration:duration];
        [[self.animatorChains lastObject] repeat:count andIsAnimation:YES];
        [self animateWithAnimatorChain:[self.animatorChains lastObject]];
    };
    
    return animator;
}

- (LSAnimatorAnimationWithCompletion)animateWithCompletion {
    LSAnimatorAnimationWithCompletion animator = LSAnimatorAnimationWithCompletion(duration, completion) {
        [[self.animatorChains lastObject] updateCurrentTurnLinkerAnimationsDuration:duration];
        [self.animatorChains lastObject].completeBlock = completion;
        [self animateWithAnimatorChain:[self.animatorChains lastObject]];
    };
    
    return animator;
}


#pragma mark - Multi-chain
- (LSAnimator *)concurrent {
    [self.animatorChains addObject:[LSAnimatorChain chainWithAnimator:self]];
    
    return self;
}

@end
