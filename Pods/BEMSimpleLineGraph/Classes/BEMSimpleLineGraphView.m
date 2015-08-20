//
//  BEMSimpleLineGraphView.m
//  SimpleLineGraph
//
//  Created by Bobo on 12/27/13. Updated by Sam Spencer on 1/11/14.
//  Copyright (c) 2013 Boris Emorine. All rights reserved.
//  Copyright (c) 2014 Sam Spencer.
//

#import "BEMSimpleLineGraphView.h"

#if !__has_feature(objc_arc)
// Add the -fobjc-arc flag to enable ARC for only these files, as described in the ARC documentation: http://clang.llvm.org/docs/AutomaticReferenceCounting.html
#error BEMSimpleLineGraph is built with Objective-C ARC. You must enable ARC for these files.
#endif

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define DEFAULT_FONT_NAME @"HelveticaNeue-Light"

#define  Y_PINCH_MIN_VALUE 12.0f
#define  Y_PINCH_MAX_VALUE 30.0f
#define  X_DAY_MIN_VALUE (0.21/60)
#define  X_MONTH_MIN_VALUE 0.0002
#define  X_WEEK_MIN_VALUE 0.0002
#define  SIZE_MIN_VALUE 12
#define  SIZE_MAX_VALUE 20



@interface BEMSimpleLineGraphView () {
    
    /// The Date in the Graph
    NSDate *currentDate;
    
    /// The number of Points in the Graph
    NSInteger numberOfPoints;
    NSInteger numberOfGaps;
    
    /// The closest point to the touch point
    BEMCircle *closestDot;
    CGFloat currentlyCloser;
    
    /// The hyper and hypo value
    CGFloat hyperValue;
    CGFloat hypoValue;
    
    /// All of the X-Axis Values
    NSMutableArray *xAxisValues;
    
    NSMutableArray *xAxisValuePoints;
    
    /// All of the X-Axis Label Points
    NSMutableArray *xAxisLabelPoints;
    
    /// All of the Y-Axis Label Points
    NSMutableArray *yAxisLabelPoints;
    
    // Points for average value etc.
    NSMutableArray *averagePoints;
    
    /// All of the Y-Axis Values
    NSMutableArray *yAxisValues;
    
    /// All of the Data Points
    NSMutableArray *dataPoints;
    
    
    
    /// All of the X-Axis Labels
    NSMutableArray *xAxisLabels;
}

/// ScrollView for data scrolling when user scroll across the graph
@property (strong, nonatomic) UIScrollView *scrollView;

@property (assign) GraphSearchMode searchMode;

/// The vertical line which appears when the user drags across the graph
@property (strong, nonatomic) UIView *touchInputLine;

/// View for picking up pan gesture
@property (strong, nonatomic, readwrite) UIView *panView;

/// Label to display when there is no data
@property (strong, nonatomic) UILabel *noDataLabel;

/// The gesture recognizer picking up the pan in the graph view
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;

/// The label displayed when enablePopUpReport is set to YES
@property (strong, nonatomic) UILabel *popUpLabel;

/// The view used for the background of the popup label
@property (strong, nonatomic) UIView *popUpView;

/// The X position (center) of the view for the popup label
@property (nonatomic) CGFloat xCenterLabel;

/// The Y position (center) of the view for the popup label
@property (nonatomic) CGFloat yCenterLabel;

/// The Y offset necessary to compensate the labels on the X-Axis
@property (nonatomic) CGFloat XAxisLabelYOffset;

/// The X offset necessary to compensate the labels on the Y-Axis. Will take the value of the bigger label on the Y-Axis
@property (nonatomic) CGFloat YAxisLabelXOffset;

@property (nonatomic) CGFloat dayInterval;
@property (nonatomic) CGFloat monthInterval;
@property (nonatomic) CGFloat weekInterval;

@property (nonatomic) CGFloat yMaxValue;
@property (nonatomic) CGFloat yMinValue;

/// Find which point is currently the closest to the vertical line
- (BEMCircle *)closestDotFromtouchInputLine:(UIView *)touchInputLine;

/// Determines the biggest Y-axis value from all the points
- (CGFloat)maxValue;

/// Determines the smallest Y-axis value from all the points
- (CGFloat)minValue;

@end

@implementation BEMSimpleLineGraphView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) [self commonInit];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) [self commonInit];
    return self;
}

- (void)commonInit {
    // Do any initialization that's common to both -initWithFrame: and -initWithCoder: in this method
    
    _avoidLayoutSubviews = NO;
    
    // Set the X Axis label font
    _labelFont = [UIFont fontWithName:DEFAULT_FONT_NAME size:13];
    
    // Set Animation Values
    _animationGraphEntranceTime = 1.5;
    
    // Set numberOfGaps Value
    numberOfGaps = 1;
    
    // Set Color Values
    _colorXaxisLabel = [UIColor blackColor];
    _colorYaxisLabel = [UIColor blackColor];
    _colorTop = [UIColor colorWithRed:0 green:122.0/255.0 blue:255/255 alpha:1];
    _colorLine = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1];
    _colorBottom = [UIColor colorWithRed:0 green:122.0/255.0 blue:255/255 alpha:1];
    _colorPoint = [UIColor whiteColor];
    //    _colorTouchInputLine = [UIColor grayColor];
    _colorBackgroundPopUplabel = [UIColor whiteColor];
    _hyperColor = [UIColor colorWithRed:244./255. green:2./255. blue:0/255. alpha:1];
    _hypoColor = [UIColor colorWithRed:0 green:122./255. blue:255/255 alpha:1];
    //    _alphaTouchInputLine = 0.2;
    //    _widthTouchInputLine = 1.0;
    _colorBackgroundXaxis = nil;
    _alphaBackgroundXaxis = 1.0;
    _colorBackgroundYaxis = nil;
    _alphaBackgroundYaxis = 1.0;
    
    // Set Alpha Values
    _alphaTop = 1.0;
    _alphaBottom = 1.0;
    _alphaLine = 1.0;
    
    // Set Size Values
    _widthLine = 1.0;
    _sizePoint = 20.0;
    
    // Set Default Feature Values
    _enableTouchReport = NO;
    _enablePopUpReport = NO;
    _enableBezierCurve = NO;
    _enableXAxisLabel = YES;
    _enableYAxisLabel = NO;
    _YAxisLabelXOffset = 0;
    _autoScaleYAxis = YES;
    _alwaysDisplayDots = NO;
    _alwaysDisplayPopUpLabels = NO;
    
    // Initialize the various arrays
    xAxisValues = [NSMutableArray array];
    xAxisValuePoints = [NSMutableArray array];
    xAxisLabelPoints = [NSMutableArray array];
    yAxisLabelPoints = [NSMutableArray array];
    averagePoints = [NSMutableArray array];
    dataPoints = [NSMutableArray array];
    xAxisLabels = [NSMutableArray array];
    yAxisValues = [NSMutableArray array];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.avoidLayoutSubviews) {
        return;
    }
    
    // Let the delegate know that the graph began layout updates
    if ([self.delegate respondsToSelector:@selector(lineGraphDidBeginLoading:)])
        [self.delegate lineGraphDidBeginLoading:self];
    
    // Get the number of points in the graph
    [self layoutNumberOfPoints];
    
    if (numberOfPoints <= 0) {
        return;
    } else {
        // Draw the graph
        [self drawEntireGraph];
        
        // Let the delegate know that the graph finished layout updates
        if ([self.delegate respondsToSelector:@selector(lineGraphDidFinishLoading:)])
            [self.delegate lineGraphDidFinishLoading:self];
        
        
        // Scroll to the visible point
        CGPoint fPoint;
        switch (self.searchMode)
        {
            case GraphSearchModeByDay:
            {
                fPoint = CGPointMake([[xAxisValuePoints firstObject] floatValue]-20, 0);
            }
                break;
            default:
            {
                CGFloat lastValue = [[xAxisValuePoints firstObject] floatValue];
                if (lastValue > self.scrollView.contentSize.width - self.scrollView.bounds.size.width)
                {
                    fPoint = CGPointMake(self.scrollView.contentSize.width - self.scrollView.bounds.size.width, 0);
                }
                else if (lastValue < self.scrollView.bounds.size.width)
                    fPoint = CGPointMake(0, 0);
                else
                    fPoint = CGPointMake([[xAxisValuePoints firstObject] floatValue]-CGRectGetWidth(self.scrollView.bounds)/2, 0);
            }
                break;
        }
        [self.scrollView setContentOffset:fPoint animated:YES];
    }
    
}

- (void)layoutNumberOfPoints {
    
    // Remove the No Data Label that were previously on the graph
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[UILabel class]] && subview.tag == 4000)
            [subview removeFromSuperview];
    }
    
    
    // Get the total number of data points from the delegate
    if ([self.dataSource respondsToSelector:@selector(numberOfPointsInLineGraph:)]) {
        numberOfPoints = [self.dataSource numberOfPointsInLineGraph:self];
        
    } else if ([self.delegate respondsToSelector:@selector(numberOfPointsInGraph)]) {
        [self printDeprecationWarningForOldMethod:@"numberOfPointsInGraph" andReplacementMethod:@"numberOfPointsInLineGraph:"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        numberOfPoints = [self.delegate numberOfPointsInGraph];
#pragma clang diagnostic pop
        
    } else if ([self.delegate respondsToSelector:@selector(numberOfPointsInLineGraph:)]) {
        [self printDeprecationAndUnavailableWarningForOldMethod:@"numberOfPointsInLineGraph:"];
        numberOfPoints = 0;
        
    } else numberOfPoints = 0;
    
    // There are no points to load
    if (numberOfPoints == 0) {
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(noDataLabelEnableForLineGraph:)] &&
            ![self.delegate noDataLabelEnableForLineGraph:self]) return;
        
        //        NSLog(@"[BEMSimpleLineGraph] Data source contains no data. A no data label will be displayed and drawing will stop. Add data to the data source and then reload the graph.");
        
        //        self.noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.viewForBaselineLayout.frame.size.width, self.viewForBaselineLayout.frame.size.height)];
        self.noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.viewForBaselineLayout.frame.size.width, 100)];
        self.noDataLabel.tag = 4000;
        self.noDataLabel.backgroundColor = [UIColor clearColor];
        self.noDataLabel.textAlignment = NSTextAlignmentCenter;
        self.noDataLabel.text = NSLocalizedString(@"No Data", nil);
        self.noDataLabel.textColor = [UIColor lightGrayColor];
        self.noDataLabel.font = [UIFont systemFontOfSize:17.0];
        //        self.noDataLabel.textColor = self.colorLine;
        
        [self.viewForBaselineLayout addSubview:self.noDataLabel];
        
        // Let the delegate know that the graph finished layout updates
        if ([self.delegate respondsToSelector:@selector(lineGraphDidFinishLoading:)])
            [self.delegate lineGraphDidFinishLoading:self];
        return;
        
        //    } else if (numberOfPoints == 1) {
        //        NSLog(@"[BEMSimpleLineGraph] Data source contains only one data point. Add more data to the data source and then reload the graph.");
        //        BEMCircle *circleDot = [[BEMCircle alloc] initWithFrame:CGRectMake(0, 0, self.sizePoint, self.sizePoint)];
        //        circleDot.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        //        circleDot.Pointcolor = self.colorPoint;
        //        circleDot.alpha = 1;
        //        [self addSubview:circleDot];
        //        return;
        //
    } else {
        // Remove all dots that were previously on the graph
        for (UILabel *subview in [self subviews]) {
            if ([subview isEqual:self.noDataLabel])
                [subview removeFromSuperview];
        }
    }
}

- (void)layoutTouchReport {
    // If the touch report is enabled, set it up
    if (self.enableTouchReport == YES || self.enablePopUpReport == YES) {
        // Initialize the vertical gray line that appears where the user touches the graph.
        self.touchInputLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.widthTouchInputLine, self.frame.size.height)];
        self.touchInputLine.backgroundColor = self.colorTouchInputLine;
        self.touchInputLine.alpha = 0;
        [self addSubview:self.touchInputLine];
        
        self.panView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.viewForBaselineLayout.frame.size.width, self.viewForBaselineLayout.frame.size.height)];
        self.panView.backgroundColor = [UIColor clearColor];
        [self.viewForBaselineLayout addSubview:self.panView];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.panGesture.delegate = self;
        [self.panGesture setMaximumNumberOfTouches:1];
        [self.panView addGestureRecognizer:self.panGesture];
        
        if (self.enablePopUpReport == YES && self.alwaysDisplayPopUpLabels == NO) {
            NSDictionary *labelAttributes = @{NSFontAttributeName: self.labelFont};
            NSString *maxValueString = [NSString stringWithFormat:@"%li",
                                        (long)[self calculateMaximumPointValue].integerValue];
            NSString *minValueString = [NSString stringWithFormat:@"%li",
                                        (long)[self calculateMinimumPointValue].integerValue];
            NSString *longestString = nil;
            if ([minValueString sizeWithAttributes:labelAttributes].width >
                [maxValueString sizeWithAttributes:labelAttributes].width)
                longestString = minValueString;
            else longestString = maxValueString;
            
            self.popUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
            if ([self.delegate respondsToSelector:@selector(popUpSuffixForlineGraph:)])
                self.popUpLabel.text = [NSString stringWithFormat:@"%@%@", longestString, [self.delegate popUpSuffixForlineGraph:self]];
            else self.popUpLabel.text = longestString;
            self.popUpLabel.textAlignment = 1;
            self.popUpLabel.numberOfLines = 1;
            self.popUpLabel.font = self.labelFont;
            self.popUpLabel.backgroundColor = [UIColor clearColor];
            [self.popUpLabel sizeToFit];
            self.popUpLabel.alpha = 0;
            
            self.popUpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.popUpLabel.frame.size.width + 7, self.popUpLabel.frame.size.height + 2)];
            self.popUpView.backgroundColor = self.colorBackgroundPopUplabel;
            self.popUpView.alpha = 0;
            self.popUpView.layer.cornerRadius = 3;
            [self addSubview:self.popUpView];
            [self addSubview:self.popUpLabel];
        }
    }
}

#pragma mark - Drawing

- (void)drawEntireGraph {
    // The following method calls are in this specific order for a reason
    // Changing the order of the method calls below can result in drawing glitches and even crashes
    
    // Set the Y-Axis Offset if the Y-Axis is enabled. The offset is relative to the size of the longest label on the Y-Axis.
    if (self.enableYAxisLabel) {
        NSDictionary *attributes = @{NSFontAttributeName: self.labelFont};
        if (self.autoScaleYAxis == YES){
            NSString *maxValueString = [NSString stringWithFormat:@"%.1f", (float)[self maxValue]];
            NSString *minValueString = [NSString stringWithFormat:@"%.1f", (float)[self minValue]];
            
            self.YAxisLabelXOffset = MAX([maxValueString sizeWithAttributes:attributes].width,
                                         [minValueString sizeWithAttributes:attributes].width) + 5;
        }
        else{
            
            NSString *longestString = [NSString stringWithFormat:@"%i", (int)self.frame.size.height];
            self.YAxisLabelXOffset = [longestString sizeWithAttributes:attributes].width + 5;
        }
    } else self.YAxisLabelXOffset = 0;
    
    // Add a scroll view for drawing the graph
    [self addScrollViewForGraph];
    
    // Draw the X-Axis
    [self drawXAxis];
    
    // Draw the graph
    [self drawDots];
    
    // Draw the Y-Axis
    if (self.enableYAxisLabel) [self drawYAxis];
}

- (void)drawDots
{
    CGFloat positionOnXAxis; // The position on the X-axis of the point currently being created.
    CGFloat positionOnYAxis; // The position on the Y-axis of the point currently being created.
    
    // Remove all dots that were previously on the scrollView
    // @bug Remove all popUpLabel and popUpView that were previously on the scrollView
    for (UIView *subview in [self.scrollView subviews])
    {
        if ([subview isKindOfClass:[BEMCircle class]])
            [subview removeFromSuperview];
        if ([subview isKindOfClass:[UILabel class]] && subview.tag == 3100)
        {
            [subview removeFromSuperview];
        }
        if ([subview isKindOfClass:[UIView class]] && subview.tag == 3101)
        {
            [subview removeFromSuperview];
        }
    }
    
    if ([self.dataSource respondsToSelector:@selector(hyperValueForLineGraph:)])
    {
        hyperValue = [self.dataSource hyperValueForLineGraph:self];
    } else {
        hyperValue = [self maxValue];
    }
    
    if ([self.dataSource respondsToSelector:@selector(hypoValueForLineGraph:)])
    {
        hypoValue = [self.dataSource hypoValueForLineGraph:self];
    } else {
        hypoValue = [self minValue];
    }
    
    // Remove all data points before adding them to the array
    [dataPoints removeAllObjects];
    
    // Remove all yAxis values before adding them to the array
    [yAxisValues removeAllObjects];
    
    // Remove all xAxis values before addint them to the array
    [xAxisValuePoints removeAllObjects];
    
    // Loop through each point and add it to the graph
    @autoreleasepool {
        for (int i = 0; i < numberOfPoints; i++)
        {
            CGFloat dotValue = 0;
            GraphDotType dotType;
            NSDate *dotDate;
            
            if ([self.dataSource respondsToSelector:@selector(lineGraph:valueAndDotTypeForPointAtIndex:)]) {
                NSDictionary *valueAndType = [self.dataSource lineGraph:self valueAndDotTypeForPointAtIndex:i];
                NSNumber *value = [valueAndType valueForKey:@"value"];
                NSNumber *type = [valueAndType valueForKey:@"type"];
                dotValue = value.floatValue;
                dotType = type.integerValue;
                
            }
            else if ([self.delegate respondsToSelector:@selector(valueForIndex:)])
            {
                [self printDeprecationWarningForOldMethod:@"valueForIndex:" andReplacementMethod:@"lineGraph:valueForPointAtIndex:"];
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                dotValue = [self.delegate valueForIndex:i];
#pragma clang diagnostic pop
                
            } else if ([self.delegate respondsToSelector:@selector(lineGraph:valueForPointAtIndex:)]) {
                [self printDeprecationAndUnavailableWarningForOldMethod:@"lineGraph:valueForPointAtIndex:"];
                NSException *exception = [NSException exceptionWithName:@"Implementing Unavailable Delegate Method" reason:@"lineGraph:valueForPointAtIndex: is no longer available on the delegate. It must be implemented on the data source." userInfo:nil];
                [exception raise];
                
                
            } else [NSException raise:@"lineGraph:valueForPointAtIndex: protocol method is not implemented in the data source. Throwing exception here before the system throws a CALayerInvalidGeometry Exception." format:@"Value for point %f at index %lu is invalid. CALayer position may contain NaN: [0 nan]", dotValue, (unsigned long)i];
            
            
            if ([self.dataSource respondsToSelector:@selector(lineGraph:dateOnXAxisForIndex:)]) {
                dotDate = [self.dataSource lineGraph:self dateOnXAxisForIndex:i];
            }else [NSException raise:@"lineGraph:dateOnXAxisForIndex: protocol method is not implemented in the data source. Throwing exception here before the system throws a CALayerInvalidGeometry Exception." format:@"Value for point %f at index %lu is invalid. CALayer position may contain NaN: [0 nan]", dotValue, (unsigned long)i];
            
            
            positionOnXAxis = [self xPostionForDotDate:dotDate];
            positionOnYAxis = [self yPositionForDotValue:dotValue];
            
            [dataPoints addObject:[NSNumber numberWithFloat:dotValue]];
            [xAxisValuePoints addObject:[NSNumber numberWithFloat:positionOnXAxis]];
            [yAxisValues addObject:[NSNumber numberWithFloat:positionOnYAxis]];
            
            
            if (self.animationGraphEntranceTime != 0 || self.alwaysDisplayDots == YES) {
                
                BEMCircle *circleDot = [[BEMCircle alloc] initWithFrame:CGRectMake(0, 0, self.sizePoint, self.sizePoint)];
                circleDot.type = BEMTypeImage;
                
                circleDot.center = CGPointMake(positionOnXAxis, positionOnYAxis);
                circleDot.tag = i+100;
                circleDot.alpha = 0;
                circleDot.absoluteValue = dotValue;
                
                switch (dotType)
                {
                    case GraphDotTypeDetect:
                        if (dotType == GraphDotTypeDetect)
                        {
                            if (dotValue > hyperValue)
                            {
                                circleDot.Pointcolor = self.hyperColor;
                            }
                            else if (dotValue < hypoValue)
                            {
                                circleDot.Pointcolor = self.hypoColor;
                            }
                            else circleDot.Pointcolor = self.colorPoint;
                        }
                        circleDot.PointImage = [UIImage imageNamed:@"detect_"];
                        break;
                        
                    case GraphDotTypeDrug:
                        circleDot.Pointcolor = [UIColor colorWithRed:52/255.0 green:152/255.0 blue:219/255.0 alpha:1];
                        circleDot.PointImage = [UIImage imageNamed:@"drug_"];
                        break;
                    case GraphDotTypeDiet:
                        circleDot.Pointcolor = [UIColor colorWithRed:231/255.0 green:70/255.0 blue:60/255.0 alpha:1];
                        circleDot.PointImage = [UIImage imageNamed:@"diet_"];
                        break;
                    default:
                        circleDot.Pointcolor = self.colorPoint;
                        break;
                }
                
                
                [self.scrollView addSubview:circleDot];
                
                if (self.alwaysDisplayPopUpLabels == YES) {
                    if ([self.delegate respondsToSelector:@selector(lineGraph:alwaysDisplayPopUpAtIndex:)]) {
                        if ([self.delegate lineGraph:self alwaysDisplayPopUpAtIndex:i] == YES) {
                            [self displayPermanentLabelForPoint:circleDot];
                        }
                    } else [self displayPermanentLabelForPoint:circleDot];
                }
                
                // Dot entrance animation
                if (self.animationGraphEntranceTime == 0) {
                    if (self.alwaysDisplayDots == NO) {
                        circleDot.alpha = 0;  // never reach here
                    } else circleDot.alpha = 0.8;
                } else {
                    [UIView animateWithDuration:(float)self.animationGraphEntranceTime/numberOfPoints delay:(float)i*((float)self.animationGraphEntranceTime/numberOfPoints) options:UIViewAnimationOptionCurveLinear animations:^{
                        circleDot.alpha = 0.8;
                    } completion:^(BOOL finished) {
                        if (self.alwaysDisplayDots == NO) {
                            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                                circleDot.alpha = 0;
                            } completion:nil];
                        }
                    }];
                }
            }
        }
    }
    
    // CREATION OF THE LINE AND BOTTOM AND TOP FILL
    [self drawLine];
}

- (void)drawLine {
    for (UIView *subview in [self.scrollView subviews]) {
        if ([subview isKindOfClass:[BEMLine class]])
            [subview removeFromSuperview];
    }
    
    BEMLine *line = [[BEMLine alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height)];
    line.opaque = NO;
    line.alpha = 1;
    line.backgroundColor = [UIColor clearColor];
    line.topColor = self.colorTop;
    line.bottomColor = self.colorBottom;
    line.topAlpha = self.alphaTop;
    line.bottomAlpha = self.alphaBottom;
    line.lineWidth = self.widthLine;
    line.lineAlpha = self.alphaLine;
    line.bezierCurveIsEnabled = self.enableBezierCurve;
    line.arrayOfYPoints = yAxisValues;
    line.arrayOfXPoints = xAxisValuePoints;
    line.frameOffset = self.XAxisLabelYOffset;
    line.xAxisBackgroundAlpha = self.alphaBackgroundXaxis;
    line.arrayOfValues = self.graphValuesForDataPoints;
    if (self.colorBackgroundXaxis == nil) {
        line.xAxisBackgroundColor = self.colorBottom;
    } else {
        line.xAxisBackgroundColor = self.colorBackgroundXaxis;
    }
    if (self.enableReferenceXAxisLines || self.enableReferenceYAxisLines) {
        line.enableRefrenceFrame = self.enableReferenceAxisFrame;
        
        line.enableRefrenceLines = YES;
        line.arrayOfVerticalRefrenceLinePoints = self.enableReferenceXAxisLines ? xAxisLabelPoints: nil;
        line.arrayOfHorizontalRefrenceLinePoints = self.enableReferenceYAxisLines ?  yAxisLabelPoints: nil;
    }
    // average value line
    line.arrayOfAverageRefrenceLinePoints = averagePoints;
    
    line.color = self.colorLine;
    line.animationTime = self.animationGraphEntranceTime;
    line.animationType = self.animationGraphStyle;
    
    [self.scrollView addSubview:line];
    [self.scrollView sendSubviewToBack:line];
}

- (void)addScrollViewForGraph
{
    // Remove the scrollView that were previously on the graph
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[UIScrollView class]])
            [subview removeFromSuperview];
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.YAxisLabelXOffset, 0, self.viewForBaselineLayout.frame.size.width-self.YAxisLabelXOffset, self.viewForBaselineLayout.frame.size.height)];
    self.scrollView.bounces = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
    [self addSubview:self.scrollView];
    
    // Add Tap GestureRecognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTap:)];
    [self.scrollView addGestureRecognizer:tap];
    
    // Add Pinch GestureRecognizer
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetect:)];
    [self.scrollView addGestureRecognizer:pinch];
    
    
}

- (void)drawXAxis {
    if(!self.enableXAxisLabel) return;
    //    if (![self.dataSource respondsToSelector:@selector(lineGraph:labelOnXAxisForIndex:)] && ![self.dataSource respondsToSelector:@selector(labelOnXAxisForIndex:)]) return
    
    // Remove the labels that were previously added on the scroll view
    for (UIView *subview in [self.scrollView subviews]) {
        if ([subview isKindOfClass:[UILabel class]] && subview.tag == 1000)
            [subview removeFromSuperview];
    }
    
    
    if ([self.delegate respondsToSelector:@selector(numberOfGapsBetweenLabelsOnLineGraph:)]) {
        numberOfGaps = [self.delegate numberOfGapsBetweenLabelsOnLineGraph:self] + 1;
        
    } else if ([self.delegate respondsToSelector:@selector(numberOfGapsBetweenLabels)]) {
        [self printDeprecationWarningForOldMethod:@"numberOfGapsBetweenLabels" andReplacementMethod:@"numberOfGapsBetweenLabelsOnLineGraph:"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        numberOfGaps = [self.delegate numberOfGapsBetweenLabels] + 1;
#pragma clang diagnostic pop
        
    } else numberOfGaps = 1;
    
    
    // Remove all X-Axis Labels before adding them to the array
    [xAxisValues removeAllObjects];
    [xAxisLabels removeAllObjects];
    [xAxisLabelPoints removeAllObjects];
    
    if (NO)
    {
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        
        NSString *firstXLabel = @"";
        NSString *lastXLabel = @"";
        
        if ([self.dataSource respondsToSelector:@selector(lineGraph:labelOnXAxisForIndex:)]) {
            firstXLabel = [self.dataSource lineGraph:self labelOnXAxisForIndex:0];
            lastXLabel = [self.dataSource lineGraph:self labelOnXAxisForIndex:(numberOfPoints - 1)];
            
        } else if ([self.delegate respondsToSelector:@selector(labelOnXAxisForIndex:)]) {
            [self printDeprecationWarningForOldMethod:@"labelOnXAxisForIndex:" andReplacementMethod:@"lineGraph:labelOnXAxisForIndex:"];
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            firstXLabel = [self.delegate labelOnXAxisForIndex:0];
            lastXLabel = [self.delegate labelOnXAxisForIndex:(numberOfPoints - 1)];
#pragma clang diagnostic pop
            
        } else if ([self.delegate respondsToSelector:@selector(lineGraph:labelOnXAxisForIndex:)]) {
            [self printDeprecationAndUnavailableWarningForOldMethod:@"lineGraph:labelOnXAxisForIndex:"];
            NSException *exception = [NSException exceptionWithName:@"Implementing Unavailable Delegate Method" reason:@"lineGraph:labelOnXAxisForIndex: is no longer available on the delegate. It must be implemented on the data source." userInfo:nil];
            [exception raise];
            
        } else firstXLabel = @"";
        
        CGFloat viewWidth = self.scrollView.contentSize.width;
        
        // No support for multi-line in this condition
        
        UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, self.scrollView.contentSize.height-20, viewWidth/2, 20)];
        firstLabel.text = firstXLabel;
        firstLabel.font = self.labelFont;
        firstLabel.textAlignment = 0;
        firstLabel.textColor = self.colorXaxisLabel;
        firstLabel.backgroundColor = [UIColor clearColor];
        firstLabel.tag = 1000;
        [self.scrollView addSubview:firstLabel];
        [xAxisValues addObject:firstXLabel];
        [xAxisLabels addObject:firstLabel];
        
        NSNumber *xFirstAxisLabelCoordinate = [NSNumber numberWithFloat:firstLabel.center.x];
        [xAxisLabelPoints addObject:xFirstAxisLabelCoordinate];
        
        UILabel *lastLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.contentSize.width/2 - 3, self.scrollView.contentSize.height-20, self.scrollView.contentSize.width/2, 20)];
        lastLabel.text = lastXLabel;
        lastLabel.font = self.labelFont;
        lastLabel.textAlignment = 2;
        lastLabel.textColor = self.colorXaxisLabel;
        lastLabel.backgroundColor = [UIColor clearColor];
        lastLabel.tag = 1000;
        [self.scrollView addSubview:lastLabel];
        [xAxisValues addObject:lastXLabel];
        [xAxisLabels addObject:lastLabel];
        
        NSNumber *xLastAxisLabelCoordinate = [NSNumber numberWithFloat:lastLabel.center.x];
        [xAxisLabelPoints addObject:xLastAxisLabelCoordinate];
        
    }
    else
    {
        
        if ([self.dataSource respondsToSelector:@selector(currentDateInLineGraph:)])
        {
            currentDate = [self.dataSource currentDateInLineGraph:self];
        }
        else
        {
            currentDate = [NSDate date];
        }
        
        if ([self.dataSource respondsToSelector:@selector(searchModeInLineGraph:)])
        {
            self.searchMode = [self.dataSource searchModeInLineGraph:self];
        }
        else
        {
            self.searchMode = GraphSearchModeByDay;
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        CGFloat interval;
        NSInteger intervalCount;
        
        switch (self.searchMode)
        {
            case GraphSearchModeByDay:
            {
                [dateFormatter setDateFormat:@"yyyyMMdd000000"];
                NSString *dateString = [dateFormatter stringFromDate:currentDate];
                currentDate = [dateFormatter dateFromString:dateString];
                
                if (!self.dayInterval)
                {
                    if ([self.dataSource respondsToSelector:@selector(intervalForSecondInLineGraph:)])
                    {
                        self.dayInterval = [self.dataSource intervalForSecondInLineGraph:self];
                    }
                    else
                    {
                        self.dayInterval = 1.0/60;
                    }
                }
                
                interval = self.dayInterval;
                
                intervalCount = 24;
                
                self.scrollView.contentSize = CGSizeMake(interval * 60 * 60 * intervalCount, self.scrollView.frame.size.height);
                
            }
                break;
            case GraphSearchModeByThreeDay:
            {
                
                //以明天为最后一个点
                currentDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:currentDate];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMdd000000"];
                NSDate *aDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:currentDate]];
                
                NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
                NSInteger zoneInterval = [timeZone secondsFromGMTForDate:aDate];
                aDate = [aDate dateByAddingTimeInterval:zoneInterval];
                
                
                NSTimeInterval timeInterVal = -3 * 24 * 60 * 60;
                currentDate = [NSDate dateWithTimeInterval:timeInterVal sinceDate:aDate];
                
                if (!self.monthInterval)
                {
                    if ([self.dataSource respondsToSelector:@selector(intervalForDayInLineGraph:)])
                    {
                        self.monthInterval = [self.dataSource intervalForSecondInLineGraph:self];
                    }
                    else
                    {
                        self.monthInterval = 0.0005;
                    }
                }
                
                interval = self.monthInterval;
                
                intervalCount = 3;
                
                self.scrollView.contentSize = CGSizeMake(interval * 60 * 60 * 24 * intervalCount, self.scrollView.frame.size.height);
            }
                break;
            case GraphSearchModeByWeek:
            {
                
                //以明天为最后一个点
                currentDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:currentDate];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMdd000000"];
                NSDate *aDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:currentDate]];
                
                NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
                NSInteger zoneInterval = [timeZone secondsFromGMTForDate:aDate];
                aDate = [aDate dateByAddingTimeInterval:zoneInterval];
                
                
                NSTimeInterval timeInterVal = -7 * 24 * 60 * 60;
                currentDate = [NSDate dateWithTimeInterval:timeInterVal sinceDate:aDate];
                
                if (!self.monthInterval)
                {
                    if ([self.dataSource respondsToSelector:@selector(intervalForDayInLineGraph:)])
                    {
                        self.monthInterval = [self.dataSource intervalForSecondInLineGraph:self];
                    }
                    else
                    {
                        self.monthInterval = 0.0005;
                    }
                }
                
                interval = self.monthInterval;
                
                intervalCount = 7;
                
                self.scrollView.contentSize = CGSizeMake(interval * 60 * 60 * 24 * intervalCount, self.scrollView.frame.size.height);
                
            }
                break;
            case GraphSearchModeByTwoWeek:
            {
                
                //以明天为最后一个点
                currentDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:currentDate];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMdd000000"];
                NSDate *aDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:currentDate]];
                
                NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
                NSInteger zoneInterval = [timeZone secondsFromGMTForDate:aDate];
                aDate = [aDate dateByAddingTimeInterval:zoneInterval];
                
                
                NSTimeInterval timeInterVal = -14 * 24 * 60 * 60;
                currentDate = [NSDate dateWithTimeInterval:timeInterVal sinceDate:aDate];
                
                if (!self.monthInterval)
                {
                    if ([self.dataSource respondsToSelector:@selector(intervalForDayInLineGraph:)])
                    {
                        self.monthInterval = [self.dataSource intervalForSecondInLineGraph:self];
                    }
                    else
                    {
                        self.monthInterval = 0.0005;
                    }
                }
                
                interval = self.monthInterval;
                
                intervalCount = 14;
                
                self.scrollView.contentSize = CGSizeMake(interval * 60 * 60 * 24 * intervalCount, self.scrollView.frame.size.height);
            }
                break;
            case GraphSearchModeByMonth:
            {
                //以明天为最后一个点
                currentDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:currentDate];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMdd000000"];
                NSDate *aDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:currentDate]];
                
                NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
                NSInteger zoneInterval = [timeZone secondsFromGMTForDate:aDate];
                aDate = [aDate dateByAddingTimeInterval:zoneInterval];
                
                
                NSTimeInterval timeInterVal = -30 * 24 * 60 * 60;
                currentDate = [NSDate dateWithTimeInterval:timeInterVal sinceDate:aDate];
                
                if (!self.monthInterval)
                {
                    if ([self.dataSource respondsToSelector:@selector(intervalForDayInLineGraph:)])
                    {
                        self.monthInterval = [self.dataSource intervalForSecondInLineGraph:self];
                    }
                    else
                    {
                        self.monthInterval = 0.0005;
                    }
                }
                
                interval = self.monthInterval;
                
                intervalCount = 30;
                
                self.scrollView.contentSize = CGSizeMake(interval * 60 * 60 * 24 * intervalCount, self.scrollView.frame.size.height);
            }
                break;
            case GraphSearchModeByTwoMonth:
            {
                
                //以明天为最后一个点
                currentDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:currentDate];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMdd000000"];
                NSDate *aDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:currentDate]];
                
                NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
                NSInteger zoneInterval = [timeZone secondsFromGMTForDate:aDate];
                aDate = [aDate dateByAddingTimeInterval:zoneInterval];
                
                
                NSTimeInterval timeInterVal = -60 * 24 * 60 * 60;
                currentDate = [NSDate dateWithTimeInterval:timeInterVal sinceDate:aDate];
                
                if (!self.monthInterval)
                {
                    if ([self.dataSource respondsToSelector:@selector(intervalForDayInLineGraph:)])
                    {
                        self.monthInterval = [self.dataSource intervalForSecondInLineGraph:self];
                    }
                    else
                    {
                        self.monthInterval = 0.0005;
                    }
                }
                
                interval = self.monthInterval;
                
                intervalCount = 60;
                
                self.scrollView.contentSize = CGSizeMake(interval * 60 * 60 * 24 * intervalCount, self.scrollView.frame.size.height);
            }
                break;
            case GraphSearchModeByThreeMonth:
            {
                
                //以明天为最后一个点
                currentDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:currentDate];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMdd000000"];
                NSDate *aDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:currentDate]];
                
                NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
                NSInteger zoneInterval = [timeZone secondsFromGMTForDate:aDate];
                aDate = [aDate dateByAddingTimeInterval:zoneInterval];
                
                
                NSTimeInterval timeInterVal = -90 * 24 * 60 * 60;
                currentDate = [NSDate dateWithTimeInterval:timeInterVal sinceDate:aDate];
                
                if (!self.monthInterval)
                {
                    if ([self.dataSource respondsToSelector:@selector(intervalForDayInLineGraph:)])
                    {
                        self.monthInterval = [self.dataSource intervalForSecondInLineGraph:self];
                    }
                    else
                    {
                        self.monthInterval = 0.0005;
                    }
                }
                
                interval = self.monthInterval;
                
                intervalCount = 90;
                
                self.scrollView.contentSize = CGSizeMake(interval * 60 * 60 * 24 * intervalCount, self.scrollView.frame.size.height);
            }
                break;
                
        }
        
        
        
        NSInteger offset = [self offsetForXAxisWithNumberOfGaps]; // The offset (if possible and necessary) used to shift the Labels on the X-Axis for them to be centered.
        
        @autoreleasepool {
            
            for (int i = 1; i <= (intervalCount/numberOfGaps); i++) {
                NSString *xAxisLabelText = @"";
                NSInteger index;
                
                if ([self.dataSource respondsToSelector:@selector(lineGraph:labelOnXAxisForIndex:)]) {
                    index = i *numberOfGaps - 1 - offset;
                    xAxisLabelText = [self.dataSource lineGraph:self labelOnXAxisForIndex:index];
                    
                } else if ([self.delegate respondsToSelector:@selector(labelOnXAxisForIndex:)]) {
                    [self printDeprecationWarningForOldMethod:@"labelOnXAxisForIndex:" andReplacementMethod:@"lineGraph:labelOnXAxisForIndex:"];
                    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    xAxisLabelText = [self.delegate labelOnXAxisForIndex:(i *numberOfGaps - 1 - offset)];
#pragma clang diagnostic pop
                    
                } else if ([self.delegate respondsToSelector:@selector(lineGraph:labelOnXAxisForIndex:)]) {
                    [self printDeprecationAndUnavailableWarningForOldMethod:@"lineGraph:labelOnXAxisForIndex:"];
                    NSException *exception = [NSException exceptionWithName:@"Implementing Unavailable Delegate Method" reason:@"lineGraph:labelOnXAxisForIndex: is no longer available on the delegate. It must be implemented on the data source." userInfo:nil];
                    [exception raise];
                    
                }
                else
                {
                    
                    index = i * numberOfGaps - 1 - offset;
                    NSTimeInterval timeInterval;
                    
                    
                    switch (self.searchMode)
                    {
                        case GraphSearchModeByDay:
                        {
                            timeInterval = index * numberOfGaps * 60 * 60;
                            
                            NSDate *time = [currentDate dateByAddingTimeInterval:timeInterval];
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"MM/dd HH:mm"];
                            NSString *timeString = [dateFormatter stringFromDate:time];
                            
                            xAxisLabelText = [timeString stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
                            break;
                        }
                        default:
                        {
                            timeInterval = index * numberOfGaps * 60 * 60 * 24;
                            
                            NSDate *time = [currentDate dateByAddingTimeInterval:timeInterval];
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"MM/dd"];
                            
                            xAxisLabelText = [dateFormatter stringFromDate:time];
                        }
                            break;
                    }
                    
                    
                    
                }
                
                UILabel *labelXAxis = [[UILabel alloc] init];
                labelXAxis.text = xAxisLabelText;
                labelXAxis.font = self.labelFont;
                labelXAxis.textAlignment = 1;
                labelXAxis.textColor = self.colorXaxisLabel;
                labelXAxis.backgroundColor = [UIColor clearColor];
                [xAxisLabels addObject:labelXAxis];
                labelXAxis.tag = 1000;
                
                // Add support multi-line, but this might overlap with the graph line if text have too many lines
                labelXAxis.numberOfLines = 0;
                CGRect lRect = [labelXAxis.text boundingRectWithSize:self.viewForBaselineLayout.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:labelXAxis.font} context:nil];
                
                CGRect rect = labelXAxis.frame;
                rect.size = lRect.size;
                labelXAxis.frame = rect;
                
                switch (self.searchMode)
                {
                    case GraphSearchModeByDay:
                    {
                        [labelXAxis setCenter:CGPointMake(index * numberOfGaps * interval * 60 * 60, self.scrollView.contentSize.height - lRect.size.height/2)];
                        break;
                    }
                    default:
                    {
                        [labelXAxis setCenter:CGPointMake(index * numberOfGaps * interval * 60 * 60 * 24, self.scrollView.contentSize.height - lRect.size.height/2)];
                        break;
                    }
                }
                
                [self.scrollView addSubview:labelXAxis];
                
                [xAxisLabelPoints addObject:[NSNumber numberWithFloat:labelXAxis.center.x]];
                [xAxisValues addObject:xAxisLabelText];
                
                if (i == 1) {
                    CGPoint point = labelXAxis.center;
                    labelXAxis.center = CGPointMake(point.x+labelXAxis.bounds.size.width/2, point.y);
                }
            }
            
            
            // Use for removing the overlaped labels in XAsix when there are too many labels
            __block NSUInteger lastMatchIndex;
            NSMutableArray *overlapLabels = [NSMutableArray arrayWithCapacity:0];
            [xAxisLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
                
                if (idx == 0) lastMatchIndex = 0;
                else { // Skip first one
                    UILabel *prevLabel = [xAxisLabels objectAtIndex:lastMatchIndex];
                    CGRect r = CGRectIntersection(prevLabel.frame, label.frame);
                    if (CGRectIsNull(r)) lastMatchIndex = idx;
                    else [overlapLabels addObject:label]; // Overlapped
                }
            }];
            
            for (UILabel *l in overlapLabels) {
                [l removeFromSuperview];
            }
        }
    }
}

- (void)drawYAxis {
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[UILabel class]] && subview.tag == 2000) {
            [subview removeFromSuperview];
        }
        else if ([subview isKindOfClass:[UIView class] ] && subview.tag == 2100) {
            [subview removeFromSuperview];
        }
    }
    
    UIView *backgroundYaxis = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.YAxisLabelXOffset, self.frame.size.height)];
    backgroundYaxis.tag = 2100;
    if (self.colorBackgroundYaxis == nil) {
        backgroundYaxis.backgroundColor = self.colorTop;
    } else backgroundYaxis.backgroundColor = self.colorBackgroundYaxis;
    
    backgroundYaxis.alpha = self.alphaBackgroundYaxis;
    [self addSubview:backgroundYaxis];
    
    
    NSMutableArray *yAxisLabels = [NSMutableArray arrayWithCapacity:0];
    [yAxisLabelPoints removeAllObjects];
    [averagePoints removeAllObjects];
    
    if (self.autoScaleYAxis)
    {
        // Plot according to min-max range
        //        NSNumber *minimumValue = [NSNumber numberWithFloat:[self calculateMinimumPointValue].floatValue];
        //        NSNumber *maximumValue = [NSNumber numberWithFloat:[self calculateMaximumPointValue].floatValue];
        
        
        self.yMaxValue = [self maxValue];
        self.yMinValue = [self minValue];
        
        NSNumber *minimumValue = [NSNumber numberWithFloat:self.yMinValue];
        NSNumber *maximumValue = [NSNumber numberWithFloat:self.yMaxValue];
        NSNumber *averageValue = [self calculatePointValueAverage];
        
        
        CGFloat numberOfLabels;
        if ([self.delegate respondsToSelector:@selector(numberOfYAxisLabelsOnLineGraph:)]) numberOfLabels = [self.delegate numberOfYAxisLabelsOnLineGraph:self];
        else numberOfLabels = 3;
        
        NSMutableArray *dotValues = [[NSMutableArray alloc] initWithObjects:minimumValue,averageValue,maximumValue, nil];
        
        if (numberOfLabels <= 0) return;
        else if (numberOfLabels == 1)
        {
            [dotValues removeAllObjects];
            [dotValues addObject:[NSNumber numberWithFloat:(minimumValue.floatValue + maximumValue.floatValue)/2]];
        }
        else
        {
            /*
             根据最大最小值和线条数量均等划分
             
             for (int i=0; i<numberOfLabels; i++)
             {
             //间隔的数值跨度
             CGFloat eachValueHeight = ((maximumValue.floatValue - minimumValue.floatValue)/(numberOfLabels-1));
             [dotValues addObject:[NSNumber numberWithFloat:(minimumValue.floatValue + eachValueHeight*i)]];
             //                [dotValues addObject:[NSNumber numberWithInteger:(minimumValue.floatValue + ((maximumValue.floatValue - minimumValue.floatValue)/(numberOfLabels-1))*i)]];
             }
             */
            
            //Y坐标全部取整
            NSInteger dotValue = [minimumValue integerValue];
            while (dotValue < [maximumValue integerValue])
            {
                [dotValues addObject:[NSNumber numberWithInteger:dotValue]];
                dotValue++;
            }
            [dotValues addObject:averageValue];
        }
        
        
        for (NSNumber *dotValue in dotValues) {
            CGFloat yAxisPosition = [self yPositionForDotValue:dotValue.floatValue];
            //            CGFloat yAxisPosition = [self yPositionForDotValue:dotValue.integerValue];
            UILabel *labelYAxis = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.YAxisLabelXOffset - 5, 15)];
            labelYAxis.text = [[NSString alloc] initWithFormat:@"%ld",dotValue.integerValue];
            //            labelYAxis.text = [[NSString alloc] initWithFormat:@"%ld",dotValue.integerValue];
            labelYAxis.textAlignment = NSTextAlignmentRight;
            labelYAxis.font = self.labelFont;
            labelYAxis.textColor = self.colorYaxisLabel;
            labelYAxis.backgroundColor = [UIColor clearColor];
            labelYAxis.tag = 2000;
            labelYAxis.center = CGPointMake(self.YAxisLabelXOffset/2, yAxisPosition);
            [self addSubview:labelYAxis];
            [yAxisLabels addObject:labelYAxis];
            
            NSNumber *yAxisLabelCoordinate = [NSNumber numberWithFloat:labelYAxis.center.y];
            [yAxisLabelPoints addObject:yAxisLabelCoordinate];
            
            if ([minimumValue floatValue] == [maximumValue floatValue])
            {
                [yAxisLabelPoints removeObject:yAxisLabelCoordinate];
                [averagePoints addObject:yAxisLabelCoordinate];
                break;
            }
            
            if ([dotValue isEqual:averageValue])
            {
                labelYAxis.textColor = [UIColor orangeColor];
                labelYAxis.hidden = YES;
                [yAxisLabelPoints removeObject:yAxisLabelCoordinate];
                [averagePoints addObject:yAxisLabelCoordinate];
            }
            
        }
    }
    else
    {
        CGFloat numberOfLabels;
        if ([self.delegate respondsToSelector:@selector(numberOfYAxisLabelsOnLineGraph:)]) numberOfLabels = [self.delegate numberOfYAxisLabelsOnLineGraph:self];
        else numberOfLabels = 3;
        
        CGFloat graphHeight = self.frame.size.height;
        CGFloat graphSpacing = (graphHeight - self.XAxisLabelYOffset) / numberOfLabels;
        
        CGFloat yAxisPosition = graphHeight - self.XAxisLabelYOffset + graphSpacing/2;
        
        for (NSInteger i = numberOfLabels; i > 0; i--) {
            yAxisPosition -= graphSpacing;
            
            UILabel *labelYAxis = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.YAxisLabelXOffset - 5, 10)];
            labelYAxis.center = CGPointMake(self.YAxisLabelXOffset/2, yAxisPosition);
            labelYAxis.text = [NSString stringWithFormat:@"%i", (int)(graphHeight - self.XAxisLabelYOffset - yAxisPosition)];
            labelYAxis.font = self.labelFont;
            labelYAxis.textAlignment = NSTextAlignmentRight;
            labelYAxis.textColor = self.colorYaxisLabel;
            labelYAxis.backgroundColor = [UIColor clearColor];
            labelYAxis.tag = 2000;
            
            [self addSubview:labelYAxis];
            
            [yAxisLabels addObject:labelYAxis];
            
            NSNumber *yAxisLabelCoordinate = [NSNumber numberWithFloat:labelYAxis.center.y];
            [yAxisLabelPoints addObject:yAxisLabelCoordinate];
        }
    }
    
    //清除有覆盖的label
    // Detect overlapped labels
    __block NSUInteger lastMatchIndex;
    NSMutableArray *overlapLabels = [NSMutableArray arrayWithCapacity:0];
    [yAxisLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        
        if (idx==0) lastMatchIndex = 0;
        else { // Skip first one
            UILabel *prevLabel = [yAxisLabels objectAtIndex:lastMatchIndex];
            CGRect r = CGRectIntersection(prevLabel.frame, label.frame);
            if (CGRectIsNull(r)) lastMatchIndex = idx;
            else [overlapLabels addObject:label]; // overlapped
        }
    }];
    
    for (UILabel *label in overlapLabels) {
        [label removeFromSuperview];
    }
    
}

- (NSInteger)offsetForXAxisWithNumberOfGaps{
    // Calculates the optimum offset needed for the Labels to be centered on the X-Axis.
    NSInteger leftGap = numberOfGaps - 1;
    NSInteger rightGap = numberOfPoints - (numberOfGaps*(numberOfPoints/numberOfGaps));
    NSInteger offset = 0;
    
    if (leftGap != rightGap)
    {
        for (int i = 0; i <= numberOfGaps; i++)
        {
            if (leftGap - i == rightGap + i)
            {
                offset = i;
            }
        }
    }
    
    return offset;
}

- (void)displayPermanentLabelForPoint:(BEMCircle *)circleDot {
    self.enablePopUpReport = NO;
    self.xCenterLabel = circleDot.center.x;
    
    UILabel *permanentPopUpLabel = [[UILabel alloc] init];
    permanentPopUpLabel.textAlignment = 1;
    permanentPopUpLabel.numberOfLines = 0;
    permanentPopUpLabel.text = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:circleDot.absoluteValue]];
    permanentPopUpLabel.font = self.labelFont;
    permanentPopUpLabel.backgroundColor = [UIColor clearColor];
    [permanentPopUpLabel sizeToFit];
    permanentPopUpLabel.center = CGPointMake(self.xCenterLabel, circleDot.center.y - circleDot.frame.size.height/2 - 15);
    permanentPopUpLabel.alpha = 0;
    permanentPopUpLabel.tag = 3100;
    
    UIView *permanentPopUpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, permanentPopUpLabel.frame.size.width + 7, permanentPopUpLabel.frame.size.height + 2)];
    permanentPopUpView.backgroundColor = self.colorBackgroundPopUplabel;
    permanentPopUpView.alpha = 0;
    permanentPopUpView.layer.cornerRadius = 3;
    permanentPopUpView.tag = 3101;
    permanentPopUpView.center = permanentPopUpLabel.center;
    
    if (permanentPopUpLabel.frame.origin.x <= 0) {
        self.xCenterLabel = permanentPopUpLabel.frame.size.width/2 + 4;
        permanentPopUpLabel.center = CGPointMake(self.xCenterLabel, circleDot.center.y - circleDot.frame.size.height/2 - 15);
    } else if ((permanentPopUpLabel.frame.origin.x + permanentPopUpLabel.frame.size.width) >= self.scrollView.contentSize.width) {
        self.xCenterLabel = self.scrollView.contentSize.width - permanentPopUpLabel.frame.size.width/2 - 4;
        permanentPopUpLabel.center = CGPointMake(self.xCenterLabel, circleDot.center.y - circleDot.frame.size.height/2 - 15);
    }
    
    if (permanentPopUpLabel.frame.origin.y <= 2) {
        permanentPopUpLabel.center = CGPointMake(self.xCenterLabel, circleDot.center.y + circleDot.frame.size.height/2 + 15);
    }
    
    if ([self checkOverlapsForView:permanentPopUpView] == YES) {
        permanentPopUpLabel.center = CGPointMake(self.xCenterLabel, circleDot.center.y + circleDot.frame.size.height/2 + 15);
    }
    
    permanentPopUpView.center = permanentPopUpLabel.center;
    
    [self.scrollView addSubview:permanentPopUpView];
    [self.scrollView addSubview:permanentPopUpLabel];
    
    if (self.animationGraphEntranceTime == 0) {
        permanentPopUpLabel.alpha = 1;
        permanentPopUpView.alpha = 0.7;
    } else {
        [UIView animateWithDuration:0.5 delay:self.animationGraphEntranceTime options:UIViewAnimationOptionCurveLinear animations:^{
            permanentPopUpLabel.alpha = 1;
            permanentPopUpView.alpha = 0.7;
        } completion:nil];
    }
}

- (BOOL)checkOverlapsForView:(UIView *)view {
    for (UIView *viewForLabel in [self.scrollView subviews]) {
        if ([viewForLabel isKindOfClass:[UIView class]] && viewForLabel.tag == 3100) {
            if ((viewForLabel.frame.origin.x + viewForLabel.frame.size.width) >= view.frame.origin.x) {
                if (viewForLabel.frame.origin.y >= view.frame.origin.y && viewForLabel.frame.origin.y <= view.frame.origin.y + view.frame.size.height) return YES;
                else if (viewForLabel.frame.origin.y + viewForLabel.frame.size.height >= view.frame.origin.y && viewForLabel.frame.origin.y + viewForLabel.frame.size.height <= view.frame.origin.y + view.frame.size.height) return YES;
            }
        }
    }
    return NO;
}

- (UIImage *)graphSnapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES]; // Pre-iOS 7 Style [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - Data Source

- (void)reloadGraph {
    
    self.avoidLayoutSubviews = NO;
    
    for (UIView *subviews in self.subviews) {
        [subviews removeFromSuperview];
    }
    
    [self setNeedsLayout];
}

#pragma mark - Calculations

- (NSNumber *)calculatePointValueAverage {
    NSExpression *expression = [NSExpression expressionForFunction:@"average:" arguments:@[[NSExpression expressionForConstantValue:dataPoints]]];
    NSNumber *value = [expression expressionValueWithObject:nil context:nil];
    
    return value;
}

- (NSNumber *)calculatePointValueSum {
    NSExpression *expression = [NSExpression expressionForFunction:@"sum:" arguments:@[[NSExpression expressionForConstantValue:dataPoints]]];
    NSNumber *value = [expression expressionValueWithObject:nil context:nil];
    
    return value;
}

- (NSNumber *)calculatePointValueMedian {
    NSExpression *expression = [NSExpression expressionForFunction:@"median:" arguments:@[[NSExpression expressionForConstantValue:dataPoints]]];
    NSNumber *value = [expression expressionValueWithObject:nil context:nil];
    
    return value;
}

- (NSNumber *)calculatePointValueMode {
    NSExpression *expression = [NSExpression expressionForFunction:@"mode:" arguments:@[[NSExpression expressionForConstantValue:dataPoints]]];
    NSMutableArray *value = [expression expressionValueWithObject:nil context:nil];
    
    return [value firstObject];
}

- (NSNumber *)calculateLineGraphStandardDeviation {
    NSExpression *expression = [NSExpression expressionForFunction:@"stddev:" arguments:@[[NSExpression expressionForConstantValue:dataPoints]]];
    NSNumber *value = [expression expressionValueWithObject:nil context:nil];
    
    return value;
}

- (NSNumber *)calculateMinimumPointValue {
    if (dataPoints.count > 0) {
        NSExpression *expression = [NSExpression expressionForFunction:@"min:" arguments:@[[NSExpression expressionForConstantValue:dataPoints]]];
        NSNumber *value = [expression expressionValueWithObject:nil context:nil];
        return value;
    } else return 0;
}

- (NSNumber *)calculateMaximumPointValue {
    NSExpression *expression = [NSExpression expressionForFunction:@"max:" arguments:@[[NSExpression expressionForConstantValue:dataPoints]]];
    NSNumber *value = [expression expressionValueWithObject:nil context:nil];
    
    return value;
}


#pragma mark - Values

- (NSArray *)graphValuesForXAxis {
    return xAxisValues;
}

- (NSArray *)graphValuesForDataPoints {
    return dataPoints;
}

- (NSArray *)graphLabelsForXAxis {
    return xAxisLabels;
}

- (void)setAnimationGraphStyle:(BEMLineAnimation)animationGraphStyle
{
    _animationGraphStyle = animationGraphStyle;
    if (_animationGraphStyle == BEMLineAnimationNone)
        self.animationGraphEntranceTime = 0.f;
}


#pragma mark - ScrollView Tap And Pinch Gestures

- (void)pinchDetect:(UIPinchGestureRecognizer *)pinch
{
    CGFloat scale = [pinch scale];
    
    if ([pinch state] == UIGestureRecognizerStateEnded) {
        // Zoom in
        if (scale > 1.0) {
            [self lineGraphZoomIn];
        }else{
            [self lineGraphZoomOut];
        }
    }
}

- (void)lineGraphZoomOut
{
    self.sizePoint = self.sizePoint > SIZE_MIN_VALUE ? self.sizePoint-2 : SIZE_MIN_VALUE;
    
    self.yMaxValue = self.yMaxValue + 5;
    if (self.yMaxValue > Y_PINCH_MAX_VALUE) {
        self.yMaxValue = Y_PINCH_MAX_VALUE;
    }
    switch (self.searchMode) {
        case GraphSearchModeByDay:
            self.dayInterval = self.dayInterval - (0.4/60);
            if (self.dayInterval < X_DAY_MIN_VALUE) {
                self.dayInterval = X_DAY_MIN_VALUE;
            }
            break;
            
        default:
        {
            self.monthInterval = self.monthInterval - 0.0004;
            if (self.monthInterval < X_MONTH_MIN_VALUE) {
                self.monthInterval = X_MONTH_MIN_VALUE;
            }
        }
            break;
    }
    [self reloadGraph];
}

- (void)lineGraphZoomIn
{
    self.sizePoint = self.sizePoint < SIZE_MAX_VALUE ? self.sizePoint+2 : SIZE_MAX_VALUE;
    
    self.yMaxValue = self.yMaxValue - 5;
    if (self.yMaxValue < Y_PINCH_MIN_VALUE) {
        self.yMaxValue = Y_PINCH_MIN_VALUE;
    }
    switch (self.searchMode) {
        case GraphSearchModeByDay:
        {
            self.dayInterval = self.dayInterval + (0.4/60);
        }
            break;
        default:
        {
            self.monthInterval = self.monthInterval + 0.0004;
            break;
        }
    }
    
    [self reloadGraph];
    
}

- (void)scrollViewTap:(UITapGestureRecognizer *)tap
{
    CGPoint touchPoint = [tap locationInView:self.scrollView];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(lineGraph:didTapPointAtIndex:)] && (self.enableTouchReport == YES || self.enablePopUpReport == YES))
    {
        NSInteger index = [self indexForTouchPoint:touchPoint];
        if (index >= 0)
        {
            [_delegate lineGraph:self didTapPointAtIndex:index];
        }
        else if (yAxisValues.count == 1)
        {
            [_delegate lineGraph:self didTapPointAtIndex:0];
        }
    }
    else return;
    
}


- (NSInteger)indexForTouchPoint:(CGPoint)touchPoint
{
    
    for (int i = 0; i < yAxisValues.count-1; i += 1)
    {
        
        CGPoint p1 = CGPointMake([[xAxisValuePoints objectAtIndex:i] floatValue], [[yAxisValues objectAtIndex:i] floatValue]);
        CGPoint p2 = CGPointMake([[xAxisValuePoints objectAtIndex:i+1] floatValue], [[yAxisValues objectAtIndex:i+1] floatValue]);
        
        float distanceToP1 = fabsf(hypotf(touchPoint.x - p1.x, touchPoint.y - p1.y));
        float distanceToP2 = hypotf(touchPoint.x - p2.x, touchPoint.y - p2.y);
        
        float distance = MIN(distanceToP1, distanceToP2);
        if (distance <= 20.0) {
            return distance == distanceToP2 ? i+1 : i;
        }
    }
    return -1;
}

#pragma mark - Touch Gestures （For PanView, Never used in this project!)

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:self.panGesture]) {
        if (gestureRecognizer.numberOfTouches > 0) {
            CGPoint translation = [self.panGesture velocityInView:self.panView];
            return fabs(translation.y) < fabs(translation.x);
        } else return NO;
        return YES;
    } else return NO;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer locationInView:self.viewForBaselineLayout];
    
    if (!((translation.x + self.frame.origin.x) <= self.frame.origin.x) && !((translation.x + self.frame.origin.x) >= self.frame.origin.x + self.frame.size.width)) { // To make sure the vertical line doesn't go beyond the frame of the graph.
        self.touchInputLine.frame = CGRectMake(translation.x - self.widthTouchInputLine/2, 0, self.widthTouchInputLine, self.frame.size.height);
    }
    
    self.touchInputLine.alpha = self.alphaTouchInputLine;
    
    closestDot = [self closestDotFromtouchInputLine:self.touchInputLine];
    closestDot.alpha = 0.8;
    
    
    if (self.enablePopUpReport == YES && closestDot.tag > 99 && closestDot.tag < 1000 && [closestDot isKindOfClass:[BEMCircle class]] && self.alwaysDisplayPopUpLabels == NO) {
        [self setUpPopUpLabelAbovePoint:closestDot];
    }
    
    if (closestDot.tag > 99 && closestDot.tag < 1000 && [closestDot isMemberOfClass:[BEMCircle class]]) {
        if ([self.delegate respondsToSelector:@selector(lineGraph:didTouchGraphWithClosestIndex:)] && self.enableTouchReport == YES) {
            [self.delegate lineGraph:self didTouchGraphWithClosestIndex:((NSInteger)closestDot.tag - 100)];
            
        } else if ([self.delegate respondsToSelector:@selector(didTouchGraphWithClosestIndex:)] && self.enableTouchReport == YES) {
            [self printDeprecationWarningForOldMethod:@"didTouchGraphWithClosestIndex:" andReplacementMethod:@"lineGraph:didTouchGraphWithClosestIndex:"];
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [self.delegate didTouchGraphWithClosestIndex:((int)closestDot.tag - 100)];
#pragma clang diagnostic pop
        }
    }
    
    // ON RELEASE
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(lineGraph:didReleaseTouchFromGraphWithClosestIndex:)]) {
            [self.delegate lineGraph:self didReleaseTouchFromGraphWithClosestIndex:(closestDot.tag - 100)];
            
        } else if ([self.delegate respondsToSelector:@selector(didReleaseGraphWithClosestIndex:)]) {
            [self printDeprecationWarningForOldMethod:@"didReleaseGraphWithClosestIndex:" andReplacementMethod:@"lineGraph:didReleaseTouchFromGraphWithClosestIndex:"];
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [self.delegate didReleaseGraphWithClosestIndex:(closestDot.tag - 100)];
#pragma clang diagnostic pop
        }
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (self.alwaysDisplayDots == NO) {
                closestDot.alpha = 0;
            }
            self.touchInputLine.alpha = 0;
            if (self.enablePopUpReport == YES) {
                self.popUpView.alpha = 0;
                self.popUpLabel.alpha = 0;
            }
        } completion:nil];
    }
}

- (CGFloat)distanceToClosestPoint {
    return sqrt(pow(closestDot.center.x - self.touchInputLine.center.x, 2));
}

- (void)setUpPopUpLabelAbovePoint:(BEMCircle *)closestPoint {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.popUpView.alpha = 0.7;
        self.popUpLabel.alpha = 1;
    } completion:nil];
    
    self.xCenterLabel = closestDot.center.x;
    self.yCenterLabel = closestDot.center.y - closestDot.frame.size.height/2 - 15;
    self.popUpView.center = CGPointMake(self.xCenterLabel, self.yCenterLabel);
    self.popUpLabel.center = self.popUpView.center;
    
    if ([self.delegate respondsToSelector:@selector(popUpSuffixForlineGraph:)])
        self.popUpLabel.text = [NSString stringWithFormat:@"%li%@", (long)[[dataPoints objectAtIndex:((NSInteger)closestDot.tag - 100)] integerValue], [self.delegate popUpSuffixForlineGraph:self]];
    else
        self.popUpLabel.text = [NSString stringWithFormat:@"%li", (long)[[dataPoints objectAtIndex:((NSInteger)closestDot.tag - 100)] integerValue]];
    if (self.enableYAxisLabel == YES && self.popUpView.frame.origin.x <= self.YAxisLabelXOffset) {
        self.xCenterLabel = self.popUpView.frame.size.width/2;
        self.popUpView.center = CGPointMake(self.xCenterLabel + self.YAxisLabelXOffset + 1, self.yCenterLabel);
    }
    else if (self.popUpView.frame.origin.x <= 0) {
        self.xCenterLabel = self.popUpView.frame.size.width/2;
        self.popUpView.center = CGPointMake(self.xCenterLabel, self.yCenterLabel);
    } else if ((self.popUpView.frame.origin.x + self.popUpView.frame.size.width) >= self.frame.size.width) {
        self.xCenterLabel = self.frame.size.width - self.popUpView.frame.size.width/2;
        self.popUpView.center = CGPointMake(self.xCenterLabel, self.yCenterLabel);
    }
    if (self.popUpView.frame.origin.y <= 2) {
        self.yCenterLabel = closestDot.center.y + closestDot.frame.size.height/2 + 15;
        self.popUpView.center = CGPointMake(self.xCenterLabel, closestDot.center.y + closestDot.frame.size.height/2 + 15);
    }
    self.popUpLabel.center = self.popUpView.center;
}

#pragma mark - Graph Calculations

- (BEMCircle *)closestDotFromtouchInputLine:(UIView *)touchInputLine {
    currentlyCloser = pow((self.frame.size.width/(numberOfPoints-1))/2, 2);
    for (BEMCircle *point in self.subviews) {
        if (point.tag > 99 && point.tag < 1000 && [point isMemberOfClass:[BEMCircle class]]) {
            if (self.alwaysDisplayDots == NO) {
                point.alpha = 0;
            }
            if (pow(((point.center.x) - touchInputLine.center.x), 2) < currentlyCloser) {
                currentlyCloser = pow(((point.center.x) - touchInputLine.center.x), 2);
                closestDot = point;
            }
        }
    }
    return closestDot;
}

- (CGFloat)maxValue {
    if ([self.delegate respondsToSelector:@selector(maxValueForLineGraph:)]) {
        return [self.delegate maxValueForLineGraph:self];
    } else {
        CGFloat dotValue;
        CGFloat maxValue = -FLT_MAX;
        
        @autoreleasepool {
            for (int i = 0; i < numberOfPoints; i++) {
                if ([self.dataSource respondsToSelector:@selector(lineGraph:valueAndDotTypeForPointAtIndex:)]) {
                    NSDictionary *valueAndType = [self.dataSource lineGraph:self valueAndDotTypeForPointAtIndex:i];
                    NSNumber *value = [valueAndType valueForKey:@"value"];
                    dotValue = value.floatValue;
                    
                } else if ([self.delegate respondsToSelector:@selector(valueForIndex:)]) {
                    [self printDeprecationWarningForOldMethod:@"valueForIndex:" andReplacementMethod:@"lineGraph:valueForPointAtIndex:"];
                    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    dotValue = [self.delegate valueForIndex:i];
#pragma clang diagnostic pop
                    
                } else if ([self.delegate respondsToSelector:@selector(lineGraph:valueForPointAtIndex:)]) {
                    [self printDeprecationAndUnavailableWarningForOldMethod:@"lineGraph:valueForPointAtIndex:"];
                    NSException *exception = [NSException exceptionWithName:@"Implementing Unavailable Delegate Method" reason:@"lineGraph:valueForPointAtIndex: is no longer available on the delegate. It must be implemented on the data source." userInfo:nil];
                    [exception raise];
                    
                } else dotValue = 0;
                
                if (dotValue > maxValue) {
                    maxValue = dotValue;
                }
            }
        }
        return maxValue;
    }
}

- (CGFloat)minValue {
    if ([self.delegate respondsToSelector:@selector(minValueForLineGraph:)])
    {
        CGFloat minValue = [self.delegate minValueForLineGraph:self];
        return minValue;
    }
    else
    {
        CGFloat dotValue;
        CGFloat minValue = INFINITY;
        
        @autoreleasepool {
            for (int i = 0; i < numberOfPoints; i++) {
                if ([self.dataSource respondsToSelector:@selector(lineGraph:valueAndDotTypeForPointAtIndex:)]) {
                    NSDictionary *valueAndType = [self.dataSource lineGraph:self valueAndDotTypeForPointAtIndex:i];
                    NSNumber *value = [valueAndType valueForKey:@"value"];
                    dotValue = value.floatValue;
                    
                } else if ([self.delegate respondsToSelector:@selector(valueForIndex:)]) {
                    [self printDeprecationWarningForOldMethod:@"valueForIndex:" andReplacementMethod:@"lineGraph:valueForPointAtIndex:"];
                    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    dotValue = [self.delegate valueForIndex:i];
#pragma clang diagnostic pop
                    
                } else if ([self.delegate respondsToSelector:@selector(lineGraph:valueForPointAtIndex:)]) {
                    [self printDeprecationAndUnavailableWarningForOldMethod:@"lineGraph:valueForPointAtIndex:"];
                    NSException *exception = [NSException exceptionWithName:@"Implementing Unavailable Delegate Method" reason:@"lineGraph:valueForPointAtIndex: is no longer available on the delegate. It must be implemented on the data source." userInfo:nil];
                    [exception raise];
                    
                } else dotValue = 0;
                
                if (dotValue < minValue) {
                    minValue = dotValue;
                }
            }
        }
        return minValue;
    }
}

- (CGFloat)xPostionForDotDate:(NSDate *)dotDate
{
    NSTimeInterval secondInterval;
    CGFloat xPosition;
    switch (self.searchMode) {
        case GraphSearchModeByDay:
        {
            if (!self.dayInterval)
            {
                if ([self.dataSource respondsToSelector:@selector(intervalForSecondInLineGraph:)])
                {
                    self.dayInterval = [self.dataSource intervalForSecondInLineGraph:self];
                }
                else
                {
                    self.dayInterval = 1.0/60;
                }
            }
            
            secondInterval = self.dayInterval;
            
            
            NSTimeInterval interval = [dotDate timeIntervalSinceDate:currentDate];
            NSDate *date = [NSDate dateWithTimeInterval:interval sinceDate:currentDate];
            xPosition = secondInterval * interval;
            
            
            return xPosition;
        }
            break;
        default:
        {
            if (!self.monthInterval)
            {
                if ([self.dataSource respondsToSelector:@selector(intervalForSecondInLineGraph:)])
                {
                    self.monthInterval = [self.dataSource intervalForSecondInLineGraph:self];
                }
                else
                {
                    self.monthInterval = 0.0005;
                }
            }
            
            secondInterval = self.monthInterval;
            
            NSTimeZone *zone = [NSTimeZone systemTimeZone];
            NSInteger zoneInterval = [zone secondsFromGMTForDate:dotDate];
            NSDate *localDate = [dotDate dateByAddingTimeInterval:zoneInterval];
            
            NSTimeInterval interval = [localDate timeIntervalSinceDate:currentDate];
            
            xPosition = secondInterval * interval;
            
            return xPosition;
        }
            break;
            
    }
    
    
}

- (CGFloat)yPositionForDotValue:(CGFloat)dotValue {
    
    if (!self.yMaxValue) {
        self.yMaxValue = [self maxValue];
    }
    if (!self.minValue) {
        self.yMinValue = [self minValue];
    }
    
    CGFloat maxValue = [self maxValue]; // Biggest Y-axis value from all the points.
    
    CGFloat minValue = [self minValue]; // Smallest Y-axis value from all the points.
    
    CGFloat positionOnYAxis; // The position on the Y-axis of the point currently being created.
    CGFloat padding = self.frame.size.height/2;
    if (padding > 90.0)
    {
        padding = 90.0;
    }
    
    if([self.delegate respondsToSelector:@selector(staticPaddingForLineGraph:)])
        padding = [self.delegate staticPaddingForLineGraph:self];
    
    if (self.enableXAxisLabel)
    {
        //        if ([self.dataSource respondsToSelector:@selector(lineGraph:labelOnXAxisForIndex:)] || [self.dataSource respondsToSelector:@selector(labelOnXAxisForIndex:)]) {
        if ([xAxisLabels count] > 0) {
            UILabel *label = [xAxisLabels objectAtIndex:0];
            self.XAxisLabelYOffset = label.frame.size.height + self.widthLine;
        }
        //        }
    }
    
    if (minValue == maxValue && self.autoScaleYAxis == YES) positionOnYAxis = self.frame.size.height/2;
    else if (self.autoScaleYAxis == YES)
    {
        //把有效空间根据有效数值等份划分
        CGFloat validHeight = ((self.frame.size.height - padding) / (maxValue - minValue));
        //目标数值于有效空间的占有空间
        CGFloat valueHeight = ((dotValue - minValue) * validHeight);
        //目标高度于视图内的高度位置
        CGFloat height = ((self.frame.size.height - padding/2) - valueHeight);
        //减去底部的label高度
        positionOnYAxis =
        height + self.XAxisLabelYOffset/2;
    }
    else positionOnYAxis = ((self.frame.size.height) - dotValue);
    
    positionOnYAxis -= self.XAxisLabelYOffset;
    
    return positionOnYAxis;
}

#pragma mark - Customization Methods

- (void)setColorTouchInputLine:(UIColor *)colorTouchInputLine {
    self.touchInputLine.backgroundColor = colorTouchInputLine;
}

#pragma mark - Other Methods

- (void)printDeprecationAndUnavailableWarningForOldMethod:(NSString *)oldMethod {
    NSLog(@"[BEMSimpleLineGraph] UNAVAILABLE, DEPRECATION ERROR. The delegate method, %@, is both deprecated and unavailable. It is now a data source method. You must implement this method from BEMSimpleLineGraphDataSource. Update your delegate method as soon as possible. One of two things will now happen: A) an exception will be thrown, or B) the graph will not load.", oldMethod);
}

- (void)printDeprecationWarningForOldMethod:(NSString *)oldMethod andReplacementMethod:(NSString *)replacementMethod {
    NSLog(@"[BEMSimpleLineGraph] DEPRECATION WARNING. The delegate method, %@, is deprecated and will become unavailable in a future version. Use %@ instead. Update your delegate method as soon as possible. An exception will be thrown in a future version.", oldMethod, replacementMethod);
}

@end
