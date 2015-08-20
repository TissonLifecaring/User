//
//  EvaluateCell.h
//  SugarNursing
//
//  Created by Dan on 14-11-21.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinesLabel.h"

@interface EvaluateCell : UITableViewCell

@property (weak, nonatomic) IBOutlet LinesLabel *scoreLabel;
@property (weak, nonatomic) IBOutlet LinesLabel *evaluateTextLabel;

@end
