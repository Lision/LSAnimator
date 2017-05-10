//
//  ViewController.m
//  LSAnimatorDemo
//
//  Created by Lision on 2017/5/3.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import "ViewController.h"
#import "UIView+LSAnimator.h"
#import "CALayer+LSAnimator.h"

@interface ViewController ()

@property (nonatomic, strong) UIView *animatorView;
@property (nonatomic, strong) UIButton *animatorBtn;


@property (nonatomic, strong) CALayer *layer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _animatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _animatorView.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:_animatorView];
    _animatorView.center = CGPointMake(self.view.center.x, self.view.center.y - 20);
    
    
    _layer = [CALayer layer];
    _layer.frame = CGRectMake(50, 50, 20, 20);
    _layer.backgroundColor = [UIColor redColor].CGColor;
//    _layer.position = CGPointMake(self.view.center.x, self.view.center.y - 20);

    [self.view.layer addSublayer:_layer];
    
    
    _animatorBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 49, self.view.bounds.size.width, 49)];
    [_animatorBtn setBackgroundColor:[UIColor lightGrayColor]];
    [_animatorBtn setTitle:@"start test" forState:UIControlStateNormal];
    [self.view addSubview:_animatorBtn];
    [_animatorBtn addTarget:self action:@selector(animatorBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)animatorBtnDidClicked:(UIButton *)sender {
    sender.enabled = NO;
    // chain_01
    _animatorView.ls_increWidth(20).ls_bounce.ls_repeat(0.5, 3).ls_increHeight(60).ls_spring.ls_thenAfter(1).ls_cornerRadius(40).ls_moveX(-100).ls_thenAfter(1.5).ls_wait(0.2).ls_y(_animatorBtn.frame.origin.y - 80).ls_postAnimationBlock(^{
        sender.ls_moveY(sender.bounds.size.height).ls_animate(0.2);
    }).ls_thenAfter(0.2).ls_moveY(-60).ls_easeOut.ls_thenAfter(0.2).ls_moveY(109).ls_bounce.ls_animate(1);
    // chain_02
    _animatorView.ls_concurrent.ls_background([UIColor orangeColor]).ls_delay(0.75).ls_animate(1);
    // theFinalCompletion
    _animatorView.ls_theFinalCompletion(^{
        _animatorView.ls_cornerRadius(0).ls_background([UIColor purpleColor]).ls_bounds(CGRectMake(0, 0, 20, 20)).ls_center(self.view.center.x, self.view.center.y - 20).ls_animate(0.5);
        sender.ls_moveY(-sender.bounds.size.height).ls_animateWithCompletion(0.5, ^{
            sender.enabled = YES;
        });
    });

    
//    layer 动画执行 的时候 也执行了隐式动画
    _layer.ls_increWidth(20).ls_bounce.ls_repeat(0.5, 3).ls_increHeight(60).ls_spring.ls_thenAfter(1).ls_cornerRadius(40).ls_thenAfter(1.5).ls_wait(0.2).ls_y(_animatorBtn.frame.origin.y - 80).ls_postAnimationBlock(^{
        sender.ls_moveY(sender.bounds.size.height).ls_animate(0.2);
    }).ls_thenAfter(0.2).ls_moveY(-60).ls_easeOut.ls_thenAfter(0.2).ls_moveY(109).ls_bounce.ls_animate(1);
    _layer.ls_concurrent.ls_background([UIColor orangeColor]).ls_delay(1.5).ls_animate(1);
    _layer.ls_theFinalCompletion(^{
        _layer.ls_cornerRadius(0).ls_bounds(CGRectMake(0, 0, 20, 20)).ls_position(self.view.center.x, self.view.center.y - 20).ls_animate(0.5);
        sender.ls_moveY(-sender.bounds.size.height).ls_animateWithCompletion(0.5, ^{
            sender.enabled = YES;
        });
    });
    

    
    
}

@end
