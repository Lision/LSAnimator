//
//  LSKeyframeAnimation.h
//  LSAnimator
//
//  Created by Lision on 2017/4/30.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef double(^LSKeyframeAnimationFunctionBlock)(double t, double b, double c, double d);

@interface LSKeyframeAnimation : CAKeyframeAnimation

@property (nonatomic, copy) LSKeyframeAnimationFunctionBlock functionBlock;

@property (nonatomic, strong) id fromValue;
@property (nonatomic, strong) id toValue;

- (void)calculate;

@end
