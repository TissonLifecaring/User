//
//  VendorMacro.h
//  SugarNursing
//
//  Created by Dan on 14-12-18.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#ifndef SugarNursing_VendorMacro_h
#define SugarNursing_VendorMacro_h

#define UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define UM_REDIRECT_URL @"http://user.lifecaring.cn/web/download.jsp"
#define GCSHARE_BASE_URL @"http://user.lifecaring.cn/web/user/"
#define GCSHARE_TEST_URL @"http://172.16.24.72:8083/web2/user/"


#define IM_EXPERT_KEY @"23202119"
#define IM_USER_KEY @"23201935"


#define UM_ANALYTICS_KEY @"54d48d0cfd98c516f500085b"
#define UM_MESSAGE_APPKEY @"54d48d0cfd98c516f500085b"
#define DEVICE_IPHONE @"iOS"

#endif
