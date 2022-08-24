![license](https://img.shields.io/hexpm/l/plug.svg)
![Pod Version](https://img.shields.io/badge/pod-v1.0.0-green.svg)
![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)
![Language](https://img.shields.io/badge/language-ObjectC-green.svg)

---
## 介绍

guldan是货拉拉开源的一个用于iOS Objective-C方法耗时分析的工具，能够方便开发/测试同学快速获取APP运行某段时间内所有OC方法的执行耗时，并支持可视化。详见 [掘金文章](https://juejin.cn/post/7134877291716280328/)
## 比较
 |方案对比 |优点 |   缺点
|--|:-------------------------:|:-------------------------:
| 静态插桩|可以覆盖函数的 entry edge 与 exit edge ，能够完成对函数的整个执行过程覆盖 |  对包体积有负向影响;无法应用到闭源库;接入成本高
|Messier|分析产物可视化，具有时序性 | 依赖三方维护，部分iOS系统无法应用
| Xcode Instruments | 功能强大、支持子线程分析, | 使用成本高；分析结果不可持续;不支持时序
| 本方案 | 侵入性低、性能高、使用成本低、可视化 | 不支持模拟器、仅面向OC方法耗时


## 特点
-  低侵入性：采用Hook objc_megSend方式采集耗时数据，对业务目标代码无侵入；
-  高性能：采用汇编语言实现核心代码，性能有保障；
-  可视化：支持桌面端和移动端的分析结果可视化；
-  支持子线程：除了主线程的方法耗时分析，也支持子线程的方法耗时分析；

## 依赖
- 真机设备和部分模拟器

## 使用

（1) 通过CocoaPods命令安装
```
    pod 'Guldan'
```
（2) 引入头文件
```
#import <Guldan/GDNOCMethodTimeProfiler.h>
```
（3）开始分析
```
[GDNOCMethodTimeProfiler start];
```
（4）结束分析
```
[GDNOCMethodTimeProfiler stop];
```
（5）输出结果文件路径
```
[GDNOCMethodTimeProfiler handleRecordsWithComplete:^(NSArray<NSString *> * _Nonnull filePaths) {
    // file path
}];
```
（6）输出结果文件路径
可借助一些沙盒工具快速打开。也可以使用Xcode下载沙盒目录。这里仅介绍如何使用Xcode找到沙盒中的结果文件。
Xcode window/Devices and Simulators/选中目标APP/点击齿轮图标并选择「Download Container」

<img src=Image/xcode_devices.png width=100% height=100% />
右击上一步下载的文件，选择「显示包内容」并找到oc_method_cost_mainthread文件

<img src=Image/sandbox.png width=100% height=100% />
（7）借助Chrome实现桌面端可视化
在chrome浏览器中输入chrome://tracing/，拖入oc_method_cost_mainthread文件。

<img src=Image/demo.png width=100% height=100% />

## 作者
&emsp;&emsp; [货拉拉移动端技术团队](https://juejin.cn/user/1768489241815070)
## 许可证
&emsp;&emsp;采用Apache 2.0协议，详情参考[LICENSE](LICENSE)
