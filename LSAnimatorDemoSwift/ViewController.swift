//
//  ViewController.swift
//  LSAnimatorDemoSwift
//
//  Created by Lision on 2017/12/28.
//  Copyright © 2017年 Lision. All rights reserved.
//

import UIKit
import CoreAnimator

extension UIDevice {
    public func isX() -> Bool {
        if UIScreen.main.bounds.height == 812 {
            return true
        }
        return false
    }
}

class ViewController: UIViewController {
    
    let btnHeight = UIDevice.current.isX() ? 83.0 : 49.0
    let animatorView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    let animatorBtn: UIButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CoreAnimator"
        view.backgroundColor = .white
        
        animatorView.backgroundColor = .purple
        view.addSubview(animatorView)
        animatorView.center = CGPoint(x: view.center.x, y: view.center.y - 40)
        
        animatorBtn.frame = CGRect(x: 0, y: self.view.bounds.size.height - CGFloat(btnHeight), width: view.bounds.size.width, height: CGFloat(btnHeight))
        if UIDevice.current.isX() {
            animatorBtn.titleEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 34, right: 10)
        }
        animatorBtn.backgroundColor = .purple
        animatorBtn.setTitle("StartAnimation", for: .normal)
        view.addSubview(animatorBtn)
        animatorBtn.addTarget(self, action: #selector(animatorBtnDidClicked), for: .touchUpInside)
    }
    
    @objc func animatorBtnDidClicked() {
        animatorBtn.isEnabled = false
        animatorBtn.backgroundColor = .lightGray
        
        let animator = CoreAnimator(view: animatorView)
        animator.incre(width: 20).bounce.repeat(t: 0.5, count: 3).incre(height: 60).spring.thenAfter(t: 1).make(cornerRadius: 40).move(x: -20).thenAfter(t: 1.5).wait(t: 0.2).make(y: Double(animatorBtn.frame.origin.y - 80)).postAnimationBlock {
            let btnAnimator = CoreAnimator(view:self.animatorBtn)
            btnAnimator.move(y: Double(self.animatorBtn.bounds.size.height)).animate(t: 0.2)
        }.thenAfter(t: 0.2).move(y: -60).easeOut.thenAfter(t: 0.2).move(y: 109).bounce.animate(t: 1)
        
        animator.concurrent.make(backgroundColor: .cyan).thenAfter(t: 2).wait(t: 1).make(backgroundColor: .orange).animate(t: 2)
        
        animator.theFinalCompletion {
            animator.make(cornerRadius: 0).make(backgroundColor: .purple).make(bounds: CGRect(x: 0, y: 0, width: 20, height: 20)).makePosition(x: Double(self.view.center.x), y: Double(self.view.center.y - 40)).animate(t: 0.5)
            let btnAnimator = CoreAnimator(view:self.animatorBtn)
            btnAnimator.move(y: -self.btnHeight).make(backgroundColor: .purple).animate(t: 0.5, completion: {
                self.animatorBtn.isEnabled = true
            })
        }
    }
    
}

