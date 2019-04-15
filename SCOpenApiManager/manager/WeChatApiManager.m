//
//  WeChatApiManager.m
//  CaiJie
//
//  Created by SuoChenhe on 15/12/22.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import "WeChatApiManager.h"
#import "OpenApiConstant.h"
#import "SCShareMessage.h"

@interface WeChatApiManager ()

@end
@implementation WeChatApiManager
+ (instancetype)sharedManager{
    static WeChatApiManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
        instance.userInfo = [SCUserModel loadFromPath:SCWeChatUserInfoArchive];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - 分享

+ (void)shareWithScenes:(enum WXScene)scene{
    if ([SCShareMessage sharedMessage].shareType == SCShareMessageTypeMessage) {
        [self shareMessageWithScenes:scene];
    }else{
        [self shareAppWithScenes:scene];
    }

}

+ (void)shareMessageWithScenes:(enum WXScene)scene{
    SCShareMessage *sharedMessage = [SCShareMessage sharedMessage];
    BOOL bText = YES;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = sharedMessage.title;
    message.description = sharedMessage.content;
    message.thumbData = sharedMessage.thumbnailData;
    
    if ([sharedMessage.urlStr isNotEmpty]) {
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = sharedMessage.urlStr;
        message.mediaObject = ext;
        bText = NO;
    }else if ([sharedMessage.mediaUrlStr isNotEmpty]){
        WXVideoObject *ext = [WXVideoObject object];
        ext.videoUrl = sharedMessage.mediaUrlStr;
        message.mediaObject = ext;
        bText = NO;
    }
    
    SendMessageToWXReq *req = [SendMessageToWXReq new];
    req.bText = bText;
    req.scene = scene;
    if (bText)
        req.text = sharedMessage.title;
    else
        req.message = message;

    [WXApi sendReq:req];
}

+ (void)shareAppWithScenes:(enum WXScene)scene{
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = AppShareTitle;
    message.description = AppDescription;
    UIImage *appIcon = (scene == WXSceneTimeline)? AppIconSquare : AppIcon;
    message.thumbData = UIImagePNGRepresentation(appIcon);
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = AppUrl;
    message.mediaObject = ext;
    
    SendMessageToWXReq *req = [SendMessageToWXReq new];
    req.bText = NO;
    req.scene = scene;
    req.message = message;
    
    [WXApi sendReq:req];
}


#pragma mark - WXApiDelegate

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        SendMessageToWXResp *messageResp = (SendMessageToWXResp *)resp;
        BOOL successs = (messageResp.errCode == 0);
        if ([_delegate respondsToSelector:@selector(managerDidSendMessageSuccess:errorMsg:)]) {
            [_delegate managerDidSendMessageSuccess:successs errorMsg:messageResp.errStr];
        }
    } else if ([resp isKindOfClass:[SendAuthResp class]]) {

        SendAuthResp *authResp = (SendAuthResp *)resp;
        BOOL successs = (authResp.errCode == 0);
        if (!successs) {
            if ([_delegate respondsToSelector:@selector(managerDidLoginSuccess:platform:errorMsg:)]) {
                [_delegate managerDidLoginSuccess:successs platform:SCOpenPlatformTypeWeChat errorMsg:authResp.errStr];
            }
        }else{
            _userInfo.code = authResp.code;
            [self getAccess_tokenWithCode:authResp.code];
        }
    }
}

- (void)onReq:(BaseReq *)req {
   
}


#pragma mark - 登录

+ (void)loginWithViewController:(UIViewController *)viewController{
    SendAuthReq* req = [SendAuthReq new];
    req.scope = wechatAuthScope; // @"post_timeline,sns"
    req.state = wechatAuthState;
    req.openID = [WeChatApiManager sharedManager].userInfo.openId;
    
    [WXApi sendAuthReq:req viewController:viewController delegate:[self sharedManager]];
}

-(void)getAccess_tokenWithCode:(NSString *)code
{
    //https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WeChatAppID,WeChatAppSecret,code];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 "access_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWiusJMZwzQU8kXcnT1hNs_ykAFDfDEuNp6waj-bDdepEzooL_k1vb7EQzhP8plTbD0AgR8zCRi1It3eNS7yRyd5A";
                 "expires_in" = 7200;
                 openid = oyAaTjsDx7pl4Q42O3sDzDtA7gZs;
                 "refresh_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWi2ZzH_XfVVxZbmha9oSFnKAhFsS0iyARkXCa7zPu4MqVRdwyb8J16V8cWw7oNIff0l-5F-4-GJwD8MopmjHXKiA";
                 scope = "snsapi_userinfo,snsapi_base";
                 }
                 */
                /*
                 {
                 "errcode":40030,"errmsg":"invalid refresh_token"
                 }
                 */
                SCUserModel *userInfo = self.userInfo;
                
                NSString *errcode = [dic[@"errcode"] stringValue];
                NSString *errmsg = dic[@"errmsg"];
                BOOL success = ![errcode isNotEmpty];
                
                if (success){
                    userInfo.openId = [dic objectForKey:@"openid"];
                    userInfo.accessToken = [dic objectForKey:@"access_token"];
                    userInfo.refreshToken = [dic objectForKey:@"refresh_token"];
                    userInfo.scope = [dic objectForKey:@"scope"];
                    userInfo.expiresIn = [dic objectForKey:@"expires_in"];
                    userInfo.expirationDate = [NSDate dateWithTimeIntervalSinceNow:userInfo.expiresIn.longLongValue];
                    
                    [userInfo saveToPath:SCWeChatUserInfoArchive];
                    
                    [self getUserInfoWithAccessToken:userInfo.accessToken openId:userInfo.openId];
                }
                
                if ([_delegate respondsToSelector:@selector(managerDidLoginSuccess:platform:errorMsg:)]) {
                    [_delegate managerDidLoginSuccess:success platform:SCOpenPlatformTypeWeChat errorMsg:errmsg];
                }
                
            }else{
                if ([_delegate respondsToSelector:@selector(managerDidLoginSuccess:platform:errorMsg:)]) {
                    [_delegate managerDidLoginSuccess:NO platform:SCOpenPlatformTypeWeChat errorMsg:@"登录失败"];
                }            }
        });
    });
}

-(void)getUserInfoWithAccessToken:(NSString *)accessToken openId:(NSString *)openId{
    // https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",accessToken,openId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 city = Haidian;
                 country = CN;
                 headimgurl = "http://wx.qlogo.cn/mmopen/FrdAUicrPIibcpGzxuD0kjfnvc2klwzQ62a1brlWq1sjNfWREia6W8Cf8kNCbErowsSUcGSIltXTqrhQgPEibYakpl5EokGMibMPU/0";
                 language = "zh_CN";
                 nickname = "xxx";
                 openid = oyAaTjsDx7pl4xxxxxxx;
                 privilege =     (
                 );
                 province = Beijing;
                 sex = 1;
                 unionid = oyAaTjsxxxxxxQ42O3xxxxxxs;
                 }
                 */
                SCUserModel *userInfo = self.userInfo;
                
                NSString *errcode = dic[@"errcode"];
                NSString *errmsg = dic[@"errmsg"];
                BOOL success = ![errcode isNotEmpty];
                
                if (success){
                    userInfo.nickName = [dic objectForKey:@"nickname"];
                    userInfo.headerUrl = [dic objectForKey:@"headimgurl"];
                    userInfo.unionId = [dic objectForKey:@"unionid"];
                    
                    [userInfo saveToPath:SCWeChatUserInfoArchive];
                }
                if ([_delegate respondsToSelector:@selector(managerDidGetUserInoSuccess:platform:errorMsg:)]) {
                    [_delegate managerDidGetUserInoSuccess:success platform:SCOpenPlatformTypeWeChat errorMsg:errmsg];
                }
            }else{
                if ([_delegate respondsToSelector:@selector(managerDidGetUserInoSuccess:platform:errorMsg:)]) {
                    [_delegate managerDidGetUserInoSuccess:NO platform:SCOpenPlatformTypeWeChat errorMsg:@"获取用户信息失败"];
                }
            }
        });
        
    });
}

+ (void)updateAccessToken{
    //https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=APPID&grant_type=refresh_token&refresh_token=REFRESH_TOKEN
    WeChatApiManager *manager = [WeChatApiManager sharedManager];
    SCUserModel *userInfo = manager.userInfo;
    if ([userInfo.refreshToken isNotEmpty]) {
        NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@",WeChatAppID,userInfo.refreshToken];
        NSURL *url = [NSURL URLWithString:urlStr];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *zoneStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
            NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (data) {
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    
                    NSString *errcode = dic[@"errcode"];
                    NSString *errmsg = dic[@"errmsg"];
                    BOOL success = ![errcode isNotEmpty];
                    
                    if (success){
                        userInfo.openId = [dic objectForKey:@"openid"];
                        userInfo.accessToken = [dic objectForKey:@"access_token"];
                        userInfo.refreshToken = [dic objectForKey:@"refresh_token"];
                        userInfo.scope = [dic objectForKey:@"scope"];
                        userInfo.expiresIn = [dic objectForKey:@"expires_in"];
                    }
                    
                    if ([manager.delegate respondsToSelector:@selector(managerDidLoginSuccess:platform:errorMsg:)]) {
                        [manager.delegate managerDidLoginSuccess:success platform:SCOpenPlatformTypeWeChat errorMsg:errmsg];
                    }
                }
            });
                
        });
    }
}

+ (void)logout{
    SCUserModel *userInfo = [WeChatApiManager sharedManager].userInfo;
    [userInfo clearInfo];
    [userInfo saveToPath:SCWeChatUserInfoArchive];
    if ([[WeChatApiManager sharedManager].delegate respondsToSelector:@selector(managerDidLogoutSuccess:platform:errorMsg:)]) {
        [[WeChatApiManager sharedManager].delegate managerDidLogoutSuccess:YES platform:SCOpenPlatformTypeWeChat errorMsg:@"退出登录"];
    }
}

@end
