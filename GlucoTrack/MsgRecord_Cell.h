//
//  MsgRecord_Cell.h
//  糖博士
//
//  Created by Ian on 14-11-11.
//  Copyright (c) 2014年 Ian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinesLabel.h"
#import "Advise.h"

@interface MsgRecord_Cell : UITableViewCell

@property (strong, nonatomic) IBOutlet LinesLabel *timeLabel;
@property (strong, nonatomic) IBOutlet LinesLabel *detailLabel;
@property (strong, nonatomic) IBOutlet LinesLabel *contentLabel;


@property (strong, nonatomic) IBOutlet UICollectionView *myCollectView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentLabelBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectViewHeightConstraint;


- (void)configureCellWithModel:(id)model delegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)theDelegate;



@end
