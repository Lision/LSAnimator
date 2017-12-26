//
//  UIView+Animator.swift
//  LSAnimatorSwiftDemo
//
//  Created by Lision on 2017/12/26.
//  Copyright © 2017年 Lision. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    public var animator: Animator {
        return Animator(view: self)
    }
}
