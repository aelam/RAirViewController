//
//  RSectionView.h
//  RAirViewControllerDemo
//
//  Created by Ryan Wang on 14-3-22.
//  Copyright (c) 2014年 Ryan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSectionView;

@protocol RSectionDataSource <NSObject>

@required
- (NSInteger)numberOfRowsInSectionView:(RSectionView *)section;
- (UITableViewCell *)sectionView:(RSectionView *)sectionView viewForRowAtRow:(NSInteger)row;
- (NSString *)titleForHeaderInSectionView:(RSectionView *)sectionView;

@optional
- (CGFloat)sectionView:(RSectionView *)sectionView heightForRow:(NSInteger)index;


@end

@protocol RSectionDelegate <NSObject>


@optional
- (void)sectionView:(RSectionView *)sectionView willSelectRowAtIndex:(NSInteger)index;
- (void)sectionView:(RSectionView *)sectionView didSelectRowAtIndex:(NSInteger)index;

@end



@interface RSectionView : UIView {
    NSMutableDictionary         *_reusableTableCells;
    NSMutableArray              *_visibleCells;
    NSInteger                   _highlightedRow;
    NSInteger                   _selectedRow;
    
    UITapGestureRecognizer      *_tap;
}

@property (nonatomic, assign, readonly) CGSize contentSize;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak) id<RSectionDataSource> dataSource;
@property (nonatomic, weak) id<RSectionDelegate> delegate;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong,readonly) UIButton *titleButton;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, strong) NSMutableDictionary *cells;

@property (nonatomic, assign) CGFloat translationX;
@property (nonatomic, assign) CGFloat translationY;
@property (nonatomic, assign) CGFloat rowHeight; // TODO


- (void)setTranslationX:(CGFloat)translationX animation:(BOOL)animation;

- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (void)reloadData;
//TODO
- (void)reloadData:(NSInteger)sectionIndex;


- (void)deselectRowAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)selectRowAtIndex:(NSInteger)index animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;


@end
