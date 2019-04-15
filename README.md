# SCShare       

第三方原生分享登录封装   

**注意点：**
新浪和朋友圈 分享 只取 title

QQ空间分享url，无图bug（系统繁忙，请重试）

通过.pch import uikit框架

**第三方集成**

1.将文件夹拖入工程

2.添加库

sina

```
QuartzCore.framework 
ImageIO.framework 
SystemConfiguration.framework  
Security.framework 
CoreTelephony.framework 
CoreText.framework  
UIKit.framework 
Foundation.framework 
CoreGraphics.framework  
libz.dylib  
libsqlite3.dylib
```

qq

```
libiconv.dylib
SystemConfiguration.framework
CoreGraphics.Framework
libsqlite3.dylib
CoreTelephony.framework
Security.framework 
```

微信

```
SystemConfiguration.framework
libz.dylib
libsqlite3.0.dylib
libc++.dylib
Security.framework 
```

3.设置工程回调URL Scheme

```
修改info.plist 文件URL types为自己的sso回调地址
com.weibo    wb拼接appKey
tencent	  tencent拼接appId	
weixin             appId
```

4.Target->Buid Settings->Linking   Other Linker Flags  添加  -ObjC 和 -fobjc-arc

5.注意配置应用白名单

6.在OpenApiConstant.h文件中配置第三方信息

7.AppDelegate中添加以下代码 

```objective-c
 import "SCOpenApiManager.h"
 /**
 这里处理第三方授权，分享之后跳转回来
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
  return [SCOpenApiManager handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
  return [SCOpenApiManager handleOpenURL:url];
}
```

8.分享示例

```objective-c
SCOpenApiShareView.h
//App分享信息设置
[SCShareMessage setAppMessage];
//媒体分享信息设置
NSString *vedioUrl = @"http://zbj.cnebtv.com/static_data/uploaddata/media/20501_55f8d3eb3a438.mp4";
[SCShareMessage setMediaMessageWithTitle:@"测试视频连接" content:@"正在测试视频连接" image:AppIconSquare mediaUrlStr:vedioUrl];
//普通分享信息设置
[SCShareMessage setMessageWithTitle:@"测试一般连接" content:@"正在测试一般连接" image:AppIconSquare urlStr:vedioUrl];
[SCOpenApiShareView showInView:self.view delegate:nil];
```

