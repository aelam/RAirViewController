//
//  RAirViewController.m
//  RAirViewController
//
//  Created by Ryan Wang on 14-3-20.
//  Copyright (c) 2014年 Ryan Wang. All rights reserved.
//

#import "RAirViewController.h"
#import "RAirMenuView.h"
#import "UIViewAdditions.h"
#import "UIView+AnchorPoint.h"

@interface RAirViewController () <RAirMenuDataSource, RAirMenuDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *rightCloseButton;

@end

@implementation RAirViewController {
    UIPanGestureRecognizer      *_panGestureRecognizer;
    CGFloat                     _menuWidth;
    NSMutableDictionary         *_viewControllersMap;
    
    BOOL                        _menuOpened;
    CGFloat                     _translationX;

    BOOL                        _draggingHorizonal;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ([self initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void)viewDidLoad {
    
    _menuWidth = 320;
    _menuRowHeight = 50;
    CGFloat _topHeight = 60;
    
    self.menuView = [[RAirMenuView alloc] initWithFrame:self.view.bounds];
    self.menuView.delegate = self;
    self.menuView.dataSource = self;
    [self.view addSubview:self.menuView];
    
    _rightCloseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_rightCloseButton setTitle:@"Close" forState:UIControlStateNormal];
    _rightCloseButton.frame = CGRectMake(self.view.bounds.size.width - 70, 0, 70, self.view.bounds.size.height);
    _rightCloseButton.layer.borderColor = [UIColor yellowColor].CGColor;
    _rightCloseButton.layer.borderWidth = 3;
    [self.view addSubview:_rightCloseButton];

    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    self.contentView.backgroundColor = [UIColor lightGrayColor];
    self.contentView.layer.borderWidth = 2;
    self.contentView.layer.borderColor = [UIColor redColor].CGColor;
    [self.view addSubview:self.contentView];
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, -_topHeight, CGRectGetWidth(self.view.bounds), _topHeight)];
    self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.topView.backgroundColor = [UIColor darkGrayColor];
    self.topView.layer.borderWidth = 2;
    self.topView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:self.topView];
    
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRevealGesture:)];
    _panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_panGestureRecognizer];
    
//    [self setupAnimations];

}


#pragma mark - menu dataSource (Test Data)
- (NSInteger)numberOfSectionsInMenuView:(RAirMenuView *)menuView {
    return 4;
}

- (NSInteger)menuView:(RAirMenuView *)menuView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)menuView:(RAirMenuView *)menuView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _menuRowHeight;
}

- (UITableViewCell *)menuView:(RAirMenuView *)menuView viewForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [menuView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld %ld", (long)indexPath.section , (long)indexPath.row];
    
    return cell;
}

- (NSString *)menuView:(RAirMenuView *)menuView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Section %ld", (long)section];
}



#pragma mark - 
#pragma mark - Drag and animations
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
    CGFloat distanceThreshold = 280.f;
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


- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:self.view];

    _draggingHorizonal = fabs(translation.y) < fabs(translation.x);
//    return fabs(translation.y) > fabs(translation.x);
    return YES;
}


- (void)handleRevealGesture:(UIPanGestureRecognizer *)recognizer
{
    if (_draggingHorizonal) {
        switch ( recognizer.state)
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
    } else {
        CGPoint point = [recognizer locationInView:self.view];
        if (CGRectContainsPoint(self.contentView.frame, point)) {
            NSLog(@"point: %@", NSStringFromCGPoint(point));
            NSLog(@"rect : %@", NSStringFromCGRect(self.contentView.frame));
        } else {
            [self.menuView handleRevealGesture:recognizer];
        }
//         [self.menuView.frame ]
    }
}

- (void)handleRevealGestureStateBeganWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
}

- (void)handleRevealGestureStateChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    if(!_menuOpened && translation.x <= 0 ){
        return;
    }
    [self transformForContentView:translation.x + _translationX animation:NO];
    [self transformForMenuView:translation.x + _translationX animation:NO];
    [self transformForTopView:translation.x + _translationX animation:NO];
}

- (void)handleRevealGestureStateEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
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
