//
//  QQApiManager.m
//  CaiJie
//
//  Created by SuoChenhe on 15/12/22.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import "QQApiManager.h"
#import "OpenApiConstant.h"
#import "SCShareMessage.h"
@interface QQApiManager ()

@end

@implementation QQApiManager
+ (instancetype)sharedManager{
    static QQApiManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _userInfo = [SCUserModel loadFromPath:SCQQUserInfoArchive];
        
        _tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAppID andDelegate:self];
        [_tencentOAuth setAccessToken:_userInfo.accessToken] ;
        [_tencentOAuth setOpenId:_userInfo.openId] ;
        [_tencentOAuth setExpirationDate:_userInfo.expirationDate] ;
    }
    return self;
}
+ (void)shareToQZone:(BOOL)toQzone{
    if ([SCShareMessage sharedMessage].shareType == SCShareMessageTypeMessage) {
        [self shareMessageToQZone:toQzone];
    }else{
        [self shareAppToQZone:toQzone];
    }
}

#pragma mark - 分享
/**
 *  分享消息
 *
 *  @param toQzone Yes分享到qzone  NO 分享到QQ
 */
+ (void)shareMessageToQZone:(BOOL)toQzone{
    SCShareMessage *sharedMessage = [SCShareMessage sharedMessage];
    
    QQApiObject *shareContent = nil;
    if ([sharedMessage.urlStr isNotEmpty]) {
         shareContent = [QQApiNewsObject objectWithURL:[NSURL URLWithString:sharedMessage.urlStr] title:sharedMessage.title description:sharedMessage.content previewImageData:sharedMessage.thumbnailData];
    }else if ([sharedMessage.mediaUrlStr isNotEmpty]){
        QQApiVideoObject *vedioObj = [QQApiVideoObject objectWithURL:[NSURL URLWithString:sharedMessage.mediaUrlStr] title:sharedMessage.title description:sharedMessage.content previewImageData:sharedMessage.thumbnailData];
        vedioObj.flashURL = [NSURL URLWithString:sharedMessage.mediaUrlStr];
        shareContent = vedioObj;
    }else if([sharedMessage.title isNotEmpty]){
         shareContent = [QQApiTextObject objectWithText:sharedMessage.title];
    }
    if (toQzone) {
        shareContent.cflag = kQQAPICtrlFlagQZoneShareOnStart;
    }
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:shareContent];
    [QQApiInterface sendReq:req];
    
}

+ (void)shareAppToQZone:(BOOL)toQzone{
    
    QQApiObject *shareContent = [QQApiNewsObject objectWithURL:[NSURL URLWithString:AppUrl] title:AppShareTitle description:AppDescription previewImageData:UIImagePNGRepresentation(AppIcon)];

    if (toQzone) {
        shareContent.cflag = kQQAPICtrlFlagQZoneShareOnStart;
    }
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:shareContent];
    [QQApiInterface sendReq:req];

//    BOOL success = (result == EQQAPISENDSUCESS);
//    if ([[QQApiManager sharedManager].delegate respondsToSelector:@selector(managerDidSendMessageSuccess:errorMsg:)]) {
//        [[QQApiManager sharedManager].delegate managerDidSendMessageSuccess:success errorMsg:[self errorMsgSendResultCode:result]];
//    }
}

#pragma mark  QQApiInterfaceDelegate
- (void)onReq:(QQBaseReq *)req
{
    switch (req.type)
    {
        case EGETMESSAGEFROMQQREQTYPE:
        {
            break;
        }
        default:
        {
            break;
        }
    }
}


// 0 成功
//-1 参数错误
//-2 该群不在自己的群列表里面
//-3 上传图片失败
//-4 用户放弃当前操作
//-5 客户端内部处理错误
- (void)onResp:(QQBaseResp *)resp{
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        SendMessageToQQResp *sendMessageToQQResp = (SendMessageToQQResp *)resp;
        NSLog(@"result :%@",sendMessageToQQResp.result);
        NSLog(@"errorDescription :%@",sendMessageToQQResp.errorDescription);
        NSLog(@"type :%d",sendMessageToQQResp.type);
        NSLog(@"extendInfo :%@",sendMessageToQQResp.extendInfo);
        BOOL success = (resp.result.integerValue == 0);
        if ([[QQApiManager sharedManager].delegate respondsToSelector:@selector(managerDidSendMessageSuccess:errorMsg:)]) {
            [[QQApiManager sharedManager].delegate managerDidSendMessageSuccess:success errorMsg:nil];
        }
    }

}

#pragma mark - 登录

+ (void)login{
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,

                            kOPEN_PERMISSION_ADD_SHARE,

                            kOPEN_PERMISSION_CHECK_PAGE_FANS,
                            kOPEN_PERMISSION_GET_INFO,
                            kOPEN_PERMISSION_GET_OTHER_INFO,


                            kOPEN_PERMISSION_GET_VIP_INFO,
                            kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                            nil];
    [[QQApiManager sharedManager].tencentOAuth authorize:permissions inSafari:NO];
}

+ (void)logout{
    [[QQApiManager sharedManager].tencentOAuth logout:[QQApiManager sharedManager]];
}

+ (BOOL)isQQAuthorize{
    return [[QQApiManager sharedManager].tencentOAuth isSessionValid];
}


#pragma mark  TencentLoginDelegate

- (void)tencentDidLogin{
    _userInfo.accessToken = _tencentOAuth.accessToken;
    _userInfo.openId = _tencentOAuth.openId;
    _userInfo.expirationDate = _tencentOAuth.expirationDate;
    
    [_userInfo saveToPath:SCQQUserInfoArchive];
    
    if ([_delegate respondsToSelector:@selector(managerDidLoginSuccess:platform:errorMsg:)]) {
        [_delegate managerDidLoginSuccess:YES platform:SCOpenPlatformTypeQQ errorMsg:nil];
    }
    BOOL success = [_tencentOAuth getUserInfo];
    NSLog(@"获取qq信息 success：%@",@(success));
    
}

//非网络错误导致登录失败：
- (void)tencentDidNotLogin:(BOOL)cancelled{
    
    if (cancelled){
        //@"用户取消登录";
    }else{
        if ([_delegate respondsToSelector:@selector(managerDidLoginSuccess:platform:errorMsg:)]) {
            [_delegate managerDidLoginSuccess:NO platform:SCOpenPlatformTypeQQ errorMsg:@"登录失败"];
        }
    }

}

//网络错误导致登录失败：
- (void)tencentDidNotNetWork{

}

#pragma mark  TencentSessionDelegate

- (void)tencentDidLogout{
    [_userInfo clearInfo];
    [_userInfo saveToPath:SCQQUserInfoArchive];
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAppID andDelegate:self];
    if ([_delegate respondsToSelector:@selector(managerDidLogoutSuccess:platform:errorMsg:)]) {
        [_delegate managerDidLogoutSuccess:YES platform:SCOpenPlatformTypeQQ errorMsg:@"退出登录"];
    }
}
- (void)getUserInfoResponse:(APIResponse*) response{
    NSDictionary *dic = response.jsonResponse;
    _userInfo.nickName = dic[@"nickname"];
    _userInfo.headerUrl = dic[@"figureurl_qq_2"];
    
    [_userInfo saveToPath:SCQQUserInfoArchive];
    
    BOOL success = (response.detailRetCode == kOpenSDKErrorSuccess);
    if ([_delegate respondsToSelector:@selector(managerDidGetUserInoSuccess:platform:errorMsg:)]) {
        [_delegate managerDidGetUserInoSuccess:success platform:SCOpenPlatformTypeQQ errorMsg:response.errorMsg];
    }
}

- (void)tencentDidUpdate:(TencentOAuth *)tencentOAuth{
    _userInfo.accessToken = _tencentOAuth.accessToken;
    _userInfo.openId = _tencentOAuth.openId;
}

//增量授权
- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentOAuth withPermissions:(NSArray *)permissions{
    [tencentOAuth incrAuthWithPermissions:permissions];
    return YES;
}

- (void)addShareResponse:(APIResponse*) response{

}

- (void)responseDidReceived:(APIResponse*)response forMessage:(NSString *)message
{
    
}

- (void)tencentFailedUpdate:(UpdateFailType)reason{
    
    switch (reason) {
        case kUpdateFailNetwork:
            //@"增量授权失败，无网络连接，请设置网络";
            break;
        case kUpdateFailUserCancel:
            //@"增量授权失败，用户取消授权";
            break;
        case kUpdateFailUnknown:
        default:
            //@"增量授权失败，未知错误";
            break;
    }
    
}

+ (NSString *)errorMsgSendResultCode:(QQApiSendResultCode)sendResultCode{
    NSString *errorMsg = nil;
    switch (sendResultCode)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            errorMsg = @"App未注册";
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            errorMsg = @"发送参数错误";
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            errorMsg = @"未安装手Q";
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            errorMsg = @"API接口不支持";
            break;
        }
        case EQQAPISENDFAILD:
        {
            errorMsg = @"发送失败";
            break;
        }
        default:
        {
            break;
        }
    }
    return errorMsg;
}




@end
