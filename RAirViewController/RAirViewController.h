//
//  RAirViewController.h
//  RAirViewController
//
//  Created by Ryan Wang on 14-3-20.
//  Copyright (c) 2014年 Ryan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RAirMenuView.h"

@class RAirViewController;

@protocol RAirViewControllerDataSource
@optional
- (NSInteger)numberOfSectionsInAirMenuViewController:(RAirViewController *)controller;

@required
- (UITableViewCell *)airViewController:(RAirViewController *)controller viewForRowAtIndexPath:(NSIndexPath *)indexPath;

// TODO
- (NSString *)airViewController:(RAirViewController *)controller titleForHeaderInSection:(NSInteger)section;
- (UIView *)airViewController:(RAirViewController *)controller titleViewForHeaderInSection:(NSInteger)section;
@end


@protocol RAirViewControllerDelegate

- (void)airViewController:(RAirViewController *)controller didSelectIndexPath:(NSIndexPath *)indexPath;

@end


@interface RAirViewController : UIViewController

//TODO
@property (nonatomic, weak) id<RAirViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<RAirViewControllerDelegate> delegate;

@property (nonatomic, strong) RAirMenuView *menuView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) NSArray *selectedIndexPaths;
@property (nonatomic, assign) UIViewController *selectedController;
@property (nonatomic, assign) CGFloat menuRowHeight;

@end
