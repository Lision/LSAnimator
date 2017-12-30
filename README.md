![](Rources/LSAnimatorLogo.jpg)

[![language](https://img.shields.io/badge/Language-Objective--C-7D6FFF.svg)](https://developer.apple.com/documentation/objectivec)&nbsp;
[![language](https://img.shields.io/badge/Language-Swift-6986FF.svg)](https://github.com/apple/swift)&nbsp;
[![CocoaPods](https://img.shields.io/cocoapods/v/LSAnimator.svg?style=flat)](http://cocoapods.org/pods/LSAnimator)&nbsp;
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)&nbsp;
[![Build Status](https://api.travis-ci.org/Lision/LSAnimator.svg?branch=master)](https://travis-ci.org/Lision/LSAnimator)&nbsp;
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/Lision/LSAnimator/master/LICENSE)&nbsp;
[![CocoaPods](https://img.shields.io/cocoapods/p/LSAnimator.svg?style=flat)](http://cocoadocs.org/docsets/LSAnimator)&nbsp;
[![Support](https://img.shields.io/badge/support-iOS%207%2B%20-orange.svg?style=flat)](https://www.apple.com/nl/ios/)

# Why Choose LSAnimator & CoreAnimator?

You can write complex and easy-to-maintain animations in just a few lines of code by use LSAnimator(Objective-C) or CoreAnimator(Swift).

![Objective-C](Rources/LSAnimatorDemo.gif)
![Swift](Rources/CoreAnimatorDemo.gif)

# What's The Multi-chain Animations?

CAAnimations and UIView animations are extremely powerful, but it is very hard to read when the animation is complicated.

Say I want to move myView 100 pixels to the right with spring and then incre 30 pixels to the width with inward easing when the movement has finished:

## The Old Way

``` objc
[UIView animateWithDuration:2.0
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:1.0
                        options:0
                     animations:^{
                         CGPoint newPosition = self.myView.frame.origin;
                         newPosition.x += 100;
                         self.myView.frame = CGRectMake(newPosition.x, newPosition.y, self.myView.frame.size.width, self.myView.frame.size.height);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:2.0
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              CGSize newSize = self.myView.frame.size;
                                              newSize.width += 30;
                                              self.myView.frame = CGRectMake(self.myView.frame.origin.x, self.myView.frame.origin.y, newSize.width, newSize.height);
                                          } completion:nil];
                     }];
```

Thats pretty gross huh... With LSAnimator it is one line of code.

## Using LSAnimator

``` objc
LSAnimator *animator = [LSAnimator animatorWithView:self.myView];
animator.moveX(100).spring.thenAfter(2).increWidth(30).easeIn.animate(2);
```

Emmmmm...There is an animation library called JHChainableAnimations can also do this.

## Whats wrong with JHChainableAnimations?

[JHChainableAnimations](https://github.com/jhurray/JHChainableAnimations) has powerful chainable animations AND easy to read/write syntax, but it does not support for Multi-chain Animations.

Following the example above, assume now that the whole animation chain above needs to change the transparency of my view to zero at the same time:

### Using LSAnimator

![LSAnimator](Rources/LSAnimatorEffect.gif)

With LSAnimator it is just need to add one line of code.

``` objc
LSAnimator *animator = [LSAnimator animatorWithView:self.myView];
animator.moveX(100).spring.thenAfter(2).increWidth(30).easeIn.animate(2);
animator.concurrent.makeOpacity(0).animate(4);
```

### Using JHChainableAnimations

![JHChainableAnimations](Rources/JHChainableAnimationsEffect.gif)

Emmmmm...With JHChainableAnimations it is can not finished task. Trying to add the following code will cause the animation bug or crash.

``` objc
JHChainableAnimator *animator = [[JHChainableAnimator alloc] initWithView:self.myView];
animator.moveX(100).spring.thenAfter(2).moveWidth(30).easeIn.animate(2);
animator.makeOpacity(0).animate(4);
```

# LSAnimator VS JHChainableAnimations

- **Multi-chain Animations:** Can complete all animation design needs, More flexible than JHChainableAnimations.
- **CALayer Support:** Support CALayer initialization, JHChainableAnimations only supports UIView.
- **Parameter Auto-completion:** Support parameter auto-completion, JHChainableAnimations does not support.

![LSAnimator](Rources/PACLSAnimator.gif)

![JHChainableAnimations](Rources/PACJHChainableAnimations.gif)

JHChainableAnimations is still a really good animation library and LSAnimator is standing on the shoulders of it.

# Features

- **Multi-chain Animations**
- **CALayer Support**
- **Parameter Auto-completion**
- **Support for Animation Hooks**
- **Swift 3.2 ~ 4 Support**
- **Friendly Swift Interface**
- **Non-intrusive**
- **Unit Testing**

# Usage

Emmmmm...

# Installation

## Cocoapods

### Objective-C

1. Add `pod 'LSAnimator', '~> 2.1.0'` to your Podfile.
2. Run `pod install` or `pod update`.
3. Add `#import <LSAnimator/LSAnimator.h>`.

### Swift

1. Add `pod 'CoreAnimator', '~> 2.1.0'` to your Podfile.
2. Run `pod install` or `pod update`.
3. Add `import CoreAnimator`.

## Carthage

1. Add `github "Lision/LSAnimator" ~> 2.1.0` to your Cartfile.
2. Run `carthage update --platform ios`.

### Objective-C

Add the `LSAnimator` framework to your project.

### Swift

Add the `CoreAnimator` framework to your project.

## Manually

Either clone the repo and manually add the Files in [LSAnimator](https://github.com/Lision/LSAnimator/tree/master/LSAnimator)

# Requirements

- LSAnimator requires `iOS 7.0+`.
- CoreAnimator requires `iOS 9.0+`.

# Contact

- Email: lisionmail@gmail.com
- Sina: [@Lision](https://weibo.com/5071795354/profile)
- Twitter: [@Lision](https://twitter.com/LisionChat)

# License

![](https://camo.githubusercontent.com/5e085da09b057cc65da38f334ab63f0c2705f46a/68747470733a2f2f75706c6f61642e77696b696d656469612e6f72672f77696b6970656469612f636f6d6d6f6e732f7468756d622f662f66382f4c6963656e73655f69636f6e2d6d69742d38387833312d322e7376672f31323870782d4c6963656e73655f69636f6e2d6d69742d38387833312d322e7376672e706e67)

LSAnimator is provided under the MIT license. See LICENSE file for details.