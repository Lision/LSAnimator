//
//  ViewController.m
//  LSAnimatorDemo
//
//  Created by Lision on 2017/5/3.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import "ViewController.h"
#import "LSAnimator.h"

@interface ViewController ()

@property (nonatomic, strong) CALayer *animatorLayer;
@property (nonatomic, strong) UIView *animatorView;
@property (nonatomic, strong) UIButton *viewAnimatorBtn;
@property (nonatomic, strong) UIButton *layerAnimatorBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // CALayer
    _animatorLayer = [CALayer layer];
    _animatorLayer.bounds = CGRectMake(0, 0, 20, 20);
    _animatorLayer.backgroundColor = [UIColor purpleColor].CGColor;
    [self.view.layer addSublayer:_animatorLayer];
    _animatorLayer.position = CGPointMake(self.view.center.x * 0.5, self.view.center.y - 20);

    // UIView
    _animatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _animatorView.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:_animatorView];
    _animatorView.center = CGPointMake(self.view.center.x * 1.5, self.view.center.y - 20);
    
    // CALayer Animator Btn
    _layerAnimatorBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 49, self.view.bounds.size.width * 0.5, 49)];
    [_layerAnimatorBtn setBackgroundColor:[UIColor lightGrayColor]];
    [_layerAnimatorBtn setTitle:@"CALayerAnimator" forState:UIControlStateNormal];
    [self.view addSubview:_layerAnimatorBtn];
    [_layerAnimatorBtn addTarget:self action:@selector(layerAnimatorBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // UIView Animator Btn
    _viewAnimatorBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height - 49, self.view.bounds.size.width * 0.5, 49)];
    [_viewAnimatorBtn setBackgroundColor:[UIColor lightGrayColor]];
    [_viewAnimatorBtn setTitle:@"UIViewAnimator" forState:UIControlStateNormal];
    [self.view addSubview:_viewAnimatorBtn];
    [_viewAnimatorBtn addTarget:self action:@selector(viewAnimatorBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // Split Line
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5, self.view.bounds.size.height)];
    line.center = self.view.center;
    line.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line];
}

- (void)layerAnimatorBtnDidClicked:(UIButton *)sender {
    // CALayer
    sender.enabled = NO;
    // chain_01
    LSAnimator *animator = [LSAnimator animatorWithLayer:_animatorLayer];
    animator.increWidth(20).bounce.repeat(0.5, 3).increHeight(60).spring.thenAfter(1).makeCornerRadius(40).moveX(-20).thenAfter(1.5).wait(0.2).makeY(sender.frame.origin.y - 80).postAnimationBlock(^{
        LSAnimator *senderAnimator = [LSAnimator animatorWithView:sender];
        senderAnimator.moveY(sender.bounds.size.height).animate(0.2);
    }).thenAfter(0.2).moveY(-60).easeOut.thenAfter(0.2).moveY(109).bounce.animate(1);
    // chain_02
    animator.concurrent.makeBackground([UIColor orangeColor]).delay(0.75).animate(1);
    // theFinalCompletion
    animator.theFinalCompletion(^{
        animator.makeCornerRadius(0).makeBackground([UIColor purpleColor]).makeBounds(CGRectMake(0, 0, 20, 20)).makePosition(self.view.center.x * 0.5, self.view.center.y - 20).animate(0.5);
        LSAnimator *senderAnimator = [LSAnimator animatorWithView:sender];
        senderAnimator.moveY(-sender.bounds.size.height).animateWithCompletion(0.5, ^{
            sender.enabled = YES;
        });
    });
}

- (void)viewAnimatorBtnDidClicked:(UIButton *)sender {
//    // UIView
//    sender.enabled = NO;
//    // chain_01
//    _animatorView.ls_increWidth(20).ls_bounce.ls_repeat(0.5, 3).ls_increHeight(60).ls_spring.ls_thenAfter(1).ls_cornerRadius(40).ls_moveX(-20).ls_thenAfter(1.5).ls_wait(0.2).ls_y(sender.frame.origin.y - 80).ls_postAnimationBlock(^{
//        sender.ls_moveY(sender.bounds.size.height).ls_animate(0.2);
//    }).ls_thenAfter(0.2).ls_moveY(-60).ls_easeOut.ls_thenAfter(0.2).ls_moveY(109).ls_bounce.ls_animate(1);
//    // chain_02
//    _animatorView.ls_concurrent.ls_background([UIColor orangeColor]).ls_delay(0.75).ls_animate(1);
//    // theFinalCompletion
//    _animatorView.ls_theFinalCompletion(^{
//        _animatorView.ls_cornerRadius(0).ls_background([UIColor purpleColor]).ls_bounds(CGRectMake(0, 0, 20, 20)).ls_center(self.view.center.x * 1.5, self.view.center.y - 20).ls_animate(0.5);
//        sender.ls_moveY(-sender.bounds.size.height).ls_animateWithCompletion(0.5, ^{
//            sender.enabled = YES;
//        });
//    });
}

@end
