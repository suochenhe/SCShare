//
//  OpenApiConstant.h
//  CaiJie
//
//  Created by SuoChenhe on 15/12/22.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#ifndef OpenApiConstant_h
#define OpenApiConstant_h

/**---------------------------------------- sina qq wecaht Config----------------------------------------*/

#define SinaAppKey @"3563172917"
#define SinaRedirectURI @"https://api.weibo.com/oauth2/default.html" // @"http://www.sina.com"   //

#define WeChatAppID @"wx62e583ae182a3f54"
#define WeChatAppSecret @"f45bc62ae1e0b30214e6677917da8c64"

#define QQAppID @"1105121134"

#define SinaSourceApplication @"com.sina.weibo"
#define WeChatSourceApplication @"com.tencent.xin"
#define QQSourceApplication @"com.tencent.mqq"

/**---------------------------------------- sina ----------------------------------------*/
#define SinaLogoutRequestTag @"sinaSsoOutAuthorize"

/**---------------------------------------- wechat --------------------------------------*/

#define wechatAuthScope  @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact"
#define wechatAuthState  @"wechatAuth"


//OpenApiUserInfo载存储目录
#define SCOpenApiDataDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"SCOpenApiUserData"]


#define SCSinaUserInfoArchive [SCOpenApiDataDirectory stringByAppendingPathComponent:@"SCSinaUserInfo.data"]

#define SCWeChatUserInfoArchive [SCOpenApiDataDirectory stringByAppendingPathComponent:@"SCWeChatUserInfo.data"]

#define SCQQUserInfoArchive [SCOpenApiDataDirectory stringByAppendingPathComponent:@"SCQQUserInfo.data"]

/**---------------------------------------- AppData----------------------------------------*/
#define AppShareTitle @"财界新闻"
#define AppDescription @"我正在用财界新闻看财经资讯，非常不错！推荐您使用。免费下载：http://www.17ok.com/app/share"
#define AppIcon [UIImage imageNamed:@"appIcon"]
//appIcon_square
#define AppIconSquare [UIImage imageNamed:@"appIcon"]
#define AppUrl @"http://www.17ok.com/app/share"

#endif /* OpenApiConstant_h */
