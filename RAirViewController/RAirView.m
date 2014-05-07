//
//  RAirView.m
//  RAirViewControllerDemo
//
//  Created by Ryan Wang on 14-3-25.
//  Copyright (c) 2014年 Ryan Wang. All rights reserved.
//

#import "RAirView.h"
#import "RAirMenuView.h"
#import "UIViewAdditions.h"
#import "UIView+AnchorPoint.h"

@interface RAirView () <RAirMenuDataSource, RAirMenuDelegate>

@end

@implementation RAirView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _menuWidth = 320;
    _menuRowHeight = 50;
    CGFloat _topHeight = 60;
    
    self.menuView = [[RAirMenuView alloc] initWithFrame:self.bounds];
    self.menuView.delegate = self;
    [self addSubview:self.menuView];

#if 0
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.image = [UIImage imageNamed:@"4"];
    [self addSubview:imageView];
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 40, 300, 30)];
    slider.maximumValue = 320;
    slider.minimumValue = 0;
    [slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:slider];
#endif
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    self.contentView.backgroundColor = [UIColor lightGrayColor];
    self.contentView.layer.borderWidth = 2;
    self.contentView.layer.borderColor = [UIColor redColor].CGColor;
    [self addSubview:self.contentView];
    
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, -_topHeight, CGRectGetWidth(self.bounds), _topHeight)];
    self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.topView.backgroundColor = [UIColor darkGrayColor];
    self.topView.layer.borderWidth = 2;
    self.topView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self addSubview:self.topView];
    

    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRevealGesture:)];
    [self addGestureRecognizer:_panGestureRecognizer];
    
    [self setupAnimations];
}

- (void)setDataSource:(id<RAirDataSource>)dataSource {
    _dataSource = dataSource;
    self.menuView.dataSource = self;
    
    [self setUpContent];
}

- (void)setUpContent {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:self.menuView.currentSection];
    UIViewController *controller = [self.menuView viewControllerForIndexPath:indexPath];
    
    [self setViewController:controller];
}


- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    return [self.menuView dequeueReusableCellWithIdentifier:identifier];
}

#pragma mark -
#pragma mark - DataSource 
- (NSInteger)numberOfSectionsInMenuView:(RAirMenuView *)menuView {
    NSInteger sections = [self.dataSource numberOfSectionsInAirView:self];
    return sections;
}

- (NSInteger)menuView:(RAirMenuView *)menuView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource airView:self numberOfRowsInSection:section];
}


- (CGFloat)menuView:(RAirMenuView *)menuView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _menuRowHeight;
}


- (UITableViewCell *)menuView:(RAirMenuView *)menuView viewForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource airView:self viewForRowAtIndexPath:indexPath];
}

- (UIViewController *)menuView:(RAirMenuView *)menuView viewControllerForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource airView:self viewControllerForRowAtIndexPath:indexPath];
}


- (NSString *)menuView:(RAirMenuView *)menuView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Section %ld", section];
}

- (void)menuView:(RAirMenuView *)menuView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark -
#pragma mark - Others
- (void)setViewController:(UIViewController *)controller {
    _viewController = controller;
//    [self.contentView addSubview:_viewController.view];
    
}

- (void)valueChanged:(UISlider *)slider {
    [self transformForContentView:slider.value animation:NO];
}

- (void) setupAnimations{
    return;
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 1.0 / -600;
    self.contentView.layer.sublayerTransform = rotationAndPerspectiveTransform;
    CGPoint anchorPoint = CGPointMake(1, 0.5);
    CGFloat newX = _viewController.view.width * anchorPoint.x;
    CGFloat newY = _viewController.view.height * anchorPoint.y;
    _viewController.view.layer.position = CGPointMake(newX, newY);
    _viewController.view.layer.anchorPoint = anchorPoint;

}

- (void)transformForMenuView:(CGFloat)distance animation:(BOOL)animation {
    [self.menuView setTranslationX:distance animation:animation];
}

- (void)transformForTopView:(CGFloat)distance animation:(BOOL)animation {
    if(animation) {
        [UIView animateWithDuration:0.2 animations:^{
            self.topView.bottom =  (fabsf(distance) / _menuWidth) * self.topView.height;
        }];
    } else {
        self.topView.bottom =  (fabsf(distance) / _menuWidth) * self.topView.height;
    }
}




- (void)transformForContentView:(CGFloat)distance animation:(BOOL)animation{
    CGFloat distanceThreshold = 320;
    CGFloat coverAngle = -55.0 / 180.0 * M_PI;
    CGFloat perspective = -1.0/1150;  // fixed

    CGFloat coverScale = 0.5;       // fixed
//    CGFloat zPosition = 1000.0;     // ?
    CGFloat percentage = fabsf(distance)/distanceThreshold;

    [self.contentView setAnchorPoint:CGPointMake(0, 0.5)];
    self.contentView.layer.anchorPointZ = 0.f;
    NSLog(@"percentage : %f",percentage);
//    self.contentView.layer.zPosition = zPosition;
    if (NO) {
        self.contentView.layer.transform = [self
                                            transform3DWithRotation:percentage * coverAngle
                                            scale:(1 - percentage) * (1 - coverScale) + coverScale
                                            translationX:distance
                                            perspective:perspective
                                            ];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.contentView.layer.transform = [self
                                                transform3DWithRotation:percentage * coverAngle
                                                scale:(1 - percentage) * (1 - coverScale) + coverScale
                                                translationX:distance
                                                perspective:perspective
                                                ];
        }];
    }

}

- (CATransform3D)transform3DWithRotation:(CGFloat)angle
                                   scale:(CGFloat)scale
                             translationX:(CGFloat)tranlationX
                             perspective:(CGFloat)perspective {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = perspective;
    transform = CATransform3DTranslate(transform, tranlationX * 280.0 / 320.0 , 0, 0);
    transform = CATransform3DScale(transform, scale, scale, 1.0);
    transform = CATransform3DRotate(transform, angle, 0.0, 1.0, 0.0);

    return transform;
    
}

- (void)handleRevealGesture:(UIPanGestureRecognizer *)recognizer
{
    switch ( recognizer.state )
    {
        case UIGestureRecognizerStateBegan:
            [self handleRevealGestureStateBeganWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateChanged:
            [self handleRevealGestureStateChangedWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateEnded:
            [self handleRevealGestureStateEndedWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateCancelled:
            [self handleRevealGestureStateCancelledWithRecognizer:recognizer];
            break;
        default:
            break;
    }
}

- (void)handleRevealGestureStateBeganWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
}

- (void)handleRevealGestureStateChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self];
    if(!_menuOpened && translation.x <= 0 ){
        return;
    }
    [self transformForContentView:translation.x + _translationX animation:NO];
    [self transformForMenuView:translation.x + _translationX animation:NO];
    [self transformForTopView:translation.x + _translationX animation:NO];
}

- (void)handleRevealGestureStateEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self];
    CGFloat threshold = 150;
    NSLog(@"translation.x = %f",translation.x);
    if(translation.x > threshold) {
        // open menu
        [self openMenu:YES];
    } else if (translation.x < 0) {
        // close menu
        [self closeMenu:YES];
    } else {
        [self closeMenu:YES];
    }
}

- (void)handleRevealGestureStateCancelledWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
}



- (void)closeMenu:(BOOL)animation {
    _menuOpened = NO;
    _translationX = 0;
    [self transformForContentView:0 animation:animation];
    [self transformForMenuView:0 animation:animation];
    [self transformForTopView:0 animation:animation];

}

- (void)openMenu:(BOOL)animation {
    _translationX = 320;
    _menuOpened = YES;
    [self transformForContentView:_translationX animation:animation];
    [self transformForMenuView:_translationX animation:animation];
    [self transformForTopView:_translationX animation:animation];
}


@end
