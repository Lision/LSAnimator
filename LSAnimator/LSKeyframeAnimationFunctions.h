//
//  LSKeyframeAnimationFunctions.h
//  LSAnimator
//
//  Created by Lision on 2017/4/29.
//  Copyright © 2017年 Lision. All rights reserved.
//

#ifndef LSKeyframeAnimationFunctions_h
#define LSKeyframeAnimationFunctions_h

typedef double (*LSKeyframeAnimationFunction)(double, double, double, double);

double LSKeyframeAnimationFunctionLinear(double t, double b, double c, double d);

double LSKeyframeAnimationFunctionEaseInQuad(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseOutQuad(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseInOutQuad(double t, double b, double c, double d);

double LSKeyframeAnimationFunctionEaseInCubic(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseOutCubic(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseInOutCubic(double t, double b, double c, double d);

double LSKeyframeAnimationFunctionEaseInQuart(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseOutQuart(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseInOutQuart(double t, double b, double c, double d);

double LSKeyframeAnimationFunctionEaseInQuint(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseOutQuint(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseInOutQuint(double t, double b, double c, double d);

double LSKeyframeAnimationFunctionEaseInSine(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseOutSine(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseInOutSine(double t, double b, double c, double d);

double LSKeyframeAnimationFunctionEaseInExpo(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseOutExpo(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseInOutExpo(double t, double b, double c, double d);

double LSKeyframeAnimationFunctionEaseInCirc(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseOutCirc(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseInOutCirc(double t, double b, double c, double d);

double LSKeyframeAnimationFunctionEaseInElastic(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseOutElastic(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseInOutElastic(double t, double b, double c, double d);

double LSKeyframeAnimationFunctionEaseInBack(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseOutBack(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseInOutBack(double t, double b, double c, double d);

double LSKeyframeAnimationFunctionEaseInBounce(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseOutBounce(double t, double b, double c, double d);
double LSKeyframeAnimationFunctionEaseInOutBounce(double t, double b, double c, double d);

#endif /* LSKeyframeAnimationFunctions_h */
