//
//  User.m
//  SugarNursing
//
//  Created by Dan on 14-12-16.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "GCRequest.h"
#import "GCHttpClient.h"
#import <objc/runtime.h>

@implementation GCRequest

+ (BOOL)handleRetCodeInRespnoseObject:(id)responseObject
{
    NSString *ret_code = [ParseData parseDictionary:responseObject ForKeyPath:@"ret_code"];
    if ([ret_code isEqualToString:@"0"]) {
        return YES;
    }else{
        [NSString localizedMsgFromRet_code:ret_code withHUD:NO];
        return NO;
    }
}

+ (NSURLSessionDataTask *)userLoginWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_LOGIN_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    //MD5 Parameters need to be mutable before change.
    parameters = [parameters mutableCopy];
    [parameters setValue:[[ParseData parseDictionary:parameters ForKeyPath:@"password"] md5] forKey:@"password"];
    
    return [[GCHttpClient sharedClient] POST:GC_LOGIN_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DDLogDebug(@"Login resoponseData:%@",responseObject);
        
        if (block) {
            block(responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
        
        if (block) {
            block(nil,error);
        }
    }];
    
}

+ (NSURLSessionDataTask *)userLogoutWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_LOGOUT_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_LOGOUT_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"Logout resoponseData:%@",responseObject);
        
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
        
        if (block) {
            block(nil,error);
        }
    }];
}

+ (NSURLSessionDataTask *)userRegisterWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_USER_REGISTER_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);

    // MD5
    parameters = [parameters mutableCopy];
    [parameters setValue:[[ParseData parseDictionary:parameters ForKeyPath:@"password"] md5] forKey:@"password"];
    
    // Sex
    [(NSDictionary *)parameters sexFormattingToServerForKey:@"sex"];
    
    //birthday
    [(NSDictionary *)parameters dateFormattingFromUser:@"yyyy-MM-dd" ToServer:@"yyyyMMdd" ForKey:@"birthday"];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_REGISTER_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DDLogDebug(@"Register resoponseData:%@",responseObject);
//        responseObject = [(NSDictionary *)responseObject keysLowercased];

        
        if (block) {
            block(responseObject,nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
        
        if (block) {
            block(nil,error);
        }
    }];
}

+ (NSURLSessionDataTask *)userGetCodeWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_GET_CODE_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    return [[GCHttpClient sharedClient] POST:GC_GET_CODE_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"Get Code responseData:%@",responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
        if (block) {
            block(nil,error);
        }
    }];
    
}

+ (NSURLSessionDataTask *)userIsRegisteredWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_IS_REGISTER_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    return [[GCHttpClient sharedClient] POST:GC_IS_REGISTER_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"User is registered resoponseData:%@",responseObject);
        
        if (block) {
            block(responseObject,nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
        
        if (block) {
            block(nil,error);
        }
    }];
    
}

+ (NSURLSessionDataTask *)userGetInfoWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_USER_GETINFO_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);

    // Parameters have to be mutable !!!
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_GETINFO_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DDLogDebug(@"Get UserInfo resoponseData:%@",responseObject);
//        responseObject = [(NSDictionary *)responseObject keysLowercased];
        
        if (block) {
            block(responseObject, nil);
        }
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
        
        if (block) {
            block(nil,error);
        }
    }];
}

+ (NSURLSessionDataTask *)userResetPasswordWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_USER_RESET_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    // MD5
    parameters = [parameters mutableCopy];
    [parameters setValue:[[ParseData parseDictionary:parameters ForKeyPath:@"password"] md5] forKey:@"password"];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_RESET_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DDLogDebug(@"Reset password resoponseData:%@",responseObject);
//        responseObject = [(NSDictionary *)responseObject keysLowercased];
        
        if (block) {
            block(responseObject,nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
        
        if (block) {
            block(nil,error);
        }
    }];
}

+ (NSURLSessionDataTask *)userRebindMobileWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_USER_REBIND_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_REBIND_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"Edit Account responseData: %@",responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];
}

+ (NSURLSessionDataTask *)userEditUserInfoWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_USER_EDITUSERINFO_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    // Sex
    [(NSDictionary *)parameters sexFormattingToServerForKey:@"sex"];
    
    //birthday
    [(NSDictionary *)parameters dateFormattingFromUser:@"yyyy-MM-dd" ToServer:@"yyyyMMdd" ForKey:@"birthday"];
    
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_EDITUSERINFO_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DDLogDebug(@"Edit userInfo responseaData: %@",responseObject);
//        responseObject = [(NSDictionary *)responseObject keysLowercased];
        
        if (block) {
            block(responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription],NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];

}

+ (NSURLSessionDataTask *)userUploadFileWithParameters:(id)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))bodyBlock withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_USER_UPLOADFILE_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_UPLOADFILE_URL parameters:parameters constructingBodyWithBlock:bodyBlock success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DDLogDebug(@"Upload file responseData: %@",responseObject);
//        responseObject = [(NSDictionary *)responseObject keysLowercased];
        
        if (block) {
            block(responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription],NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];


}

+ (NSURLSessionDataTask *)userGetMedicalRecordWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_GET_MEDICALRECORD_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    return [[GCHttpClient sharedClient] POST:GC_USER_GET_MEDICALRECORD_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"Get Medical Record responseData: %@",responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription],NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];
}

+ (NSURLSessionDataTask *)userEditMedicalRecordWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_EDIT_MEDICALRECORD_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [(NSDictionary *)parameters dateFormattingFromUser:@"yyyy-MM-dd" ToServer:@"yyyyMMdd" ForKey:@"diagTime"];
    [self signValueFor:parameters];
    return [[GCHttpClient sharedClient] POST:GC_USER_EDIT_MEDICALRECORD_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"Edit Medical Record reponseData: %@",responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];
}

+ (NSURLSessionDataTask *)userGEtMedicalREcordImagesWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_GET_MEDICALIMAGES_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    return [[GCHttpClient sharedClient] POST:GC_USER_GET_MEDICALIMAGES_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"GET Medical Record Images reponseData: %@",responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];
}

+ (NSURLSessionDataTask *)userDeleteMedicalRecordWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_DELETE_MEDICALRECORD_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    return [[GCHttpClient sharedClient] POST:GC_USER_DELETE_MEDICALRECORD_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"Delete MedicalRecord resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil,error);
        }
    }];
}

+ (NSURLSessionDataTask *)userGetDetectionDataWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_GET_DETECTIONDATA_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [parameters dateFormattingFromUser:@"yyyy-MM-dd" ToServer:@"yyyyMMdd" ForKey:@"queryDay"];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_GET_DETECTIONDATA_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"GET Detection Data resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];
}

+ (NSURLSessionDataTask *)userGetDoctorSuggestionWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_GET_DOCTORSUGGESTIONS_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_GET_DOCTORSUGGESTIONS_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"GET Doctor Suggestions resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];
    
}

+ (NSURLSessionDataTask *)userGetMessageListWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_GET_MESSAGELIST_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_GET_MESSAGELIST_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"GET Message List resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];
}

+ (NSURLSessionDataTask *)userSendMessageWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_SEND_MESSAGE_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_SEND_MESSAGE_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"SEND Message resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];
}

+ (NSURLSessionDataTask *)userSendFeedbackWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_SEND_FEEDBACK_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_SEND_FEEDBACK_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DDLogDebug(@"SEND Feedback resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];
    
}

+ (NSURLSessionDataTask *)userGetRecoveryRecordWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_GET_RECOVERYRECORD_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_GET_RECOVERYRECORD_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DDLogDebug(@"GET RecoveryRecord resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];
    
}

+ (NSURLSessionDataTask *)userGetControlEffectWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_GET_CONTROLEFFECT_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_GET_CONTROLEFFECT_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DDLogDebug(@"GET controlEffect resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
        
    }];
    
}

+ (NSURLSessionDataTask *)userEditDetectLogWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_EDIT_DETECTLOG_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_EDIT_DETECTLOG_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"Edit detectLog resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];
}

+ (NSURLSessionDataTask *)userEditDrugLogWithParameters:(id)parameters withBlock:(void(^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_EDIT_DRUGLOG_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_EDIT_DRUGLOG_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"Edit drugLog resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];
}

+ (NSURLSessionDataTask *)userEditDietLogWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_EDIT_DIETLOG_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_EDIT_DIETLOG_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DDLogDebug(@"Edit dietLog resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
        
    }];
}

+ (NSURLSessionDataTask *)userEditExerciseLogWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_EDIT_EXERCISELOG_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];

    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_EDIT_EXERCISELOG_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DDLogDebug(@"Edit exerciseLog resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
        
    }];
}

+ (NSURLSessionDataTask *)userDeleteDetectLogWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_DELETE_DETECTLOG_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_DELETE_DETECTLOG_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DDLogDebug(@"Delete detectLog resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
        
    }];
}

+ (NSURLSessionDataTask *)userDeleteDrugLogWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_DELETE_DRUGLOG_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_DELETE_DRUGLOG_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DDLogDebug(@"Delete drugLog resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
        
    }];
}

+ (NSURLSessionDataTask *)userDeleteDietLogWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_DELETE_DIETLOG_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_DELETE_DIETLOG_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DDLogDebug(@"Delete dietLog resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
        
    }];
}

+ (NSURLSessionDataTask *)userDeleteExerciseLogWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_DELETE_EXERCISELOG_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_DELETE_EXERCISELOG_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DDLogDebug(@"Delete exerciseLog resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
        
    }];
}

+ (NSURLSessionDataTask *)userGetNewMessagesWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_GET_NEWMESSAGES_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_GET_NEWMESSAGES_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"Get New Messages resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];
    
}

+ (NSURLSessionDataTask *)userResetNewMessagesWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_RESET_NEWMESSAGES_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_RESET_NEWMESSAGES_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"Reset New Messages resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];
}

+ (NSURLSessionDataTask *)userGetAppLanguageWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_GET_APP_LANGUAGE_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_GET_APP_LANGUAGE_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"Get App Language resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];
}


// getDoctorSuggestsWithAttach
+ (NSURLSessionDataTask *)userGetDoctorSuggestsWithAttachWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_GET_DOCTORSUGGESTSWITHATTACH_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_GET_DOCTORSUGGESTSWITHATTACH_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"Get DoctorSuggestsWithAttach resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];
}



// getMyDoctorList
+ (NSURLSessionDataTask *)userGetMyDoctorListWithAttachWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL: %@", [NSURL URLWithString:GC_USER_GET_MYDOCTORLIST_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_GET_MYDOCTORLIST_URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"Get MyDoctorList resonseData: %@", responseObject);
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Request Error: %@ %@",[error localizedDescription], NSStringFromSelector(_cmd));
        if (block) {
            block(nil, error);
        }
    }];
}



+ (id)signValueFor:(id)parameters
{
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        if ([[parameters allKeys] containsObject:@"sign"]) {
            [parameters setValue:[NSString generateSigWithParameters:parameters] forKey:@"sign"];
        }
    }
    return parameters;
}

@end
