//
//  LSAnimatorTests.m
//  LSAnimatorTests
//
//  Created by Lision on 2017/4/29.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIView+LSAnimator.h"
#import "CALayer+LSAnimator.h"

#define kDuration 0.01

@interface LSAnimatorTests : XCTestCase

@property (nonatomic, strong) UIView *superView;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, weak, readonly) UIView *weakView;

@end

@implementation LSAnimatorTests

- (void)setUp {
    [super setUp];
    
    _superView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [_superView addSubview:_view];
    _weakView = _view;
}

- (void)tearDown {
    [_view removeFromSuperview];
    
    [super tearDown];
}

- (void)testls_frame {
    self.view.ls_frame(CGRectMake(0, 0, 20, 20)).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGRect:self.weakView.frame], [NSValue valueWithCGRect:CGRectMake(0, 0, 20, 20)], @"testls_frame error!");
    });
    
    self.view.layer.ls_frame(CGRectMake(0, 0, 20, 20)).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGRect:self.weakView.layer.frame], [NSValue valueWithCGRect:CGRectMake(0, 0, 20, 20)], @"testls_frame error!");
    });
}

- (void)testls_bounds {
    self.view.ls_bounds(CGRectMake(0, 0, 20, 20)).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGRect:self.weakView.bounds], [NSValue valueWithCGRect:CGRectMake(0, 0, 20, 20)], @"testls_bounds error!");
    });
    
    self.view.layer.ls_bounds(CGRectMake(0, 0, 20, 20)).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGRect:self.weakView.layer.bounds], [NSValue valueWithCGRect:CGRectMake(0, 0, 20, 20)], @"testls_bounds error!");
    });
}

- (void)testls_size {
    self.view.ls_size(20, 20).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGSize:self.weakView.bounds.size], [NSValue valueWithCGSize:CGSizeMake(20, 20)], @"testls_size error!");
    });
    
    self.view.layer.ls_size(20, 20).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGSize:self.weakView.layer.bounds.size], [NSValue valueWithCGSize:CGSizeMake(20, 20)], @"testls_size error!");
    });
}

- (void)testls_origin {
    self.view.ls_origin(20, 20).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGPoint:self.weakView.frame.origin], [NSValue valueWithCGPoint:CGPointMake(20, 20)], @"testls_origin error!");
    });
    
    self.view.layer.ls_origin(20, 20).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGPoint:self.weakView.layer.frame.origin], [NSValue valueWithCGPoint:CGPointMake(20, 20)], @"testls_origin error!");
    });
}

- (void)testls_center {
    self.view.ls_center(20, 20).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGPoint:self.weakView.center], [NSValue valueWithCGPoint:CGPointMake(20, 20)], @"testls_origin error!");
    });
    
    self.view.layer.ls_position(20, 20).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGPoint:self.weakView.layer.position], [NSValue valueWithCGPoint:CGPointMake(20, 20)], @"testls_origin error!");
    });
}

- (void)testls_x {
    self.view.ls_x(0).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.frame.origin.x, 0, @"testls_x error!");
    });
    
    self.view.layer.ls_x(0).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.layer.frame.origin.x, 0, @"testls_x error!");
    });
}

- (void)testls_y {
    self.view.ls_y(0).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.frame.origin.y, 0, @"testls_y error!");
    });
    
    self.view.layer.ls_y(0).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.layer.frame.origin.y, 0, @"testls_y error!");
    });
}

- (void)testls_width {
    self.view.ls_width(100).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.frame.size.width, 100, @"testls_width error!");
    });
    
    self.view.layer.ls_width(100).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.layer.frame.size.width, 100, @"testls_width error!");
    });
}

- (void)testls_height {
    self.view.ls_height(100).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.frame.size.height, 100, @"testls_height error!");
    });
    
    self.view.layer.ls_height(100).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.layer.frame.size.height, 100, @"testls_height error!");
    });
}

- (void)testls_opacity {
    self.view.ls_opacity(0.2).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.alpha, 0.2, @"testls_opacity error!");
    });
    
    self.view.layer.ls_opacity(0.2).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.layer.opacity, 0.2, @"testls_opacity error!");
    });
}

- (void)testls_background {
    self.view.ls_background([UIColor purpleColor]).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects(self.weakView.backgroundColor, [UIColor purpleColor], @"testls_background error!");
    });
    
    self.view.layer.ls_background([UIColor purpleColor]).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects((__bridge UIColor *)self.weakView.layer.backgroundColor, [UIColor purpleColor], @"testls_background error!");
    });
}

- (void)testls_borderColor {
    self.view.ls_borderColor([UIColor purpleColor]).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects((__bridge UIColor *)self.weakView.layer.borderColor, [UIColor purpleColor], @"testls_borderColor error!");
    });
    
    self.view.layer.ls_borderColor([UIColor purpleColor]).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects((__bridge UIColor *)self.weakView.layer.borderColor, [UIColor purpleColor], @"testls_borderColor error!");
    });
}

- (void)testls_borderWidth {
    self.view.ls_borderWidth(2.5f).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.layer.borderWidth, 2.5f, @"testls_borderWidth error!");
    });
    
    self.view.layer.ls_borderWidth(2.5f).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.layer.borderWidth, 2.5f, @"testls_borderWidth error!");
    });
}

- (void)testls_cornerRadius {
    self.view.ls_cornerRadius(2.5f).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.layer.cornerRadius, 2.5f, @"testls_cornerRadius error!");
    });
    
    self.view.layer.ls_cornerRadius(2.5f).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.layer.cornerRadius, 2.5f, @"testls_cornerRadius error!");
    });
}

- (void)testls_scale {
    self.view.ls_scale(2).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGRect:self.weakView.bounds], [NSValue valueWithCGRect:CGRectMake(0, 0, 20, 20)], @"testls_scale error!");
    });
    
    self.view.layer.ls_scale(2).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGRect:self.weakView.layer.bounds], [NSValue valueWithCGRect:CGRectMake(0, 0, 20, 20)], @"testls_scale error!");
    });
}

- (void)testls_scaleX {
    self.view.ls_scaleX(2).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGRect:self.weakView.bounds], [NSValue valueWithCGRect:CGRectMake(0, 0, 20, 10)], @"testls_scaleX error!");
    });
    
    self.view.layer.ls_scaleX(2).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGRect:self.weakView.layer.bounds], [NSValue valueWithCGRect:CGRectMake(0, 0, 20, 10)], @"testls_scaleX error!");
    });
}

- (void)testls_scaleY {
    self.view.ls_scaleY(2).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGRect:self.weakView.bounds], [NSValue valueWithCGRect:CGRectMake(0, 0, 10, 20)], @"testls_scaleY error!");
    });
    
    self.view.layer.ls_scaleY(2).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGRect:self.weakView.layer.bounds], [NSValue valueWithCGRect:CGRectMake(0, 0, 10, 20)], @"testls_scaleY error!");
    });
}

- (void)testls_anchor {
    self.view.ls_anchor(0, 0).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGPoint:self.weakView.layer.anchorPoint], [NSValue valueWithCGPoint:CGPointMake(0, 0)], @"testls_anchor error!");
    });
    
    self.view.layer.ls_anchor(0, 0).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGPoint:self.weakView.layer.anchorPoint], [NSValue valueWithCGPoint:CGPointMake(0, 0)], @"testls_anchor error!");
    });
}

- (void)testls_moveX {
    self.view.ls_moveX(10).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.frame.origin.x, 10, @"testls_moveX error!");
    });
    
    self.view.layer.ls_moveX(10).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.layer.frame.origin.x, 10, @"testls_moveX error!");
    });
}

- (void)testls_moveY {
    self.view.ls_moveY(10).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.frame.origin.y, 10, @"testls_moveY error!");
    });
    
    self.view.layer.ls_moveY(10).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.layer.frame.origin.y, 10, @"testls_moveY error!");
    });
}

- (void)testls_moveXY {
    self.view.ls_moveXY(10, 20).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGPoint:self.weakView.frame.origin], [NSValue valueWithCGPoint:CGPointMake(10, 20)], @"testls_moveXY error!");
    });
    
    self.view.layer.ls_moveXY(10, 20).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGPoint:self.weakView.layer.frame.origin], [NSValue valueWithCGPoint:CGPointMake(10, 20)], @"testls_moveXY error!");
    });
}

- (void)testls_increWidth {
    self.view.ls_increWidth(20).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.frame.size.width, 30, @"testls_increWidth error!");
    });
    
    self.view.layer.ls_increWidth(20).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.layer.frame.size.width, 30, @"testls_increWidth error!");
    });
}

- (void)testls_increHeight {
    self.view.ls_increHeight(20).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.frame.size.height, 30, @"testls_increHeight error!");
    });
    
    self.view.layer.ls_increHeight(20).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.layer.frame.size.height, 30, @"testls_increHeight error!");
    });
}

- (void)testls_increSize {
    self.view.ls_increSize(-5, 20).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGRect:self.weakView.bounds], [NSValue valueWithCGRect:CGRectMake(0, 0, 5, 30)], @"testls_increSize error!");
    });
    
    self.view.layer.ls_increSize(-5, 20).ls_animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGRect:self.weakView.layer.bounds], [NSValue valueWithCGRect:CGRectMake(0, 0, 5, 30)], @"testls_increSize error!");
    });
}

@end
