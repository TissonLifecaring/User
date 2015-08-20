//
//  User.h
//  SugarNursing
//
//  Created by Dan on 14-12-16.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UtilsMacro.h"


@interface GCRequest : NSObject

// login
+ (NSURLSessionDataTask *)userLoginWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// logout
+ (NSURLSessionDataTask *)userLogoutWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *responseData, NSError *error))block;

// register
+ (NSURLSessionDataTask *)userRegisterWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// isRegister
+ (NSURLSessionDataTask *)userIsRegisteredWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *responseData, NSError *error))block;

// getCode
+ (NSURLSessionDataTask *)userGetCodeWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// getInfo
+ (NSURLSessionDataTask *)userGetInfoWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData,NSError *error))block;

// reset password
+ (NSURLSessionDataTask *)userResetPasswordWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *responseData,NSError *error))block;

// rebind mobile
+ (NSURLSessionDataTask *)userRebindMobileWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *responseData,NSError *error))block;

// userInfo edit
+ (NSURLSessionDataTask *)userEditUserInfoWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData,NSError *error))block;

// file upload
+ (NSURLSessionDataTask *)userUploadFileWithParameters:(id)parameters constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))bodyBlock withBlock:(void (^)(NSDictionary *responseData,NSError *error))block;

// get MedicalRecord
+ (NSURLSessionDataTask *)userGetMedicalRecordWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// edit MedicalRecord
+ (NSURLSessionDataTask *)userEditMedicalRecordWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// get MedicalRecordImages
+ (NSURLSessionDataTask *)userGEtMedicalREcordImagesWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// delete MedicalRecord
+ (NSURLSessionDataTask *)userDeleteMedicalRecordWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// get Detection Line Data
+ (NSURLSessionDataTask *)userGetDetectionDataWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// get Doctor Suggestion
+ (NSURLSessionDataTask *)userGetDoctorSuggestionWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// get Message List
+ (NSURLSessionDataTask *)userGetMessageListWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// send Message
+ (NSURLSessionDataTask *)userSendMessageWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// feed back
+ (NSURLSessionDataTask *)userSendFeedbackWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// get Recovery record
+ (NSURLSessionDataTask *)userGetRecoveryRecordWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// get Control Effect
+ (NSURLSessionDataTask *)userGetControlEffectWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// edit Detect Log
+ (NSURLSessionDataTask *)userEditDetectLogWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// edit drug Log
+ (NSURLSessionDataTask *)userEditDrugLogWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// edit Diet Log
+ (NSURLSessionDataTask *)userEditDietLogWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// edit exercise Log
+ (NSURLSessionDataTask *)userEditExerciseLogWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// delete Detect Log
+ (NSURLSessionDataTask *)userDeleteDetectLogWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// delete Drug Log
+ (NSURLSessionDataTask *)userDeleteDrugLogWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// delete Diet Log
+ (NSURLSessionDataTask *)userDeleteDietLogWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// delete Exercise Log
+ (NSURLSessionDataTask *)userDeleteExerciseLogWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// get New Messages
+ (NSURLSessionDataTask *)userGetNewMessagesWithParameters:(id)parameters withBlock:(void (^) (NSDictionary *responseData, NSError *error))block;

// reset New Messages
+ (NSURLSessionDataTask *)userResetNewMessagesWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *responseData, NSError *error))block;

// get App Language
+ (NSURLSessionDataTask *)userGetAppLanguageWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *responseData, NSError *error))block;


// getDoctorSuggestsWithAttach
+ (NSURLSessionDataTask *)userGetDoctorSuggestsWithAttachWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *responseData, NSError *error))block;

// getMyDoctorList
+ (NSURLSessionDataTask *)userGetMyDoctorListWithAttachWithParameters:(id)parameters withBlock:(void (^)(NSDictionary *responseData, NSError *error))block;




@end
