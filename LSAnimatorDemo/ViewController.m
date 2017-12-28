//
//  ViewController.m
//  LSAnimatorDemo
//
//  Created by Lision on 2017/12/28.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import "ViewController.h"
#import <LSAnimator/LSAnimator.h>

#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define BottomButtonHeight (iPhoneX ? (49.0f + 34.0f) : 49.0f)

@interface ViewController ()

@property (nonatomic, strong) UIView *animatorView;
@property (nonatomic, strong) UIButton *viewAnimatorBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"LSAnimator";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // UIView
    _animatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _animatorView.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:_animatorView];
    _animatorView.center = CGPointMake(self.view.center.x, self.view.center.y - 40);
    
    // UIView Animator Btn
    _viewAnimatorBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - BottomButtonHeight, self.view.bounds.size.width, BottomButtonHeight)];
    if (iPhoneX) {
        _viewAnimatorBtn.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 34, 10);
    }
    [_viewAnimatorBtn setBackgroundColor:[UIColor purpleColor]];
    [_viewAnimatorBtn setTitle:@"StartAnimation" forState:UIControlStateNormal];
    [self.view addSubview:_viewAnimatorBtn];
    [_viewAnimatorBtn addTarget:self action:@selector(viewAnimatorBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewAnimatorBtnDidClicked:(UIButton *)sender {
    // UIView
    sender.enabled = NO;
    [sender setBackgroundColor:[UIColor lightGrayColor]];
    
    // chain_01
    LSAnimator *animator = [LSAnimator animatorWithView:_animatorView];
    animator.increWidth(20).bounce.repeat(0.5, 3).increHeight(60).spring.thenAfter(1).makeCornerRadius(40).moveX(-20).thenAfter(1.5).wait(0.2).makeY(sender.frame.origin.y - 80).postAnimationBlock(^{
        LSAnimator *senderAnimator = [LSAnimator animatorWithView:sender];
        senderAnimator.moveY(sender.bounds.size.height).animate(0.2);
    }).thenAfter(0.2).moveY(-60).easeOut.thenAfter(0.2).moveY(109).bounce.animate(1);
    
    // chain_02
    animator.concurrent.makeBackground([UIColor cyanColor]).thenAfter(2).wait(1).makeBackground([UIColor orangeColor]).animate(2);
    
    // theFinalCompletion
    animator.theFinalCompletion(^{
        animator.makeCornerRadius(0).makeBackground([UIColor purpleColor]).makeBounds(CGRectMake(0, 0, 20, 20)).makePosition(self.view.center.x, self.view.center.y - 40).animate(0.5);
        LSAnimator *senderAnimator = [LSAnimator animatorWithView:sender];
        senderAnimator.moveY(-sender.bounds.size.height).makeBackground([UIColor purpleColor]).animateWithCompletion(0.5, ^{
            sender.enabled = YES;
        });
    });
}

@end
