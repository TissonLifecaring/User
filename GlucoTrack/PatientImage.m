//
//  PatientImage.m
//  SugarNursing
//
//  Created by Dan on 14-11-26.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "PatientImage.h"

@implementation PatientImage

- (IBAction)toggleDeleteBtn:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(patientImage:imageDeleted:)]) {
        [self.delegate patientImage:self imageDeleted:self.indexPath];
    }
}
@end
