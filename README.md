# MyLocations
> **平台:** iOS 10, Xcode 8.0(beta 5)
>
> **语言:** Swift 3.0(beta 5)

![DemoPreview](MyLocation.gif)

跟着 Apprentice 3做出来的 app, 顺手更到了 Swift 3.0, 主要是 Core Data 里面的 FetchRequest 等若干类增加了泛型约束, 初始化的时候需要声明具体类型, 类型变得更加安全, 取数据的时候不需要做类型转换

数据持久化里面我自己多封装了一个 coreDataStack 去简化取数据的 api

原版用的 hud 是自己封装的, 文字跟图案都是通过代码绘制出来, 不是用 label 和 imageview, 性能相对比较好, 我用 Protocol Extension 加多了一层, ViewController直接遵守协议就可以调方法去展示 hud, 相对来说更加方便
