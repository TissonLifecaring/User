//
//  WarningViewController.h
//  SugarNursing
//
//  Created by Dan on 14-11-23.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WarningViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *dataArray;

@property (weak, nonatomic) IBOutlet UITableView *warningTableView;

@end
