//
//  GCTableView.m
//  GlucoTrack
//
//  Created by Dan on 15-1-31.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "GCTableView.h"
#import "NoDataView.h"

@implementation GCTableView

//- (void)setupRefreshViewWithDelegate:(id<YALSunnyRefreshControlDelegate>)vc
//{
//    if (!self.refreshView) {
//        self.refreshView = [YALSunnyRefreshControl attachToScrollView:self];
//        self.refreshView.delegate = vc;
//    }
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        
        if ([self.dataSource numberOfSectionsInTableView:self] == 0
            ) {
            if ([self.tableFooterView isKindOfClass:[NoDataView class]] && self.tableFooterView.tag == 2014) {
                return;
            }
            NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, self.viewForBaselineLayout.frame.size.width, 100)];
            noDataView.tag = 2014;
            self.tableFooterView = noDataView;
            
        }else{
            if ([self.tableFooterView isKindOfClass:[UIView class]] && self.tableFooterView.tag == 2015) {
                return;
                
            }
            UIView *noDataView = [[UIView alloc] initWithFrame:CGRectZero];
            noDataView.tag = 2015;
            self.tableFooterView = noDataView;
        }
    }
}



@end
