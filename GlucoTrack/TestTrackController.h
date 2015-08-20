//
//  TestTrackController.h
//  SugarNursing
//
//  Created by Dan on 14-11-10.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BEMSimpleLineGraph/BEMSimpleLineGraphView.h>

@interface TestTrackController : UIViewController<BEMSimpleLineGraphDataSource,BEMSimpleLineGraphDelegate>

@property (nonatomic, strong) NSMutableArray *arrayOfXValues;
@property (nonatomic, strong) NSMutableArray *arrayOfYValues;

@end
