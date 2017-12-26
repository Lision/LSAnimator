//
//  LSAnimatorTests.m
//  LSAnimatorTests
//
//  Created by Lision on 2017/4/29.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LSAnimator.h"

#define kDuration 0.01

@interface LSAnimatorTests : XCTestCase

@property (nonatomic, strong) UIView *superView;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, weak, readonly) UIView *weakView;
@property (nonatomic, strong) LSAnimator *animtor;

@end

@implementation LSAnimatorTests

- (void)setUp {
    [super setUp];
    
    _superView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [_superView addSubview:_view];
    _weakView = _view;
    _animtor = [LSAnimator animatorWithView:_view];
}

- (void)tearDown {
    [_view removeFromSuperview];
    [super tearDown];
}

- (void)testMakeFrame {
    self.animtor.makeFrame(CGRectMake(0, 0, 20, 20)).animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGRect:self.weakView.layer.frame], [NSValue valueWithCGRect:CGRectMake(0, 0, 20, 20)], @"testls_frame error!");
    });
}

- (void)testMakeBounds {
    self.animtor.makeBounds(CGRectMake(0, 0, 20, 20)).animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGRect:self.weakView.bounds], [NSValue valueWithCGRect:CGRectMake(0, 0, 20, 20)], @"testls_bounds error!");
    });
}

- (void)testMakeSize {
    self.animtor.makeSize(20, 20).animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGSize:self.weakView.bounds.size], [NSValue valueWithCGSize:CGSizeMake(20, 20)], @"testls_size error!");
    });
}

- (void)testMakeOrigin {
    self.animtor.makeOrigin(20, 20).animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGPoint:self.weakView.frame.origin], [NSValue valueWithCGPoint:CGPointMake(20, 20)], @"testls_origin error!");
    });
}

- (void)testMakePosition {
    self.animtor.makePosition(20, 20).animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGPoint:self.weakView.center], [NSValue valueWithCGPoint:CGPointMake(20, 20)], @"testls_origin error!");
    });
}

- (void)testMakeX {
    self.animtor.makeX(0).animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.frame.origin.x, 0, @"testls_x error!");
    });
}

- (void)testMakeY {
    self.animtor.makeY(0).animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.frame.origin.y, 0, @"testls_y error!");
    });
}

- (void)testMakeWidth {
    self.animtor.makeWidth(100).animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.frame.size.width, 100, @"testls_width error!");
    });
}

- (void)testMakeHeight {
    self.animtor.makeHeight(100).animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.frame.size.height, 100, @"testls_height error!");
    });
}

- (void)testMakeOpacity {
    self.animtor.makeOpacity(0.2).animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.alpha, 0.2, @"testls_opacity error!");
    });
}

- (void)testMakeBackground {
    self.animtor.makeBackground([UIColor purpleColor]).animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects(self.weakView.backgroundColor, [UIColor purpleColor], @"testls_background error!");
    });
}

- (void)testMakeBorderColor {
    self.animtor.makeBorderColor([UIColor purpleColor]).animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects((__bridge UIColor *)self.weakView.layer.borderColor, [UIColor purpleColor], @"testls_borderColor error!");
    });
}

- (void)testMakeBorderWidth {
    self.animtor.makeBorderWidth(2.5f).animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.layer.borderWidth, 2.5f, @"testls_borderWidth error!");
    });
}

- (void)testMakeCornerRadius {
    self.animtor.makeCornerRadius(2.5f).animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.layer.cornerRadius, 2.5f, @"testls_cornerRadius error!");
    });
}

- (void)testMakeScale {
    self.animtor.makeScale(2).animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGRect:self.weakView.bounds], [NSValue valueWithCGRect:CGRectMake(0, 0, 20, 20)], @"testls_scale error!");
    });
}

- (void)testMakeScaleX {
    self.animtor.makeScaleX(2).animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGRect:self.weakView.bounds], [NSValue valueWithCGRect:CGRectMake(0, 0, 20, 10)], @"testls_scaleX error!");
    });
}

- (void)testMakeScaleY {
    self.animtor.makeScaleY(2).animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGRect:self.weakView.bounds], [NSValue valueWithCGRect:CGRectMake(0, 0, 10, 20)], @"testls_scaleY error!");
    });
}

- (void)testMakeAnchor {
    self.animtor.makeAnchor(0, 0).animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGPoint:self.weakView.layer.anchorPoint], [NSValue valueWithCGPoint:CGPointMake(0, 0)], @"testls_anchor error!");
    });
}

- (void)testMoveX {
    self.animtor.moveX(10).animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.frame.origin.x, 10, @"testls_moveX error!");
    });
}

- (void)testMoveY {
    self.animtor.moveY(10).animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.frame.origin.y, 10, @"testls_moveY error!");
    });
}

- (void)testMoveXY {
    self.animtor.moveXY(10, 20).animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGPoint:self.weakView.frame.origin], [NSValue valueWithCGPoint:CGPointMake(10, 20)], @"testls_moveXY error!");
    });
}

- (void)testIncreWidth {
    self.animtor.increWidth(20).animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.frame.size.width, 30, @"testls_increWidth error!");
    });
}

- (void)testIncreHeight {
    self.animtor.increHeight(20).animateWithCompletion(kDuration, ^{
        XCTAssertEqual(self.weakView.frame.size.height, 30, @"testls_increHeight error!");
    });
}

- (void)testIncreSize {
    self.animtor.increSize(-5, 20).animateWithCompletion(kDuration, ^{
        XCTAssertEqualObjects([NSValue valueWithCGRect:self.weakView.bounds], [NSValue valueWithCGRect:CGRectMake(0, 0, 5, 30)], @"testls_increSize error!");
    });
}

@end
