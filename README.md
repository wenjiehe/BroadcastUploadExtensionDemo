# BroadcastUploadExtensionDemo
利用扩展实现录屏共享以及视频流实时直播

## 报错

1.Embedded binary's bundle identifier is not prefixed with the parent app's bundle identifier

> 查看[解决方法](https://www.jianshu.com/p/2c8f3529b092)


## API介绍

1. #import <ReplayKit/RPPreviewViewController.h>

> 实现对录制内容的展示、保存等操作

2. #import <ReplayKit/RPScreenRecorder.h>

> 可以实现应用内录屏功能，包括语音的录制

3. RPSystemBroadcastPickerView

> 主动唤起系统录制功能

4. RPBroadcastActivityViewController

> 获取可录屏直播的App列表

5. RPBroadcastController

> 当使用了RPBroadcastActivityViewController来发起广播，就可以使用它，可以用来启动、暂停和停止广播

6. RPBroadcastSampleHandler

> 使用扩展，获取录制屏幕的数据


## 参考资料

* [初识ReplayKit](https://blog.csdn.net/Morris_/article/details/91881799?utm_medium=distribute.pc_relevant.none-task-blog-baidujs_title-6&spm=1001.2101.3001.4242)
* [官方文档](https://developer.apple.com/documentation/replaykit?language=objc)
* [屏幕录制调研](https://www.jianshu.com/p/b8ce67fb08e1)
