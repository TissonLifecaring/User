//
//  PatientImage.h
//  SugarNursing
//
//  Created by Dan on 14-11-26.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PatientImage;

@protocol PatientImageDelegate <NSObject>

- (void)patientImage:(PatientImage *)patientImage imageDeleted:(NSIndexPath *)indexPath;

@end

@interface PatientImage : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UIImageView *patientDataImageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet id<PatientImageDelegate>delegate;

@end
