# RunTrace
一个可以实时跟踪分析iOS App视图的小工具
##前言
作为ios的开发者，常常为了UI界面搞得头破血流，你是不是经常遇到这样的痛点：这个view的从哪里来的，它的父视图是什么，它的子视图有哪些，它的frame会发生什么样的变化，它怎么突然隐藏了，它什么时候会被释放掉，对于像自动布局，错误常常如潮水般的涌来，我想动态获取一个view的约束怎么办，我想知道这个view此时此刻和其他哪些view产生的约束，如何才能直观的表现出这个view的约束呢等等各种各样的问题，为了几个view的正常显示常常加班加点，痛苦不堪。同是身为ios开发者的我，深有同感。所以，我编写了此款小工具，作为app内嵌使用，完全解耦，方便无副作用，希望大家喜欢。

##安装
安装十分简单，将RunTrace目录下的RunTrace.h,RunTraceHelp.xib,libRunTraceLib.a三个文件移动到你的工程下，或者直接将文件夹拷贝过去即可，如果工程的Build Setting的Other Linker Flags没有添加-ObjC，则添加上。至此无需写一行代码，运行你的app，在界面的右上角，一个可爱的写着T的浅绿色圆形按钮便出现。

##禁用
因为这个工具是给开发者调试用的，所以正式发布的时候肯定是需要禁用的，禁用不需要移除文件，在RunTrace.h里将RunTraceOpen宏的值改为0即可。

##使用
###获取view的基本信息
将圆形按钮拖到你想获取信息的view上即可

![](https://github.com/sx1989827/RunTrace/raw/master/Resource/1.gif)

###获取view的父视图和子视图

将圆形按钮拖到你想获取信息的view上，点击顶部的信息窗口

![](https://github.com/sx1989827/RunTrace/raw/master/Resource/2.gif)
