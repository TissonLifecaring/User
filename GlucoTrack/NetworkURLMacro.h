//
//  NetworkURLMacro.h
//  SugarNursing
//
//  Created by Dan on 14-12-18.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#ifndef SugarNursing_NetworkURLMacro_h
#define SugarNursing_NetworkURLMacro_h

/*  URLSession Configuration  */

#define TIMEOUT_INTERVAL_FORREQUEST 15

static NSString * const GCHttpBaseURLString = @"http://192.168.1.4:8080/lcp-laop/";
static NSString * const GCHttpTestURLString = @"http://172.16.24.72:8083/lcp-laop/";
static NSString * const GCALIURLString = @"http://120.24.60.25:8081/lcp-laop/";
static NSString * const GCUserURLString = @"http://user.lifecaring.cn/lcp-laop/";


// URL
#define GC_LOGIN_URL @"rest/laop/linkMan/account"
#define GC_LOGOUT_URL @"rest/laop/common/account"
#define GC_USER_REGISTER_URL @"rest/laop/linkMan/account"
#define GC_GET_CODE_URL @"rest/laop/common/captcha"
#define GC_IS_REGISTER_URL @"rest/laop/common/account"
#define GC_USER_GETINFO_URL @"rest/laop/linkMan/account"
#define GC_USER_RESET_URL @"rest/laop/common/account"
#define GC_USER_REBIND_URL @"rest/laop/linkMan/account"
#define GC_USER_EDITUSERINFO_URL @"rest/laop/linkMan/account"
#define GC_USER_UPLOADFILE_URL @"rest/laop/common/upload"
#define GC_USER_GET_MEDICALRECORD_URL @"rest/laop/linkMan/mediRecord"
#define GC_USER_EDIT_MEDICALRECORD_URL @"rest/laop/linkMan/mediRecord"
#define GC_USER_GET_MEDICALIMAGES_URL @"rest/laop/linkMan/mediRecord"
#define GC_USER_DELETE_MEDICALRECORD_URL @"rest/laop/linkMan/mediRecord"
#define GC_USER_GET_DETECTIONDATA_URL @"rest/laop/linkMan/cureLog"
#define GC_USER_GET_DOCTORSUGGESTIONS_URL @"rest/laop/linkMan/suggest"
#define GC_USER_GET_MESSAGELIST_URL @"rest/laop/common/message"
#define GC_USER_SEND_MESSAGE_URL @"rest/laop/common/message"
#define GC_USER_SEND_FEEDBACK_URL @"rest/laop/common/feedBack"
#define GC_USER_GET_RECOVERYRECORD_URL @"rest/laop/linkMan/cureLog"
#define GC_USER_GET_CONTROLEFFECT_URL @"rest/laop/linkMan/cureLog"
#define GC_USER_EDIT_DETECTLOG_URL @"rest/laop/linkMan/cureLog"
#define GC_USER_EDIT_DIETLOG_URL @"rest/laop/linkMan/cureLog"
#define GC_USER_EDIT_DRUGLOG_URL @"rest/laop/linkMan/cureLog"
#define GC_USER_EDIT_EXERCISELOG_URL @"rest/laop/linkMan/cureLog"
#define GC_USER_DELETE_DETECTLOG_URL @"rest/laop/linkMan/cureLog"
#define GC_USER_DELETE_DRUGLOG_URL @"rest/laop/linkMan/cureLog"
#define GC_USER_DELETE_DIETLOG_URL @"rest/laop/linkMan/cureLog"
#define GC_USER_DELETE_EXERCISELOG_URL @"rest/laop/linkMan/cureLog"
#define GC_USER_GET_NEWMESSAGES_URL @"rest/laop/common/message"
#define GC_USER_RESET_NEWMESSAGES_URL @"rest/laop/common/message"
#define GC_USER_GET_APP_LANGUAGE_URL @"rest/laop/common/language"
#define GC_USER_GET_DOCTORSUGGESTSWITHATTACH_URL @"rest/laop/linkMan/suggest"
#define GC_USER_GET_MYDOCTORLIST_URL @"rest/laop/linkMan/doctor"


#endif
