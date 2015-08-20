//
//  YALSunyRefreshControl.m
//  YALSunyPullToRefresh
//
//  Created by Konstantin Safronov on 12/24/14.
//  Copyright (c) 2014 Konstantin Safronov. All rights reserved.
//

#import "YALSunnyRefreshControl.h"

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

static const CGFloat DefaultHeight = 100.f;
static const CGFloat AnimationDuration = 0.25f;
//static const CGFloat AnimationDamping = 0.4f;
//static const CGFloat AnimationVelosity= 0.8f;

static const CGFloat SunTopPoint = 5.f;
static const CGFloat SunBottomPoint = 55.f;
static const CGFloat SkyTopShift = 15.f;
static const CGFloat SkyDefaultShift = -70.f;

static const CGFloat BuildingDefaultHeight = 72;

static const CGFloat CircleAngle = 360.f;
static const CGFloat BuildingsMaximumScale = 1.7f;
static const CGFloat SunAndSkyMinimumScale = 0.85f;
static const CGFloat SpringTreshold = 120.f;
static const CGFloat SkyTransformAnimationDuration = 0.5f;
static const CGFloat SunRotationAnimationDuration = 0.9f;
static const CGFloat DefaultScreenWidth = 320.f;

@interface YALSunnyRefreshControl ()<UIScrollViewDelegate>

@property (nonatomic,weak) IBOutlet NSLayoutConstraint *sunTopConstraint;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *skyTopConstraint;

@property (nonatomic,weak) IBOutlet NSLayoutConstraint *skyLeadingConstraint;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *skyTrailingConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buildingsHeightConstraint;

@property (nonatomic,weak) IBOutlet UIImageView *sunImageView;
@property (nonatomic,weak) IBOutlet UIImageView *skyImageView;
@property (nonatomic,weak) IBOutlet UIImageView *buildingsImageView;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic) CGFloat scrollViewInitialOffsetY;
@property (nonatomic) CGFloat scrollViewInitialInsetTop;
@property (nonatomic,assign) BOOL wasLoading;
@property (nonatomic,assign) BOOL isEndScrolling;
@property (nonatomic,assign) BOOL forbidSunSet;
@property (nonatomic,assign) BOOL isSunRotating;
@property (nonatomic,assign) BOOL forbidOffsetChanges;

@end

@implementation YALSunnyRefreshControl

-(void)dealloc{
    
    [self removeObserver:self.scrollView forKeyPath:@"contentOffset"];
}

+ (YALSunnyRefreshControl*)attachToScrollView:(UIScrollView *)scrollView{
    
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"YALSunnyRefreshControl" owner:self options:nil];
    YALSunnyRefreshControl *refreshControl = (YALSunnyRefreshControl *)[topLevelObjects firstObject];
    
    refreshControl.scrollView = scrollView;
    [refreshControl.scrollView addObserver:refreshControl forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [refreshControl setFrame:CGRectMake(0.f,
                                        0.f,
                                        scrollView.frame.size.width,
                                        0.f)];
    [scrollView addSubview:refreshControl];
    
    return refreshControl;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit
{
    self.wasLoading = NO;
    self.isEndScrolling = NO;
    self.scrollViewInitialOffsetY = -1;
    CGFloat leadingRatio = [UIScreen mainScreen].bounds.size.width / DefaultScreenWidth;
    [self.skyLeadingConstraint setConstant:self.skyLeadingConstraint.constant * leadingRatio];
    [self.skyTrailingConstraint setConstant:self.skyTrailingConstraint.constant * leadingRatio];
    
    __weak YALSunnyRefreshControl* weakSelf = self;
    self.scrollViewDidEndScrollBlock = ^(void){
        if(weakSelf.forbidOffsetChanges){
            weakSelf.isEndScrolling = YES;
            [weakSelf.scrollView setContentInset:UIEdgeInsetsMake(weakSelf.scrollViewInitialInsetTop+DefaultHeight, 0.f, 0.f, 0.f)];
        }
    };
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    [self calculateShift];
}

-(void)calculateShift{

    [self setFrame:CGRectMake(0.f,
                              0.f,
                              self.scrollView.frame.size.width,
                              self.scrollView.contentOffset.y-self.scrollViewInitialOffsetY)];
    
    if(self.scrollView.contentOffset.y <= self.scrollViewInitialOffsetY-DefaultHeight){
        
        [self rotateSunInfinitly];
        [self scaleItems];
        
        if(self.scrollView.contentOffset.y < self.scrollViewInitialOffsetY-SpringTreshold){
            
            [self.scrollView setContentOffset:CGPointMake(0.f, self.scrollViewInitialOffsetY -SpringTreshold)];
        }

        
        if(!self.scrollView.dragging && self.forbidSunSet && self.scrollView.decelerating && !self.forbidOffsetChanges ){
            [self startRefreshing];
        }
        
        if (!self.wasLoading && self.isEndScrolling) {

            id<YALSunnyRefreshControlDelegate>delegate = self.delegate;
            if ([delegate respondsToSelector:@selector(YALRefreshViewDidStartLoading:)]) {
                [delegate YALRefreshViewDidStartLoading:self];
            }

            self.wasLoading = YES;
            self.isEndScrolling = NO;
        }
        
        self.forbidSunSet = YES;
    }
    
    if(!self.forbidSunSet){
        [self setupSunHeightAboveHorisont];
        [self setupSkyPosition];
    }

}

- (void)startRefreshing {
    if (self.scrollViewInitialOffsetY == -1) {
        self.scrollViewInitialOffsetY = self.scrollView.contentOffset.y;
        self.scrollViewInitialInsetTop = self.scrollView.contentInset.top;
    }
    CGPoint offset = CGPointMake(0.f, self.scrollViewInitialOffsetY + -DefaultHeight);
    
    [self.scrollView setContentOffset:offset animated:YES];
    self.forbidOffsetChanges = YES;
}

-(void)endRefreshing{
    
    self.forbidOffsetChanges = NO;
    
    [UIView animateWithDuration:AnimationDuration animations:^{
         [self.scrollView setContentInset:UIEdgeInsetsMake(self.scrollViewInitialInsetTop, 0.f, 0.f, 0.f)];
    } completion:^(BOOL finished) {
        if (finished) {
            self.forbidSunSet = NO;
            self.wasLoading = NO;
            [self stopSunRotating];
        }
    }];
    
}

-(void)setupSunHeightAboveHorisont{
    
    CGFloat shiftInPercents = [self shiftInPercents];
    CGFloat sunWay = SunBottomPoint - SunTopPoint;
    CGFloat sunYCoordinate = SunBottomPoint - (sunWay / 100) * shiftInPercents;

    [self.sunTopConstraint setConstant:sunYCoordinate];
    
    CGFloat rotationAngle = (CircleAngle / 100) * shiftInPercents;
    self.sunImageView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(rotationAngle));
}

-(CGFloat)shiftInPercents{
    
    return (DefaultHeight / 100) * (-self.scrollView.contentOffset.y+self.scrollViewInitialOffsetY);
}

-(void)setupSkyPosition{
    
    CGFloat shiftInPercents = [self shiftInPercents];
    CGFloat skyTopConstant = SkyDefaultShift + ((SkyTopShift / 100) * shiftInPercents);
    [self.skyTopConstraint setConstant:skyTopConstant];
}

-(void)scaleItems{
    
    CGFloat shiftInPercents = [self shiftInPercents];
    CGFloat buildigsScaleRatio = shiftInPercents / 100;
    
    if(buildigsScaleRatio <= BuildingsMaximumScale){
        
        CGFloat extraOffset = ABS(self.scrollView.contentOffset.y-self.scrollViewInitialOffsetY) - DefaultHeight;
        self.buildingsHeightConstraint.constant = BuildingDefaultHeight + extraOffset;
        [self.buildingsImageView setTransform:CGAffineTransformMakeScale(buildigsScaleRatio,1.f)];
        
        CGFloat skyScale = (SunAndSkyMinimumScale + (1 - buildigsScaleRatio));
        [UIView animateWithDuration:SkyTransformAnimationDuration animations:^{
            
            [self.skyImageView setTransform:CGAffineTransformMakeScale(skyScale,skyScale)];
            [self.sunImageView setTransform:CGAffineTransformMakeScale(skyScale,skyScale)];
        }];
    }
}

- (void)rotateSunInfinitly{
    
    if(!self.isSunRotating){
        self.isSunRotating = YES;
        self.forbidSunSet = YES;
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = @(M_PI * 2.0);
        rotationAnimation.duration = SunRotationAnimationDuration;
        rotationAnimation.autoreverses = NO;
        rotationAnimation.repeatCount = HUGE_VALF;
        rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [self.sunImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
}

-(void)stopSunRotating{
    
    if (!self.wasLoading) {
        self.isSunRotating = NO;
        self.forbidSunSet = NO;
        [self.sunImageView.layer removeAnimationForKey:@"rotationAnimation"];
    }

}

@end