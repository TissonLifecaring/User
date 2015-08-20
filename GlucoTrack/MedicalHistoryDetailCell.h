//
//  MedicalHistoryDetailCell.h
//  SugarNursing
//
//  Created by Dan on 14-11-25.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinesLabel.h"

@interface MedicalHistoryDetailCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *diseaseNameLabel;
@property (weak, nonatomic) IBOutlet LinesLabel *comfirmedDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *comfirmedHospitalLabel;
@property (weak, nonatomic) IBOutlet LinesLabel *treatmentConditionLabel;
@property (weak, nonatomic) IBOutlet LinesLabel *patientDataLabel;

@property (weak, nonatomic) IBOutlet LinesLabel *treatmentScheduleLabel;


@end
