//
//  LSAnimator.h
//  LSAnimator
//
//  Created by Lision on 2017/5/3.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __has_include(<LSAnimator/LSAnimator.h>)

FOUNDATION_EXPORT double LSAnimatorVersionNumber;
FOUNDATION_EXPORT const unsigned char LSAnimatorVersionString[];

#import "UIView+LSAnimator.h"
#import "CALayer+LSAnimator.h"

#else

#import "UIView+LSAnimator.h"
#import "CALayer+LSAnimator.h"

#endif
