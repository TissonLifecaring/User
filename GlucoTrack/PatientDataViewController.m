//
//  PatientDataViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-26.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "PatientDataViewController.h"
#import "PatientImage.h"
#import <QuartzCore/QuartzCore.h>
#import "MyTextView.h"
#import <MWPhotoBrowser.h>


@interface PatientDataViewController ()<UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MWPhotoBrowserDelegate,PatientImageDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *hud;
}

@property (weak, nonatomic) IBOutlet MyTextView *textView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) UIImage *uploadImage;
@property (strong, nonatomic) NSMutableArray *photos;

@property (strong, nonatomic) UIPopoverController *popoverController;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@end

@implementation PatientDataViewController
@synthesize popoverController;

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)aHud
{
    [aHud removeFromSuperview];
    aHud = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Medical Case", nil);
    
    [self configureTextView];
    [self configureMedicalRecordImages];
}

#pragma mark - Configuration

- (void)configureTextView
{
    if ([self.medicalRecord.mediRecord isEqualToString:NSLocalizedString(@"Please fill your info", nil)]) {
        self.textView.text = nil;
    }else self.textView.text = self.medicalRecord.mediRecord;
    
    self.textView.placeholder = NSLocalizedString(@"Please describe your case", nil);
    self.textView.placeholderColor = [UIColor lightGrayColor];
    [[self.textView layer] setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [[self.textView layer] setBorderWidth:1.0];
}

- (void)configureMedicalRecordImages
{
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.mode = MBProgressHUDModeText;
    hud.delegate = self;
    
    NSDictionary *parameters = @{@"method":@"getMediRecordAttach",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"mediHistId":self.medicalRecord.mediHistId};
    [GCRequest userGEtMedicalREcordImagesWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        if (!error) {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                
                // 清除缓存
                self.medicalRecord.recordPhoto = nil;
                
                NSArray *responseImages = [responseData objectForKey:@"mediAttach"];
                NSMutableOrderedSet *recordPhotos = [[NSMutableOrderedSet alloc] initWithCapacity:10];

                for (NSDictionary *imageDic in responseImages) {
                    RecordPhoto *photo = [RecordPhoto createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    [photo updateCoreDataForData:imageDic withKeyPath:nil];
                    
                    [recordPhotos addObject:photo];
                }
                
                self.medicalRecord.recordPhoto = recordPhotos;
                [[CoreDataStack sharedCoreDataStack] saveContext];
                
                // 刷新页面
                [self.collectionView reloadData];
                
            }else{
                hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
        }
        
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
    }];
 
}

- (void)configureRightBarButton
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
}

- (void)updateDataToServer
{
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    
    hud.delegate = self;
    hud.labelText = NSLocalizedString(@"Saving Data", nil);
    [hud show:YES];
    
    NSMutableArray *uploadImages = [@[] mutableCopy];
    for (RecordPhoto *photo in self.medicalRecord.recordPhoto) {
        NSDictionary *photoDic = @{@"attachName":photo.attachName,
                                   @"attachPath":photo.attachPath};
        [uploadImages addObject:photoDic];
    }
    
    NSString *uploadJsonString;
    if (uploadImages.count > 0 ) {
        uploadJsonString = [uploadImages JSONString];
    }else uploadJsonString = @"";
    
    
    NSDictionary *parameters = @{@"method":@"mediRecordEdit",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"linkManId":[NSString linkmanID],
                                 @"mediHistId":self.medicalRecord.mediHistId,
                                 @"mediName":self.medicalRecord.mediName,
                                 @"mediRecord":self.textView.text,
                                 @"diagTime":self.medicalRecord.diagTime,
                                 @"mediAttach":uploadJsonString
                                 };
    
    
    [GCRequest userEditMedicalRecordWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        if (!error) {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                
                self.medicalRecord.mediRecord = self.textView.text;
                [[CoreDataStack sharedCoreDataStack] saveContext];
                
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"Data Updated", nil);
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
                
            }else{
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
            }
        }else {
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
        }
        [hud hide:YES afterDelay:HUD_TIME_DELAY];

    }];

}

- (void)save:(id)sender
{
    [self.view endEditing:YES];
    [self updateDataToServer];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.medicalRecord.recordPhoto.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PatientImage *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    
    [self configureImageCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureImageCell:(PatientImage *)cell atIndexPath:(NSIndexPath *)indexPath
{
    RecordPhoto *photo = [self.medicalRecord.recordPhoto objectAtIndex:indexPath.row];
    [cell.patientDataImageView sd_setImageWithURL:[NSURL URLWithString:photo.attachPath] placeholderImage:[UIImage imageNamed:@"thumbDefault"]];
    cell.indexPath = indexPath;
    cell.backgroundColor = [UIColor lightGrayColor];
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:10];
    MWPhoto *photo;
    
    
    for (RecordPhoto *recordPhoto in self.medicalRecord.recordPhoto)
    {
        
        NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:recordPhoto.attachPath]];
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
        photo = [MWPhoto photoWithImage:image];
//        photo.caption = recordPhoto.attachName;
        [photos addObject:photo];
    }
    self.photos = photos;
    
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.displayActionButton = NO;
    photoBrowser.displayNavArrows = NO;
    photoBrowser.displaySelectionButtons = NO;
    photoBrowser.alwaysShowControls = YES;
    photoBrowser.zoomPhotosToFill = YES;
    photoBrowser.enableGrid = NO;
    photoBrowser.startOnGrid = NO;
    photoBrowser.enableSwipeToDismiss = YES;
    [photoBrowser setCurrentPhotoIndex:indexPath.row];
    
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)])
    {
        // conditionly check for any version >= iOS 8
        [self showViewController:photoBrowser sender:nil];
        
    }
    else
    {
        // iOS 7 or below
        [self.navigationController pushViewController:photoBrowser animated:YES];
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize retVal = CGSizeMake(80, 80);
    return retVal;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 5, 0, 5);
}

#pragma mark - PatientImageCellDelegate

- (void)patientImage:(PatientImage *)patientImage imageDeleted:(NSIndexPath *)indexPath
{
    NSMutableOrderedSet *photos = [self.medicalRecord.recordPhoto mutableCopy];
    [photos removeObjectAtIndex:indexPath.row];
    self.medicalRecord.recordPhoto = photos;
    
    [self.collectionView reloadData];
    [self configureRightBarButton];
}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return self.medicalRecord.recordPhoto.count;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < self.medicalRecord.recordPhoto.count) {
        return [self.photos objectAtIndex:index];
    }
    return nil;
}


#pragma mark - ButtonAction

- (IBAction)AddPatientImage:(id)sender
{
    [self showImagePickerSheet];
}

- (void)showImagePickerSheet
{
    UIActionSheet *sheet;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择图片" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从图库选择",@"从相册选择", nil];
    
    }
    else
    {
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择图片" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从图库选择",@"从相册选择", nil];
    }
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
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
                self.imagePickerController = nil;
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
                self.imagePickerController = nil;
                break;
        }
    }
    
    if (buttonIndex >0)
    {
        UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
        imagePickerVC.delegate = self;
        imagePickerVC.allowsEditing = YES;
        imagePickerVC.sourceType = soureType;
        
        self.imagePickerController = imagePickerVC;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (self.imagePickerController)
    {
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [self presentViewController:self.imagePickerController animated:YES completion:nil];
        }
        else
        {
            
            if (self.popoverController)
            {
                [self.popoverController dismissPopoverAnimated:NO];
                self.popoverController = nil;
            }
            
            self.popoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePickerController];
            [self presentViewController:self.imagePickerController animated:YES completion:nil];
        }
    }
}

#pragma mark - ImagePickerViewControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        self.uploadImage = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self uploadImageToServer];
    
}

- (void)uploadImageToServer
{
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.delegate = self;
    
    if (self.medicalRecord.recordPhoto.count >= 10) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Images is more than 10", nil);
        [hud show:YES];
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
        return;
    }
    
    hud.labelText = NSLocalizedString(@"Thumbnail uploading", nil);
    [hud show:YES];
    
    NSData *imageData = UIImageJPEGRepresentation(self.uploadImage, 0.5);
    NSDictionary *parameters = @{@"method": @"uploadFile",
                                 @"fileType": @"2"};
    [GCRequest userUploadFileWithParameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"medicalCase.jpg" mimeType:@"image/jpeg"];
        
        
    } withBlock:^(NSDictionary *responseData, NSError *error){
        
        if (!error) {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                
                [self configureRightBarButton];
                
                // 保存用户图片URL
                NSString * uploadImageURL = [ParseData parseDictionary:responseData ForKeyPath:@"fileUrl"];
                
                // 缓存在CoreData中，没有保存
                
                RecordPhoto *photo = [RecordPhoto createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                photo.attachName = @"name";
                photo.attachPath = uploadImageURL;
                
                NSMutableOrderedSet *photos = [self.medicalRecord.recordPhoto mutableCopy];
                [photos addObject:photo];
                self.medicalRecord.recordPhoto = photos;
                
                // 刷新
                [self.collectionView reloadData];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.medicalRecord.recordPhoto.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
                });
                
                
                hud.labelText = NSLocalizedString(@"Upload succeed", nil);

            }else{
                hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
            }
        }else {
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
        }
        [hud hide:YES afterDelay:HUD_TIME_DELAY];

    }];

}

#pragma mark - TextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self configureRightBarButton];
}



@end
