![](logo.png)


# LSAnimator

Easy to read and write non-intrusive multi-chain animation kits，is inspired by JHChainableAnimations.


# LSAnimator 动画师

易于阅读和写入的非侵入式可多链式动画框架，灵感来源于 JHChainableAnimations。

在我初尝 JHChainableAnimations 链式动画框架时对它的感觉非常赞，我认为它使用了 DSL(Domain Specific Language) 的概念，将官方繁杂的动画 API (包含 UIView 和 CACoreAnimation) 转为了自己的 DSL 语言。这使得它在处理动画这一指定领域变得精简而高效，所以我尽可能的保留了其作为单链动画的所有优点。不过其作为单链式动画框架的缺点也是显而易见的，当动画交互稍微复杂，存在多个动画相互独立（某些动画之间有先后次序可以放入一个动画链而某些独立其外）时 JHChainableAnimations 就显得比较无力了。

下面对比一下单链式动画和多链式动画的差异：

#### 单链式动画

| code | animation |
| ---- | --------- |
| `_animatorView.ls_moveX(80).ls_animate(1);` | ![](Rources/demo_01.gif) |
| `_animatorView.ls_increWidth(20).ls_bounce.ls_animateWithRepeat(0.5, 3);` | ![](Rources/demo_02.gif) |
| `_animatorView.ls_scale(2).ls_background([UIColor orangeColor]).ls_cornerRadius(20).ls_thenAfter(0.5).ls_moveY(40).ls_bounce.ls_animate(0.5);` | ![](Rources/demo_03.gif) |

你或许已经注意到，在上面第三个单链式动画中，改变背景颜色的动画与改变大小的动画被放入了链条的同一节点。如果你所在公司的动画交互设计师让你在改变大小之后的若干时间才开始改变颜色，且改变颜色的时长独立于大小和位移的动画链，那么很遗憾的告诉你，单链式动画无法实现上述的动画交互效果。

所以我才在 JHChainableAnimations 的基础上做了多链式动画框架 LSAnimator。

#### 多链式动画

![](Rources/demo_04.gif)


``` objc
_animatorView.ls_scale(2).ls_cornerRadius(20).ls_thenAfter(0.5).ls_moveY(40).ls_bounce.ls_animate(0.5);
    _animatorView.ls_concurrent.ls_background([UIColor orangeColor]).ls_delay(0.25).ls_animate(0.8);
```

如上所示，可以把逻辑上不相关的动画（上面例子是改变颜色的动画）独立出来放到另一个动画链去执行，以实现复杂的动画交互需求。

# 安装

### CocoaPods

1. 在 Podfile 中添加 `pod 'LSAnimator'`
2. 执行 `pod install` 或者 `pod update`
3. 导入 `<LSAnimator/LSAnimator.h>`

### 手动安装

1. 下载 LSAnimator 文件夹中的所有文件
2. 将源文件添加（拖放）到你的工程
3. 导入对应头文件 `UIView+LSAnimator.h`

# 用法

非侵入性集成，直接在你所要添加动画效果的 `UIView` 上面按照下述 API 书写动画即可。

### 多链式动画属性

#### 设置目标值的动画

| 属性名称 | 参数 | 用法 | 描述 |
| --- | :---: | --- | --- |
| ls_frame | `CGRect` | `view.ls_frame(rect)` | 在当前节点添加设置 frame 的动画 |
| ls_bounds | `CGRect` | `view.ls_bounds(rect)` | 在当前节点添加设置 bounds 的动画 |
| ls_size | `CGSize` | `view.ls_size(size)` | 在当前节点添加设置 bounds.size 的动画 |
| ls_origin | `CGPoint` | `view.ls_origin(point)` | 在当前节点添加设置 frame.origin 的动画 |
| ls_center | `CGPoint` | `view.ls_center(point)` | 在当前节点添加设置 center 的动画 |
| ls_x | `CGFloat` | `view.ls_x(float)` | 在当前节点添加设置 frame.origin.x 的动画 |
| ls_y | `CGFloat` | `view.ls_y(float)` | 在当前节点添加设置 frame.origin.y 的动画 |
| ls_width | `CGFloat` | `view.ls_width(float)` | 在当前节点添加设置 bounds.size.with 的动画 |
| ls_height | `CGFloat` | `view.ls_height(float)` | 在当前节点添加设置 bounds.size.height 的动画 |
| ls_opacity | `CGFloat` | `view.ls_opacity(float)` | 在当前节点添加设置透明度的动画 |
| ls_background | `UIColor` | `view.ls_background(color)` | 在当前节点添加设置 backgroundColor 的动画 |
| ls_borderColor | `UIColor` | `view.ls_borderColor(color)` | 在当前节点添加设置 layer.borderColor 的动画 |
| ls_borderWidth | `CGFloat ` | `view.ls_borderWidth(float)` | 在当前节点添加设置 layer.borderWidth 的动画 |
| ls_cornerRadius | `CGFloat ` | `view.ls_cornerRadius(float)` | 在当前节点添加设置 layer.cornerRadius 的动画 |
| ls_scale | `CGFloat ` | `view.ls_scale(float)` | 在当前节点添加设置 bounds.size 的倍数动画 |
| ls_scaleX | `CGFloat ` | `view.ls_scaleX(float)` | 在当前节点添加设置 bounds.size.width 的倍数动画 |
| ls_scaleY | `CGFloat ` | `view.ls_scaleY(float)` | 在当前节点添加设置 bounds.size.height 的倍数动画 |
| ls_anchor | `CGPoint ` | `view.ls_anchor(point)` | 在当前节点动画之前设置 layer.anchorPoint |

#### 增量动画

| 属性名称 | 参数 | 用法 | 描述 |
| --- | :---: | --- | --- |
| ls_moveX | `CGFloat` | `view.ls_moveX(float)` | 在当前节点添加 x 轴位移 float 的动画 |
| ls_moveY | `CGFloat` | `view.ls_moveY(float)` | 在当前节点添加 y 轴位移 float 的动画 |
| ls_moveXY | `CGPoint` | `view.ls_moveXY(point)` | 上述动画合并 |
| ls_movePolar | `CGFloat，CGFloat` | `view.ls_movePolar(radius, angle)` | 一般用作波浪位移动画 |
| ls_increWidth | `CGFloat` | `view.ls_increWidth(float)` | 在当前节点添加 bounds.size.width 增量动画 |
| ls_increHeight | `CGFloat` | `view.ls_increHeight(float)` | 在当前节点添加 bounds.size.height 增量动画 |
| ls_increSize | `CGSize` | `view. ls_increSize(size)` | 在当前节点添加 bounds.size 增量动画 |

#### 转换动画

| 属性名称 | 参数 | 用法 |
| --- | :---: | --- |
| ls_transformIdentity | --- | `view.ls_transformIdentity ` |
| ls_rotate | `CGFloat` | `view.ls_rotate(float) ` |
| ls_rotateX | `CGFloat` | `view.ls_rotateX(float) ` |
| ls_rotateY | `CGFloat` | `view.ls_rotateY(float) ` |
| ls_rotateZ | `CGFloat` | `view.ls_rotateZ(float) ` |
| ls_transformX | `CGFloat` | `view.ls_transformX(float) ` |
| ls_transformY | `CGFloat` | `view.ls_transformY(float) ` |
| ls_transformZ | `CGFloat` | `view.ls_transformZ(float) ` |
| ls_transformXY | `CGPoint` | `view.ls_transformXY(point) ` |
| ls_transformScaleX | `CGFloat` | `view.ls_transformScaleX(float) ` |
| ls_transformScaleY | `CGFloat` | `view.ls_transformScaleY(float) ` |
| ls_transformScale | `CGFloat` | `view.ls_transformScale(float) ` |

#### 贝塞尔曲线动画

| 属性名称 | 参数 | 用法 |
| --- | --- | --- |
| ls_moveOnPath | `UIBezierPath` | `view.ls_moveOnPath(path) ` |
| ls_moveAndRotateOnPath | `UIBezierPath` | `view.ls_moveAndRotateOnPath(path) ` |
| ls_moveAndReverseRotateOnPath | `UIBezierPath` | `view.ls_moveAndReverseRotateOnPath(path) ` |

#### 设置锚点

| 属性名称 | 参数 | 用法 |
| --- | :---: | --- |
| ls_anchorDefault | --- | `view.ls_anchorDefault` |
| ls_anchorCenter | --- | `view.ls_anchorCenter` |
| ls_anchorTop | --- | `view.ls_anchorTop` |
| ls_anchorBottom | --- | `view.ls_anchorBottom` |
| ls_anchorLeft | --- | `view.ls_anchorLeft` |
| ls_anchorRight | --- | `view.ls_anchorRight` |
| ls_anchorTopLeft | --- | `view.ls_anchorTopLeft` |
| ls_anchorTopRight | --- | `view.ls_anchorTopRight` |
| ls_anchorBottomLeft | --- | `view.ls_anchorBottomLeft` |
| ls_anchorBottomRight | --- | `view.ls_anchorBottomRight` |

#### 动画曲线

![](Rources/animation_curves.png)

| 属性名称 | 参数 | 用法 |
| --- | :---: | --- |
| ls_easeIn | --- | `view.ls_easeIn` |
| ls_easeOut | --- | `view.ls_easeOut` |
| ls_easeInOut | --- | `view.ls_easeInOut` |
| ls_easeBack | --- | `view.ls_easeBack` |
| ls_spring | --- | `view.ls_spring` |
| ls_bounce | --- | `view.ls_bounce` |
| ls_easeInQuad | --- | `view.ls_easeInQuad` |
| ls_easeOutQuad | --- | `view.ls_easeOutQuad` |
| ls_easeInOutQuad | --- | `view.ls_easeInOutQuad` |
| ls_easeInCubic | --- | `view.ls_easeInCubic` |
| ls_easeOutCubic | --- | `view.ls_easeOutCubic` |
| ls_easeInOutCubic | --- | `view.ls_easeInOutCubic` |
| ls_easeInQuart | --- | `view.ls_easeInQuart` |
| ls_easeOutQuart | --- | `view.ls_easeOutQuart` |
| ls_easeInOutQuart | --- | `view.ls_easeInOutQuart` |
| ls_easeInSine | --- | `view.ls_easeInSine` |
| ls_easeOutSine | --- | `view.ls_easeOutSine` |
| ls_easeInOutSine | --- | `view.ls_easeInOutSine` |
| ls_easeInExpo | --- | `view.ls_easeInExpo` |
| ls_easeOutExpo | --- | `view.ls_easeOutExpo` |
| ls_easeInOutExpo | --- | `view.ls_easeInOutExpo` |
| ls_easeInCirc | --- | `view.ls_easeInCirc` |
| ls_easeOutCirc | --- | `view.ls_easeOutCirc` |
| ls_easeInOutCirc | --- | `view.ls_easeInOutCirc` |
| ls_easeInElastic | --- | `view.ls_easeInElastic` |
| ls_easeOutElastic | --- | `view.ls_easeOutElastic` |
| ls_easeInOutElastic | --- | `view.ls_easeInOutElastic` |
| ls_easeInBack | --- | `view.ls_easeInBack` |
| ls_easeOutBack | --- | `view.ls_easeOutBack` |
| ls_easeInOutBack | --- | `view.ls_easeInOutBack` |
| ls_easeInBounce | --- | `view.ls_easeInBounce` |
| ls_easeOutBounce | --- | `view.ls_easeOutBounce` |
| ls_easeInOutBounce | --- | `view.ls_easeInOutBounce` |

#### Hooks

| 属性名称 | 参数 | 用法 | 描述 |
| --- | :---: | --- | --- |
| ls_preAnimationBlock | `Block` | `view.ls_preAnimationBlock(block)` | 设置在当前动画节点执行动画之前执行的 block |
| ls_postAnimationBlock | `Block ` | `view.ls_postAnimationBlock(block)` | 设置在当前动画节点执行动画之后执行的 block |
| ls_theFinalCompletion | `Block ` | `view.ls_theFinalCompletion(block)` | 设置当前 view 所有动画链执行完毕之后的 block |

#### Delay

| 属性名称 | 参数 | 用法 | 描述 |
| --- | :---: | --- | --- |
| ls_delay | `NSTimeInterval` | `view.ls_delay(time)` | 设置当前节点的动画 delay |
| ls_wait | `NSTimeInterval` | `view.ls_wait(time)` | 同上，只是书写方便 |

#### Animator Controls

| 属性名称 | 参数 | 用法 | 描述 |
| --- | :---: | --- | --- |
| ls_repeat | `NSTimeInterval, NSInteger` | `view.ls_repeat(time, count)` | 设置当前节点的动画时间与重复次数并添加新节点 |
| ls_thenAfter | `NSTimeInterval` | `view.ls_thenAfter(time)` | 设置当前节点的动画时间并添加新节点 |
| ls_animate | `NSTimeInterval` | `view.ls_animate(time)` | 设置当前节点动画时间并开始执行此动画链 |
| ls_animateWithRepeat | `NSTimeInterval, NSInteger` | `view. ls_animateWithRepeat(time, count)` | 设置当前节点的动画时间与重复次数并开始执行此动画链 |
| ls_animateWithCompletion | `NSTimeInterval, Block` | `view.ls_animateWithCompletion(time, block)` | 设置当前动画节点的动画时间并开始执行此动画链 动画链结束后执行block |

# 系统要求

目前支持 iOS 7.0 之后（含 7.0）。

# 许可证

LSAnimator 使用 MIT 许可证，详情见 LICENSE 文件。