![license](https://img.shields.io/hexpm/l/plug.svg)
![Pod Version](https://img.shields.io/badge/pod-v1.0.0-green.svg)
![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)
![Language](https://img.shields.io/badge/language-ObjectC-green.svg)

---
## Introduce

guldan is an open source time-consuming analysis tool for iOS Objective-C method. It can facilitate development/testing students to quickly obtain the cost time of all OC methods within a certain period of time when the APP is running, and supports visualization. see more: [juejin paper](https://juejin.cn/post/7134877291716280328/)
## Compare
 |scheme compare |advantage |   shortcomint
|--|:-------------------------:|:-------------------------:
| static instrumentation|The entry edge and exit edge of the function can be overwritten, and the entire execution process of the function can be covered |  Negative impact on package volume; cannot be applied to closed source libraries; high access cost
|Messier|Analysis product visualization, with time series | Relying on third-party maintenance, some iOS systems cannot be applied
| Xcode Instruments | Powerful functions and support for sub-thread analysis | High cost of use; unsustainable analysis results; does not support timing
| our scheme | Low invasiveness, high performance, low cost of use, visualization | Does not support simulators, only for OC methods time-consuming


## Features
-  Low intrusion: Hook objc_megSend is used to collect time-consuming data without intrusion to business target code；
-  High performance: The core code is implemented in assembly language, and the performance is guaranteed；
-  Visualization: Supports visualization of analysis results on desktop and mobile；
-  Support sub-threads: In addition to the method time-consuming analysis of the main thread, it also supports the method time-consuming analysis of sub-threads；

## Dependency
- Real device and some simulators

## Usage

（1) Install via CocoaPods command
```
pod 'Guldan'
```
（2) import header file
```
#import <Guldan/GDNOCMethodTimeProfiler.h>
```
（3）start analysis
```
[GDNOCMethodTimeProfiler start];
```
（4）stop analysis
```
[GDNOCMethodTimeProfiler stop];
```
（5）output result path
```
[GDNOCMethodTimeProfiler handleRecordsWithComplete:^(NSArray<NSString *> * _Nonnull filePaths) {
    // file path
}];
```
（6）output file path
It can be opened quickly with the help of some sandbox tools. The sandbox directory can also be downloaded using Xcode. Here is only how to use Xcode to find the result file in the sandbox.
Xcode window/Devices and Simulators/select target APP/Click the gear icon and select「Download Container」

<img src=Image/xcode_devices.png width=100% height=100% />
Right-click the file downloaded in the previous step, select "Show Package Contents" and find the oc_method_cost_mainthread file

<img src=Image/sandbox.png width=100% height=100% />
（7）Desktop visualization with Chrome
Enter chrome://tracing/ in the chrome browser and drag in the oc_method_cost_mainthread file。

<img src=Image/demo.png width=100% height=100% />

## Author
&emsp;&emsp; [HUOLALA mobile technology team](https://juejin.cn/user/1768489241815070)
## License
&emsp;&emsp;Guldan is released under the Apache 2.0 license. See [LICENSE](LICENSE) for details.
