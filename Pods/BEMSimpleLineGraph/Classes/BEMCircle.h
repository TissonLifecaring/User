//
//  BEMCircle.h
//  SimpleLineGraph
//
//  Created by Bobo on 12/27/13. Updated by Sam Spencer on 1/11/14.
//  Copyright (c) 2013 Boris Emorine. All rights reserved.
//  Copyright (c) 2014 Sam Spencer.
//


typedef NS_ENUM(NSInteger, BEMType){
    BEMTypeCircle = 0,
    BEMTypeImage,
};

#if __has_feature(objc_modules)
    // We recommend enabling Objective-C Modules in your project Build Settings for numerous benefits over regular #imports
    @import Foundation;
    @import UIKit;
    @import CoreGraphics;
#else
    #import <Foundation/Foundation.h>
    #import <UIKit/UIKit.h>
    #import <CoreGraphics/CoreGraphics.h>
#endif


/// Class to draw the circle for the points.
@interface BEMCircle : UIView

@property (nonatomic) BEMType type;

/// Set to YES if the data point circles should be constantly displayed. NO if they should only appear when relevant.
@property (assign, nonatomic) BOOL shouldDisplayConstantly;

/// The point color
@property (strong, nonatomic) UIColor *Pointcolor;
@property (strong, nonatomic) UIImage *PointImage;

/// The value of the point
@property (nonatomic) CGFloat absoluteValue;

@end