//
//  SinaApiManager.m
//  CaiJie
//
//  Created by SuoChenhe on 15/12/22.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import "SinaApiManager.h"
#import "OpenApiConstant.h"
#import "SCShareMessage.h"
#import "WeiboUser.h"

@interface SinaApiManager ()

@end
@implementation SinaApiManager

+ (instancetype)sharedManager{
    static SinaApiManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
        instance.userInfo = [SCUserModel loadFromPath:SCSinaUserInfoArchive];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - 登录
+ (BOOL)isSinaAuthorize{
    SCUserModel *userInfo = [SinaApiManager sharedManager].userInfo;
    return [userInfo.accessToken isNotEmpty];
}
+ (void)login{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = SinaRedirectURI;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
}

+ (void)logout{
    SCUserModel *userInfo = [SinaApiManager sharedManager].userInfo;
    [WeiboSDK logOutWithToken:userInfo.accessToken delegate:[SinaApiManager sharedManager] withTag:SinaLogoutRequestTag];
}

#pragma mark - 分享
+ (void)sinaShare{
    if ([SCShareMessage sharedMessage].shareType == SCShareMessageTypeApp) {
        [self sinaShareAPP];
    }else{
        [self sinaShareMessage];
    }
}

+ (void)sinaShareAPP{
    [self sinaShareWithMessage:[self appMessageToShare]];
}

+ (void)sinaShareMessage{
    [self sinaShareWithMessage:[self sinaMessageToShare]];
}

+ (void)sinaShareWithMessage:(WBMessageObject *)message{
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = SinaRedirectURI;
    authRequest.scope = @"all";
    WBSendMessageToWeiboRequest *request;
    request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:[SinaApiManager sharedManager].userInfo.accessToken];
    
    //    request = [WBSendMessageToWeiboRequest requestWithMessage:[self messageToShare]];
    //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    [WeiboSDK sendRequest:request];
}

+ (WBMessageObject *)sinaMessageToShare{
    SCShareMessage *sharedMessage = [SCShareMessage sharedMessage];
    WBMessageObject *message = [WBMessageObject message];
    
    if ([sharedMessage.title isNotEmpty]){
        NSString *shareText = sharedMessage.title;
        if (![WeiboSDK isWeiboAppInstalled]) {
            if ([sharedMessage.urlStr isNotEmpty]) {
                shareText = [NSString stringWithFormat:@"%@ %@",shareText,sharedMessage.urlStr];
            }else if ([sharedMessage.mediaUrlStr isNotEmpty]){
                shareText = [NSString stringWithFormat:@"%@ %@",shareText,sharedMessage.mediaUrlStr];
            }
        }
        message.text = shareText;
    }
    
    if ([sharedMessage.urlStr isNotEmpty]){
        WBWebpageObject *webpage = [WBWebpageObject object];
        webpage.objectID = @"sinaShareIdentifier";
        webpage.title = sharedMessage.title;
        webpage.thumbnailData = sharedMessage.thumbnailData;
        webpage.webpageUrl = sharedMessage.urlStr;
        message.mediaObject = webpage;
    }else if([sharedMessage.mediaUrlStr isNotEmpty]){
        WBVideoObject *vedioObj = [WBVideoObject object];
        vedioObj.objectID = @"sinaShareIdentifier";
        vedioObj.title = sharedMessage.title;
        vedioObj.thumbnailData = sharedMessage.thumbnailData;
        vedioObj.videoUrl = sharedMessage.mediaUrlStr;
        message.mediaObject = vedioObj;
    }else if(sharedMessage.thumbnailData != nil){
        WBImageObject *imageObj = [WBImageObject new];
        imageObj.imageData = sharedMessage.thumbnailData;
        message.imageObject = imageObj;
    }
    
    return message;
}

+ (WBMessageObject *)appMessageToShare{
    WBMessageObject *message = [WBMessageObject message];
    NSString *shareText = AppDescription;
    if ([WeiboSDK isWeiboAppInstalled]){
        NSRange range = [shareText rangeOfString:AppUrl];
        if (range.length > 0) {
            shareText = [shareText substringToIndex:range.location];
        }
    }
    message.text = shareText;

    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = @"sinaAppShareIdentifier";
    webpage.title = AppShareTitle;
    webpage.description = AppDescription;
    webpage.thumbnailData = UIImagePNGRepresentation(AppIcon);
    webpage.webpageUrl = AppUrl;
    message.mediaObject = webpage;
    
    return message;
}

//WBWebpageObject *webpage = [WBWebpageObject object];
//webpage.objectID = @"identifier1";
//webpage.title = NSLocalizedString(@"分享网页标题", nil);
//webpage.description = [NSString stringWithFormat:NSLocalizedString(@"分享网页内容简介-%.0f", nil), [[NSDate date] timeIntervalSince1970]];
//webpage.thumbnailData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_3" ofType:@"jpg"]];
//webpage.webpageUrl = @"http://sina.cn?a=1";
////        webpage.webpageUrl = @"http://toutiao.com/a6230334703833121026/";
//message.mediaObject = webpage;

#pragma mark  WBHttpRequestDelegate
- (void)request:(WBHttpRequest *)request didFinishLoadingWithDataResult:(NSData *)data{
    if ([request.tag isEqualToString:SinaLogoutRequestTag]) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
        if ([dic[@"result"] isEqualToString:@"true"]) {
            //取消授权
            [_userInfo clearInfo];
            [_userInfo saveToPath:SCSinaUserInfoArchive];
            if ([_delegate respondsToSelector:@selector(managerDidLogoutSuccess:platform:errorMsg:)]) {
                [_delegate managerDidLogoutSuccess:YES platform:SCOpenPlatformTypeSina errorMsg:@"退出登录"];
            }
        }
        
    }
}
- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result{
    
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error;{
    
}

#pragma mark  WeiboSDKDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class]){
        NSString *title = NSLocalizedString(@"发送结果", nil);
        NSString *message = [NSString stringWithFormat:@"%@: %d\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode, NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil),response.requestUserInfo];
                WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        BOOL success = response.statusCode == WeiboSDKResponseStatusCodeSuccess;

        NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
        if (accessToken)
        {
            _userInfo.accessToken = accessToken;
        }
        NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
        if (userID) {
            _userInfo.userId = userID;
        }
        
        if ([_delegate respondsToSelector:@selector(managerDidSendMessageSuccess:errorMsg:)]) {
            [_delegate managerDidSendMessageSuccess:success errorMsg:[self errorMsgWithStateCode:response.statusCode]];
        }

    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        NSString *title = NSLocalizedString(@"认证结果", nil);
        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.userId: %@\nresponse.accessToken: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken],  NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
        
        BOOL success = response.statusCode == WeiboSDKResponseStatusCodeSuccess;
        
        if (success) {
            WBAuthorizeResponse *rep = (WBAuthorizeResponse *)response;
            _userInfo.accessToken = [rep accessToken];
            _userInfo.userId = [rep userID];
            _userInfo.refreshToken = [rep refreshToken];
            _userInfo.expirationDate = [rep expirationDate];
            
            [_userInfo saveToPath:SCSinaUserInfoArchive];
            
            [SinaApiManager getUserInfo];
        }
        
        if ([_delegate respondsToSelector:@selector(managerDidLoginSuccess:platform:errorMsg:)]) {
            [_delegate managerDidLoginSuccess:success platform:SCOpenPlatformTypeSina errorMsg:[self errorMsgWithStateCode:response.statusCode]];
        }
        

    }
}

- (NSString *)errorMsgWithStateCode:(WeiboSDKResponseStatusCode)stateCode{
    NSString *errorMsg = nil;
    switch (stateCode) {
        case WeiboSDKResponseStatusCodeAuthDeny:
            errorMsg = @"授权失败";
            break;
        case WeiboSDKResponseStatusCodeSentFail:
            errorMsg = @"发送失败";
            break;
        case WeiboSDKResponseStatusCodeShareInSDKFailed:
            errorMsg = @"分享失败";
            break;
        default:
            break;
    }
    
    
    return errorMsg;

}

//WeiboSDKResponseStatusCodeSuccess               = 0,//成功
//WeiboSDKResponseStatusCodeUserCancel            = -1,//用户取消发送
//WeiboSDKResponseStatusCodeSentFail              = -2,//发送失败
//WeiboSDKResponseStatusCodeAuthDeny              = -3,//授权失败
//WeiboSDKResponseStatusCodeUserCancelInstall     = -4,//用户取消安装微博客户端
//WeiboSDKResponseStatusCodePayFail               = -5,//支付失败
//WeiboSDKResponseStatusCodeShareInSDKFailed      = -8,//分享失败 详情见response UserInfo
//WeiboSDKResponseStatusCodeUnsupport             = -99,//不支持的请求
//WeiboSDKResponseStatusCodeUnknown               = -100,

+ (void)getUserInfo{
     SCUserModel *userInfo = [SinaApiManager sharedManager].userInfo;
    [WBHttpRequest requestForUserProfile:userInfo.userId
                                                  withAccessToken:userInfo.accessToken
                                               andOtherProperties:nil
                                                            queue:nil
                                            withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                                                BOOL success = (error == nil);
                                                if (success) {
//                                                     NSDictionary *dic = (NSDictionary *)result;
//                                                    userInfo.nickName = dic[@"screen_name"];
//                                                    userInfo.headerUrl = dic[@"profile_image_url"];
                                                    
                                                    WeiboUser *dic = (WeiboUser *)result;
                                                    userInfo.nickName = dic.screenName;
                                                    userInfo.headerUrl = dic.profileImageUrl;

                                                    [userInfo saveToPath:SCSinaUserInfoArchive];
                                                }
                                                if ([[SinaApiManager sharedManager].delegate respondsToSelector:@selector(managerDidGetUserInoSuccess:platform:errorMsg:)]) {
                                                    [[SinaApiManager sharedManager].delegate managerDidGetUserInoSuccess:success platform:SCOpenPlatformTypeSina errorMsg:error.description];
                                                }
                                               
                                            }];

}

@end

