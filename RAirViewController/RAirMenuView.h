//
//  RAirMenuView.h
//  RAirViewControllerDemo
//
//  Created by Ryan Wang on 14-3-22.
//  Copyright (c) 2014年 Ryan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSectionView.h"

@class RAirMenuView;

@protocol RAirMenuDataSource <NSObject>

@required
- (NSInteger)numberOfSectionsInMenuView:(RAirMenuView *)menuView;
- (NSInteger)menuView:(RAirMenuView *)menuView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)menuView:(RAirMenuView *)menuView viewForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)menuView:(RAirMenuView *)menuView titleForHeaderInSection:(NSInteger)section;
//- (UIViewController *)menuView:(RAirMenuView *)menuView viewControllerForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (CGFloat)menuView:(RAirMenuView *)menuView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)menuView:(RAirMenuView *)menuView willDisplaySectionView:(NSInteger)sectionView forSection:(NSInteger)section;


@end

@protocol RAirMenuDelegate <NSObject>

@optional
- (void)menuView:(RAirMenuView *)menuView willDisplaySection:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)menuView:(RAirMenuView *)menuView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)menuView:(RAirMenuView *)menuView didScrollRate:(CGFloat)rate;

- (void)menuView:(RAirMenuView *)menuView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;


@end

@interface RAirMenuView : UIView {

@protected
    RSectionView                *_sectionView;
    RSectionView                *_topSectionView;
    RSectionView                *_bottomSectionView;

}

@property (nonatomic, weak) id <RAirMenuDataSource> dataSource;
@property (nonatomic, weak) id <RAirMenuDelegate> delegate;
//@property (nonatomic, strong) UIButton *closeButton; // {0,0},{70,568}
@property (nonatomic, assign) NSInteger currentSection;
@property (nonatomic, assign) CGFloat translationX;
@property (nonatomic, assign) CGFloat translationY;
@property (nonatomic, assign) UIEdgeInsets contentInsets;

- (void)setTranslationX:(CGFloat)translationX animation:(BOOL)animation;
- (void)handleRevealGesture:(UIPanGestureRecognizer *)recognizer;

- (IBAction)gotoNextPage:(id)sender;
- (IBAction)gotoPrevPage:(id)sender;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

- (void)reloadData;

- (UIViewController *)viewControllerForIndexPath:(NSIndexPath *)indexPath;


- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;


@end
