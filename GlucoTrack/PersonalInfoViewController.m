//
//  PersonalInfoViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-24.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "PersonalInfoViewController.h"
#import "UtilsMacro.h"
#import "ThumbnailImageView.h"
#import "CustomLabel.h"


@interface PersonalInfoViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *hud;
}


@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UILabel *userNameTips;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UITextField *identityCardField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet CustomLabel *serverLabel;
@property (weak, nonatomic) IBOutlet UITextField *genderField;
@property (weak, nonatomic) IBOutlet UITextField *birthDateField;
@property (strong, nonatomic) IBOutlet UIView *datePickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet ThumbnailImageView *thumbnail;

@property (strong, nonatomic) NSString *thumbnailURLString;
@property (strong, nonatomic) UIImage *thumbnailImage;

@property (strong, nonatomic) UIActionSheet *sheet;
@property (strong, nonatomic) UITextField *activeTextField;


@property (strong, nonatomic) NSFetchedResultsController *fetchController;
@property (strong, nonatomic) UserInfomation *userInfo;

@property (strong, nonatomic) UIPopoverController *popoverController;
@property (strong, nonatomic) UIImagePickerController *imagePickerVC;
@end

@implementation PersonalInfoViewController
@synthesize popoverController;

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)aHud
{
    [aHud removeFromSuperview];
    aHud = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Personal Information", nil);
    [self configureFetchController];
    [self configureUserInfo];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)configureFetchController
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userid.userId = %@ && userid.linkManId = %@",[NSString userID],[NSString linkmanID]];
    self.fetchController = [UserInfomation fetchAllGroupedBy:nil sortedBy:@"userid.userId" ascending:YES withPredicate:predicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    
    if (self.fetchController.fetchedObjects.count == 0) {
        self.userInfo = nil;
    }else{
        self.userInfo = self.fetchController.fetchedObjects[0];

    }
}

- (void)configureUserInfo
{
    [self.thumbnail sd_setImageWithURL:[NSURL URLWithString:self.userInfo.headImageUrl] placeholderImage:[UIImage imageNamed:@"thumbDefault"]];
    self.userNameField.text = self.userInfo.userName;
    self.phoneNumberField.text = self.userInfo.mobilePhone;
    self.phoneNumberField.userInteractionEnabled = NO;
    self.identityCardField.text = self.userInfo.identifyCard;
    self.identityCardField.userInteractionEnabled = NO;
    self.emailField.text = self.userInfo.email;
    self.emailField.userInteractionEnabled = NO;
    self.genderField.text = self.userInfo.sex;
    self.birthDateField.text = self.userInfo.birthday;
    self.serverLabel.text = self.userInfo.servLevel;
    
    if ([self.userNameField.text isEqualToString:@""]) {
        self.userNameField.userInteractionEnabled = YES;
        self.userNameTips.text = NSLocalizedString(@"You can change only once", nil);
    }else{
        self.userNameField.userInteractionEnabled = NO;
    }
    
    if ([self.identityCardField.text isEqualToString:@""]) {
        self.identityCardField.placeholder = NSLocalizedString(@"Setting when purchase", nil);
    }
    
    if ([self.emailField.text isEqualToString:@""]) {
        self.emailField.placeholder = NSLocalizedString(@"Binding your email in our Home", nil);
    }
}

#pragma mark - NSFetchedControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self configureUserInfo];
}

#pragma mark - TableViewDelegate/DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 ) {
        return 100;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.activeTextField resignFirstResponder];

    switch (indexPath.row) {
        case 0:
            [self showsImagePickerSheet];
            break;
        case 5:
            [self showsGenderPickerSheet];
            break;
        case 6:
        {
            if ([self.birthDateField.text isEqualToString:@""]) {
                [self.datePicker setDate:[NSDate date]];
            }else{
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                
                [self.datePicker setDate:[dateFormatter dateFromString:self.birthDateField.text] ];
            }
            
            [self showsDatePicker];
            break;
        }
        default:
            break;
    }
}

#pragma mark - PickerView

- (void)showsDatePicker
{
    if ([DeviceHelper phone])
    {
        
        hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];
        hud.margin = 0;
        hud.delegate = self;
        hud.customView = self.datePickerView;
        hud.mode = MBProgressHUDModeCustomView;
        [hud show:YES];
    }
    else
    {
        
        if (self.popoverController)
        {
            [self.popoverController dismissPopoverAnimated:NO];
            self.popoverController = nil;
        }
        
        UIViewController* popoverContent = [[UIViewController alloc] init];
        popoverContent.view = self.datePickerView;
        
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        self.popoverController.popoverContentSize = self.datePickerView.bounds.size;
        [self.popoverController presentPopoverFromRect:CGRectMake(150, 20+100+44*6, 0, 0)
                                                inView:self.view
                              permittedArrowDirections:UIPopoverArrowDirectionUp
                                              animated:YES];

    }
    
}

- (IBAction)pickerViewBtn:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 1001:
            break;
        case 1002:
        {
            [self configureSaveBarButtonItemHidden:NO];
            if (![ParseData parseDateIsAvaliable:self.datePicker.date]) {
                [hud hide:YES];
                return;
            }
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            self.birthDateField.text = [dateFormatter stringFromDate:self.datePicker.date];
            break;
        }
        default:
            break;
    }
    
    
    
    if ([DeviceHelper phone])
    {
        [hud hide:YES];
    }
    else
    {
        if (self.popoverController)
        {
            [self.popoverController dismissPopoverAnimated:YES];
            self.popoverController = nil;
        }
    }
}

- (void)userInfoSave:(id)sender
{
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.delegate = self;
    hud.labelText = NSLocalizedString(@"Saving Data", nil);
    [hud show:YES];
    
    // Check the format
    if (![ParseData parseDateStringIsAvaliable:self.birthDateField.text format:@"yyyy-MM-dd"]) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Date Format is not avaliable", nil);
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
        return;
    }
    
    [self updateDataToServer];
}

- (void)updateDataToCoreData
{
    
    NSDictionary *newInfo = [@{@"birthday": self.birthDateField.text,
                               @"email": self.emailField.text,
                               @"identifyCard": self.identityCardField.text,
                               @"sex":self.genderField.text,
                               @"userName": self.userNameField.text,
                               @"headImageUrl": !self.thumbnailURLString ? self.userInfo.headImageUrl : self.thumbnailURLString} mutableCopy];
  
    [self.userInfo updateCoreDataForData:newInfo withKeyPath:nil];
    [[CoreDataStack sharedCoreDataStack] saveContext];
}

- (void)uploadThumbnailToServer
{
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.delegate = self;
    hud.labelText = NSLocalizedString(@"Thumbnail uploading", nil);
    [hud show:YES];
    
    NSData *imageData = UIImageJPEGRepresentation(self.thumbnailImage, 0.5);
    NSDictionary *parameters = @{@"method": @"uploadFile",
                                 @"fileType": @"2"};
    [GCRequest userUploadFileWithParameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"thumbnail.jpg" mimeType:@"image/jpeg"];
        
        
    } withBlock:^(NSDictionary *responseData, NSError *error){

        if (!error) {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                
                // 保存用户图片URL
                self.thumbnailURLString = [ParseData parseDictionary:responseData ForKeyPath:@"fileUrl"];
                
                [self updateDataToServer];
                hud.labelText = NSLocalizedString(@"Upload succeed", nil);
            }else{
                [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
            }
        }else {
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
        }
        [hud hide:YES afterDelay:HUD_TIME_DELAY];

    }];

}

- (void)updateDataToServer
{
    NSDictionary *parameters = @{@"method":@"linkManInfoEdit",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"linkManId":[NSString linkmanID],
                                 @"birthday": self.birthDateField.text,
                                 @"email": self.emailField.text,
                                 @"identifyCard": self.identityCardField.text,
                                 @"sex":self.genderField.text,
                                 @"userName": self.userNameField.text,
                                 @"headImageUrl": !self.thumbnailURLString ? self.userInfo.headImageUrl : self.thumbnailURLString,
                                 };
    [GCRequest userEditUserInfoWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        
        if (!error) {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                // CoreData updated
                [self updateDataToCoreData];
                
                [self configureSaveBarButtonItemHidden:YES];

                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"Data Updated", nil);
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(HUD_TIME_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];

                });
            }else{
                hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
            }
           
        }else{ hud.labelText = [NSString localizedErrorMesssagesFromError:error]; }
        [hud hide:YES afterDelay:HUD_TIME_DELAY];

    }];
 
}

#pragma mark - TextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
    [self configureSaveBarButtonItemHidden:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = textField;
}

- (void)configureSaveBarButtonItemHidden:(BOOL)hidden
{
    if (!self.navigationItem.rightBarButtonItem) {
        if (!hidden) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(userInfoSave:)];
        }
        
    }else{
        if (hidden) {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
        
}

#pragma mark - ActionSheet

- (void)showsGenderPickerSheet
{
    self.sheet = [[UIActionSheet alloc] initWithTitle:@"选择性别" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:NSLocalizedString(@"male", nil),NSLocalizedString(@"female", nil),nil];
    self.sheet.tag = 101;
    [self.sheet showInView:self.view];
}

- (void)showsImagePickerSheet
{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.sheet = [[UIActionSheet alloc] initWithTitle:@"选择图片" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从图库选择",@"从相册选择",nil];
    }
    else
    {
        self.sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从图库选择",@"从相册选择", nil];
    }
    self.sheet.tag = 102;
    

    [self.sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Show save button
    if (buttonIndex > 0) {
        [self configureSaveBarButtonItemHidden:NO];
    }
    
    switch (actionSheet.tag) {
        case 101:
            if (buttonIndex > 0)
            {
                self.genderField.text = [actionSheet buttonTitleAtIndex:buttonIndex];
            }
            else
            {
                
            }
            break;
        case 102:
        {
            NSUInteger soureType = 0;
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                switch (buttonIndex)
                {
                    case 1:
                        soureType = UIImagePickerControllerSourceTypeCamera;
                        break;
                    case 2:
                        soureType = UIImagePickerControllerSourceTypePhotoLibrary;
                        break;
                    case 3:
                        soureType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                        break;
                    default:
                        self.imagePickerVC = nil;
                        break;
                }
            }
            else
            {
                switch (buttonIndex)
                {
                    case 1:
                        soureType = UIImagePickerControllerSourceTypePhotoLibrary;
                        break;
                    case 2:
                        soureType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                        break;
                    default:
                        self.imagePickerVC = nil;
                        break;
                }
    
            }
            
            if (buttonIndex >0)
            {
                
                UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
                imagePickerVC.delegate = self;
                imagePickerVC.allowsEditing = YES;
                imagePickerVC.sourceType = soureType;
                
                self.imagePickerVC = imagePickerVC;
            }
        }
            break;
    }
 }

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (self.imagePickerVC)
    {
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [self presentViewController:self.imagePickerVC animated:YES completion:nil];
        }
        else
        {
            
            if (self.popoverController)
            {
                [self.popoverController dismissPopoverAnimated:NO];
                self.popoverController = nil;
            }
            
            self.popoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePickerVC];
            [self presentViewController:self.imagePickerVC animated:YES completion:nil];
        }
    }
}

#pragma mark - ImagePickerViewControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        self.thumbnailImage = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self uploadThumbnailToServer];

}


@end
