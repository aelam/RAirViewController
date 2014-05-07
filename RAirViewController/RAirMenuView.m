//
//  RAirMenuView.m
//  RAirViewControllerDemo
//
//  Created by Ryan Wang on 14-3-22.
//  Copyright (c) 2014年 Ryan Wang. All rights reserved.
//

#import "RAirMenuView.h"
#import "UIViewAdditions.h"

@interface RAirMenuView() <UIGestureRecognizerDelegate, RSectionDataSource, RSectionDelegate>

@end

@implementation RAirMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [self commonInit];
}

- (void)setUpDefaults {
    _contentInsets = UIEdgeInsetsMake(0, 0, 70, 70);
    self.layer.borderWidth = 1;
    self.layer.borderColor =[UIColor yellowColor].CGColor;

}

- (void)commonInit {
    [self setUpDefaults];
    
    CGRect sectionRect = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);
    
    _sectionView = [[RSectionView alloc] initWithFrame:sectionRect];
    _sectionView.title = @"Center";
    _sectionView.dataSource = self;
    _sectionView.delegate = self;
    [_sectionView.titleButton addTarget:self action:@selector(gotoNextPage:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_sectionView];
    
    CGRect topSectionRect = sectionRect;
    topSectionRect.origin.y = sectionRect.origin.y - sectionRect.size.height;
    _topSectionView = [[RSectionView alloc] initWithFrame:topSectionRect];
    _topSectionView.title = @"top";
    _topSectionView.dataSource = self;
    _topSectionView.delegate = self;
    [self addSubview:_topSectionView];
    [_topSectionView.titleButton addTarget:self action:@selector(gotoNextPage:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect bottomSectionRect = sectionRect;
    bottomSectionRect.origin.y = sectionRect.origin.y + sectionRect.size.height;
    _bottomSectionView = [[RSectionView alloc] initWithFrame:bottomSectionRect];
    _bottomSectionView.title = @"bottom";
    _bottomSectionView.dataSource = self;
    _bottomSectionView.delegate = self;

    [_bottomSectionView.titleButton addTarget:self action:@selector(gotoNextPage:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:_bottomSectionView];
    
#if 0
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRevealGesture:)];
    _panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_panGestureRecognizer];
#endif
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    if(UIEdgeInsetsEqualToEdgeInsets(contentInsets, _contentInsets)) {
        return;
    }
    _contentInsets = contentInsets;
    [self setNeedsLayout];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect sectionRect = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);
    _sectionView.frame = sectionRect;

    CGRect topSectionRect = sectionRect;
    topSectionRect.origin.y = sectionRect.origin.y - sectionRect.size.height;
    _topSectionView.frame = topSectionRect;

    CGRect bottomSectionRect = sectionRect;
    bottomSectionRect.origin.y = sectionRect.origin.y + sectionRect.size.height;
    _bottomSectionView.frame = bottomSectionRect;

}


#pragma mark - Gesture

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
    CGFloat translation = [recognizer translationInView:self].y;
    
    [self dragging:translation];
    
    
}

- (CGFloat)sessionHeight {
//    return self.height - _topPadding - _bottomPadding;
    return self.height - self.contentInsets.top - self.contentInsets.bottom;
}

- (void)handleRevealGestureStateEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{

    CGFloat sessionHeight = _sectionView.height;
    CGFloat translation = [recognizer translationInView:self].y;
    CGFloat velocityInViewY = [recognizer velocityInView:self].y;
    NSLog(@"velocityInViewY : %f",velocityInViewY);
    if (translation <= -sessionHeight * 0.5 || velocityInViewY < -1000) {
        // move up a session
        [self moveUp];
    } else if (translation >= sessionHeight * 0.5  || velocityInViewY > 1000) {
        // move down a session
        [self moveDown];
    } else if (translation > -sessionHeight * 0.5 && translation < sessionHeight * 0.5) {
        // not change session, just animation
        [self moveBack];
    }
}

- (void)handleRevealGestureStateCancelledWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
}

- (IBAction)gotoNextPage:(id)sender {
    [self moveDown];
}

- (IBAction)gotoPrevPage:(id)sender {
    [self moveUp];
}

- (void)dragging:(CGFloat)translation {
    CGFloat sessionHeight = [self sessionHeight];

    if (translation > 0) {
        // move up
        
    } else {
        // move down
    }
    
    _topSectionView.top = translation - sessionHeight;
    _bottomSectionView.top = translation + sessionHeight;
    _sectionView.top = translation;
    
    _sectionView.translationY = translation;
    _topSectionView.translationY = sessionHeight - fabs(translation);
    _bottomSectionView.translationY = sessionHeight - fabs(translation);
    

}

- (void)moveDown {
    CGFloat sessionHeight = _sectionView.height;
    
    RSectionView *tempView = _topSectionView;
    _topSectionView = _bottomSectionView;
    _bottomSectionView = _sectionView;
    _sectionView = tempView;
    _topSectionView.top = -sessionHeight;

    [self changeSection:-1];

    [UIView animateWithDuration:0.4 animations:^{
        _sectionView.top = 0;
        _bottomSectionView.top = sessionHeight;

        _sectionView.translationY = 0;
        _topSectionView.translationY = sessionHeight;
        _bottomSectionView.translationY = sessionHeight;
        
    } completion:^(BOOL finished) {
        
        [_topSectionView reloadData];
        [self setSectionTitles];
    }];
}

- (void)moveUp {
    CGFloat sessionHeight = _sectionView.height;
    
    RSectionView *tempView = _topSectionView;
    _topSectionView = _sectionView;
    _sectionView = _bottomSectionView;
    _bottomSectionView = tempView;
    _bottomSectionView.top = sessionHeight;

    [self changeSection:1];
    [_bottomSectionView reloadData];

    [UIView animateWithDuration:0.2 animations:^{
        _sectionView.top = 0;
        _topSectionView.top = -sessionHeight;
        
        _sectionView.translationY = 0;
        _bottomSectionView.translationY = sessionHeight;

    } completion:^(BOOL finished) {

        _topSectionView.translationY = sessionHeight;

        [self setSectionTitles];


    }];
}

- (void)moveBack {
    CGFloat sessionHeight = _sectionView.height;
    [UIView animateWithDuration:0.2 animations:^{
        _topSectionView.top = -sessionHeight;
        _sectionView.top = 0;
        _bottomSectionView.top = sessionHeight;
        
        _topSectionView.translationY = sessionHeight;
        _sectionView.translationY = 0;
        _bottomSectionView.translationY = sessionHeight;

    } completion:^(BOOL finished) {
        [self setSectionTitles];
    }];
}


- (void)setSectionTitles {
    if (_dataSource == nil) {
        return;
    }
    
    NSInteger numberOfSections = [_dataSource numberOfSectionsInMenuView:self];

    if (numberOfSections <= 0) {
        return;
    }
    
    NSString *title = [_dataSource menuView:self titleForHeaderInSection:_currentSection];
    _sectionView.title = title;
    
    title = [_dataSource menuView:self titleForHeaderInSection:(_currentSection - 1 + numberOfSections) % numberOfSections];
    _topSectionView.title = title;

    title = [_dataSource menuView:self titleForHeaderInSection:(_currentSection + 1 + numberOfSections) % numberOfSections];
    _bottomSectionView.title = title;
    
}

- (NSInteger)numberOfSections {
    return [_dataSource numberOfSectionsInMenuView:self];
}

- (void)setDataSource:(id<RAirMenuDataSource>)dataSource {
    _dataSource = dataSource;
    if (_dataSource == nil) {
        return;
    }
    
    NSInteger numberOfSections = [_dataSource numberOfSectionsInMenuView:self];
    if (numberOfSections <= 0) {
        return;
    }
    
    [self reloadData];
}

- (void)changeSection:(NSInteger)nextOrPrev {
    _currentSection += nextOrPrev;
    NSInteger numberOfSections = [_dataSource numberOfSectionsInMenuView:self];
    _currentSection = (_currentSection + numberOfSections) % numberOfSections;
}

- (void)reloadData {
    if (_dataSource == nil) {
        return;
    }

    [self setSectionTitles];
    [_topSectionView reloadData];
    [_sectionView reloadData];
    [_bottomSectionView reloadData];
}

- (void)setTranslationX:(CGFloat)x animation:(BOOL)animation{
    _translationX = x;
    [_sectionView setTranslationX:x animation:animation];
    [_topSectionView setTranslationX:x animation:animation];
    [_bottomSectionView setTranslationX:x animation:animation];
}

- (CATransform3D)transform3DWithRotation:(CGFloat)angle
                                   scale:(CGFloat)scale
                            translationX:(CGFloat)tranlationX
                             perspective:(CGFloat)perspective {
    NSLog(@"---> scale: %f angle : %f", scale, angle);
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = perspective;
    transform = CATransform3DScale(transform, scale, scale, 1.0);
    transform = CATransform3DRotate(transform, angle, 0.0, 1.0, 0.0);
    transform = CATransform3DTranslate(transform, tranlationX * 1.5 , 0, 0);
    
    return transform;
    
}



#pragma mark - 
#pragma mark - DataSource
- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
	if(!identifier) return nil;
    
    UITableViewCell* aTableViewCell;
    
    aTableViewCell = [_topSectionView dequeueReusableCellWithIdentifier:identifier];
    if(aTableViewCell == nil)
        aTableViewCell = [_sectionView dequeueReusableCellWithIdentifier:identifier];
    if(aTableViewCell == nil)
        aTableViewCell = [_bottomSectionView dequeueReusableCellWithIdentifier:identifier];

	if(!aTableViewCell) return nil;
    
	return aTableViewCell;
}



- (NSInteger)numberOfRowsInSectionView:(RSectionView *)sectionView {
    if(_dataSource == nil) {
        return 0;
    }
    
    NSInteger numberOfRows;
    NSInteger sectionIndex = [self sectionIndexForSectionView:sectionView];
    numberOfRows = [_dataSource menuView:self numberOfRowsInSection:sectionIndex];
    
    return numberOfRows;
}

- (UITableViewCell *)sectionView:(RSectionView *)sectionView viewForRowAtRow:(NSInteger)row {
    if(_dataSource == nil) {
        return nil;
    }
    NSInteger sectionIndex = [self sectionIndexForSectionView:sectionView];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:sectionIndex];
    return [_dataSource menuView:self viewForRowAtIndexPath:indexPath];
}

- (CGFloat)sectionView:(RSectionView *)sectionView heightForRow:(NSInteger)row {
    NSInteger sectionIndex = [self sectionIndexForSectionView:sectionView];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:sectionIndex];
    
    return [_dataSource menuView:self heightForRowAtIndexPath:indexPath];
}

- (NSString *)titleForHeaderInSectionView:(RSectionView *)sectionView {
    NSInteger sectionIndex = [self sectionIndexForSectionView:sectionView];
    return [_dataSource menuView:self titleForHeaderInSection:sectionIndex];
}

- (NSInteger)sectionIndexForSectionView:(RSectionView *)sectionView {
    NSInteger sectionCount = [_dataSource numberOfSectionsInMenuView:self];
    if (sectionCount <= 0) {
        return 0;
    }
    
    NSInteger sectionIndex = 0;
    if (sectionView == _topSectionView) {
        sectionIndex = (self.currentSection + sectionCount - 1) % sectionCount;
    } else if (sectionView == _sectionView) {
        sectionIndex = (self.currentSection + sectionCount) % sectionCount;
    } else if (sectionView == _bottomSectionView) {
        sectionIndex = (self.currentSection + sectionCount + 1) % sectionCount;
    }
    return sectionIndex;
}


- (NSString *)sectionView:(RSectionView *)sectionView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"section : %d", section];
}

//- (UIViewController *)viewControllerForIndexPath:(NSIndexPath *)indexPath {
//    if ([_dataSource respondsToSelector:@selector(menuView:viewControllerForRowAtIndexPath:)]) {
//        return [_dataSource menuView:self viewControllerForRowAtIndexPath:indexPath];
//    }
//    return nil;
//}

- (void)sectionView:(RSectionView *)sectionView willSelectRowAtIndex:(NSInteger)index {
//    NSInteger sectionIndex = [self sectionIndexForSectionView:sectionView];
}

- (void)sectionView:(RSectionView *)sectionView didSelectRowAtIndex:(NSInteger)index {
    NSInteger sectionIndex = [self sectionIndexForSectionView:sectionView];
    
    if ([_delegate respondsToSelector:@selector(menuView:didSelectRowAtIndexPath:)]) {
        [_delegate menuView:self didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:sectionIndex]];
    }
}






@end
