//
//  RAirView.h
//  RAirViewControllerDemo
//
//  Created by Ryan Wang on 14-3-25.
//  Copyright (c) 2014年 Ryan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RAirMenuView;
@class RAirView;

@protocol RAirDataSource <NSObject>

@required
- (NSInteger)numberOfSectionsInAirView:(RAirView *)airView;
- (NSInteger)airView:(RAirView *)airView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)airView:(RAirView *)airView viewForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)airView:(RAirView *)airView titleForHeaderInSection:(NSInteger)section;
- (UIViewController *)airView:(RAirView *)airView viewControllerForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional

@end

__deprecated
@interface RAirView : UIView {
    UIPanGestureRecognizer      *_panGestureRecognizer;
    CGFloat                     _menuWidth;
    NSMutableDictionary         *_viewControllersMap;
    
    BOOL                        _menuOpened;
    CGFloat                     _translationX;
}

@property (nonatomic, strong) RAirMenuView *menuView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, weak)  id <RAirDataSource>dataSource;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, assign) CGFloat menuRowHeight;

- (BOOL)isMenuOpened;
- (void)reloadData;

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end
