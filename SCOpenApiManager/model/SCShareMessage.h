//
//  SCShareMessage.h
//  CaiJie
//
//  Created by SuoChenhe on 15/12/22.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SCShareMessageType) {
    SCShareMessageTypeMessage = 1,//消息分享
    SCShareMessageTypeApp,//应用分享
};
@interface SCShareMessage : NSObject

@property(nonatomic,assign,readonly)SCShareMessageType shareType;

//shareType == SCShareMessageTypeApp 以下属性不需设置
@property(nonatomic,copy,readonly)NSString *title;
@property(nonatomic,copy,readonly)NSString *content;
@property(nonatomic,copy,readonly)NSData *thumbnailData;
@property(nonatomic,copy,readonly)NSString *urlStr;
@property(nonatomic,copy,readonly)NSString *mediaUrlStr;

+ (instancetype)sharedMessage;


//设置消息信息，调用以下方法
+ (void)setAppMessage;
//设置一般消息
+ (void)setMessageWithTitle:(NSString *)title content:(NSString *)content image:(UIImage *)image urlStr:(NSString *)urlStr;
//设置媒体消息（视频）
+ (void)setMediaMessageWithTitle:(NSString *)title content:(NSString *)content image:(UIImage *)image mediaUrlStr:(NSString *)mediaUrlStr;
@end
