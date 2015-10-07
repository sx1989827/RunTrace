# RunTrace
一个可以实时跟踪分析iOS App视图的小工具（已开源）
##前言
作为ios的开发者，常常为了UI界面搞得头破血流，你是不是经常遇到这样的痛点：这个view是从哪里来的，它的父视图是什么，它的子视图有哪些，它的frame会发生什么样的变化，它怎么突然隐藏了，它什么时候会被释放掉，对于像自动布局，错误常常如潮水般的涌来，我想动态获取一个view的约束怎么办，我想知道这个view此时此刻和其他哪些view产生了怎样的约束，如何才能直观的表现出这个view的约束呢等等各种各样的问题，为了几个view的正常显示常常加班加点，痛苦不堪。同是身为ios开发者的我，深有同感。所以，我编写了此款小工具，作为app内嵌使用，完全解耦，安全方便无副作用，希望大家喜欢。

##更新
已更新至1.1，弹出窗口完全重写，交互性更好，操作比之前更简单，同时增加了view  stack和hit功能，提升了用户体验，修复了少量bug，保证了稳定性。

##安装
1.将RunTrace目录下的RunTrace.h,RunTraceHelp.xib,libRunTraceLib.a三个文件移动到你的工程下，或者直接将文件夹拷贝过去即可。至此无需写一行代码，运行你的app，在界面的右上角，一个可爱的写着T的浅绿色圆形小按钮便出现。

2.如果你使用了cocoapods，那么在podfile里加上pod "RunTrace"即可。

##禁用
因为这个工具是给开发者调试用的，所以正式发布的时候肯定是需要禁用的，禁用不需要移除文件，在RunTrace.h里将RunTraceOpen宏的值改为0即可。

##使用
###获取view的基本信息
将圆形按钮拖到你想获取信息的view上即可,它可以获取你想要的任何view，无论是tabitem上的，还是navigationitem上，甚至uiwindow上的，你都可以获取到。点击顶部的信息栏，便会弹出一个窗口，在General列表里会列出view的基本信息。

![](https://github.com/sx1989827/RunTrace/raw/master/Resource/1.gif)

###获取view的父视图和子视图

想看看这个view的父视图或者子视图有哪些，将圆形按钮拖到你想获取信息的view上，点击顶部的信息栏，便会弹出一个窗口，在SuperViews和SubViews列表里列举出了这个view的父视图（按照以此往上的顺序）和子视图（按照由内向外的顺序），点击便会列举出该视图的信息，右上角有一个back按钮，点击便可以一层层的回到原先的视图。当你不知道当前获取的是哪一个view的信息时，hit按钮可以快速的帮你定位到当前正在查看的是哪一个view。

![](https://github.com/sx1989827/RunTrace/raw/master/Resource/2.gif)

###显示自动布局信息

获取你想要的view，在弹出窗口里，在Constrains列表显示view的自动布局约束，点击列表，相应的约束在页面上高亮显示。

![](https://github.com/sx1989827/RunTrace/raw/master/Resource/3.gif)

###追踪view的状态

很多时候，我们实时跟踪一个view的状态和属性，比如它的frame的变化，它的center的变化，它的superview的改变，它的subview的改变，它的contentSize的改变等等变化，现在一个按钮即可实现你想要的。点击弹出窗口上的Trace列表里的Start按钮，即可追踪该view的状态，view的更新信息全部都在列表里，当你点击stop的时候，便会停止追踪。

![](https://github.com/sx1989827/RunTrace/raw/master/Resource/4.gif)

###监测内存泄露

没有听错吧，它可以监测内存泄露，是的，那么如何来做呢，你push进一个viewController的时候，随便获取一个view的信息，然后pop回来，如果内存正常会弹出RemoveFromSuperview的提示框，如果没有弹出，说明那个viewController发生了内存泄露。

![](https://github.com/sx1989827/RunTrace/raw/master/Resource/5.gif)

##原理
说完了大致运用，我们来简单说说原理，原理就是首先Method Swizzling修改很多方法的入口，加入我们想要的东西，比如那个圆形小按钮，然后通过view的hittest来获取我们想要的view，对view的相关属性kvo便可以跟踪它的一些状态啦。其实原理并不难，但是细节很麻烦，尤其是在写自动布局约束展现的时候需要判断的东西很多。另外大家在使用的时候可以放心，对于app原生界面上的view我都使用了weak引用，不会影响到你的代码。

##后记
支付宝账号：395414574@qq.com 你的支持，是我日以继夜完善这个工具的很大动力，如果您的条件允许，同时觉得这个工具有帮助到你，可以小小赞助下，不在多，重在心意。

QQ群：1群：460483960（目前已满） 2群：239309957 这是我们的ios项目的开发者qq群，这是一个纯粹的ios开发者社区，里面汇聚了众多有经验的ios开发者，没有hr和打扰和广告的骚扰，为您创造一个纯净的技术交流环境，如果您对我的项目以及对ios开发有任何疑问，都可以加群交流，欢迎您的加入~

微信公众号：fuckingxcode  欢迎大家关注，我们群的活动投票和文章等都会在公众号里，群期刊目前也移到公众号里。


