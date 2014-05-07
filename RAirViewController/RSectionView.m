//
//  RSectionView.m
//  RAirViewControllerDemo
//
//  Created by Ryan Wang on 14-3-22.
//  Copyright (c) 2014年 Ryan Wang. All rights reserved.
//

#import "RSectionView.h"
#import "UIViewAdditions.h"
#import "UIView+AnchorPoint.h"

@interface RSectionView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) CGSize contentSize;

- (void)queueReusableCell:(UITableViewCell*)aTableViewCell;

@end

@implementation RSectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}


- (void)commonInit {
    _reusableTableCells = [NSMutableDictionary dictionary];
    _visibleCells = [NSMutableArray array];
    
    NSArray *colors = @[[UIColor redColor],[UIColor purpleColor], [UIColor greenColor]];
    
    UIColor *color = colors[rand() % 3];
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = 3;
    self.contentView = [[UIView alloc] initWithFrame:self.bounds];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.contentView];
    
    _titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _titleButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 50);
    _titleButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    _titleButton.layer.borderColor = [UIColor redColor].CGColor;
    _titleButton.layer.borderWidth= 2;
    [self.contentView addSubview:self.titleButton];
    

    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.contentView addGestureRecognizer:_tap];
    
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self.titleButton setTitle:title forState:UIControlStateNormal];
}

- (void)setDataSource:(id<RSectionDataSource>)dataSource {
    _dataSource = dataSource;
    if (_dataSource == nil) {
        return;
    }
}


- (void)reloadData:(NSInteger)sectionIndex {
    _section = sectionIndex;
}


- (void)reloadData {
    if (_dataSource == nil) {
        return;
    }
    
    for(UITableViewCell *cell in self.contentView.subviews) {
        if ([cell isKindOfClass:[UITableViewCell class]]) {
            [cell removeFromSuperview];
            [self queueReusableCell:cell];
        }
    }
    
    [_visibleCells removeAllObjects];
    
    
    CGFloat contentHeight = [self contentHeight];
    NSInteger numberOfRows = [_dataSource numberOfRowsInSectionView:self];
    CGFloat rowHeight = [_dataSource sectionView:self heightForRow:0];
    
    CGFloat fullContentHeight = [self fullContentHeight];
    
    
    CGFloat allGap = fullContentHeight - contentHeight;
    CGFloat newHeight = contentHeight + _translationY / fullContentHeight * allGap ;
    [self setContentSize:CGSizeMake(CGRectGetWidth(self.bounds), newHeight)];
    
    CGFloat fullRowHeight = newHeight / (numberOfRows + 1);
    
    
    CGFloat cellTop = fullRowHeight;
    for(int i = 0 ; i < numberOfRows; i++) {
        UITableViewCell *cell = [_dataSource sectionView:self viewForRowAtRow:i];
        cell.width = self.contentView.width;
        cell.height = rowHeight;
        cell.top = cellTop;
        cellTop += fullRowHeight;
        [self.contentView addSubview:cell];
        [_visibleCells addObject:cell];
        
    }

}

- (void)setTranslationX:(CGFloat)translationX animation:(BOOL)animation{
    _translationX = translationX;
    [self transfromCellsWithAnimation:animation];
}

- (void)transfromCellsWithAnimation:(BOOL)animation{
    float factor = 1;
    float persentage = 1.0 - fabsf( - _translationX) / 320.0;
    float angle = (persentage) * M_PI ;
    NSLog(@"persentage = %f angle = %f",persentage, angle);
    if (animation) {
        [UIView beginAnimations:@"CellAnimation" context:NULL];
        [UIView setAnimationDuration:0.3];
    }
    for(UITableViewCell *cell in _visibleCells) {
        angle *= factor;
        [cell setAnchorPoint:CGPointMake(0, 0.5)];
        cell.layer.anchorPointZ = 100 * persentage;
        CATransform3D tranform = CATransform3DIdentity;
        tranform.m34 = 1.f / 1000.f;
        tranform =  CATransform3DRotate(tranform ,angle, 0, 1, 0);
        cell.layer.transform = tranform;
        factor *= 0.9;
    }
    if (animation) {
        [UIView commitAnimations];
    }

}

- (void)setTranslationY:(CGFloat)x {
    _translationY = fabsf(x);
    
    [self layout];
}

- (void)layout {
    if (_dataSource == nil) {
        return;
    }
    
    NSInteger numberOfRows = [_dataSource numberOfRowsInSectionView:self];

    if(_visibleCells.count < numberOfRows) {
        return;
    }

    CGFloat contentHeight = [self contentHeight];
    CGFloat rowHeight = [_dataSource sectionView:self heightForRow:0];
    CGFloat fullContentHeight = [self fullContentHeight];
    
    CGFloat allGap = fullContentHeight - contentHeight;
    CGFloat newHeight = contentHeight + _translationY / fullContentHeight * allGap ;
    [self setContentSize:CGSizeMake(CGRectGetWidth(self.bounds), newHeight)];
    
    CGFloat fullRowHeight = newHeight / (numberOfRows + 1);
    
    
    CGFloat cellTop = fullRowHeight;
    for(int i = 0 ; i < numberOfRows; i++) {
        
        UITableViewCell *cell = _visibleCells[i];
        [cell setAnchorPoint:CGPointMake(0.5, 0.5)];
        cell.height = rowHeight;
        cell.top = cellTop;
        cellTop += fullRowHeight;
    }
}

- (CGFloat)headerHeight {
    CGFloat rowHeight = [_dataSource sectionView:self heightForRow:0];
    return rowHeight;
}

- (CGFloat)contentHeight {
    NSInteger numberOfRows = [_dataSource numberOfRowsInSectionView:self];
    CGFloat rowHeight = [_dataSource sectionView:self heightForRow:0];
    return (numberOfRows + 1)* rowHeight;
}

- (CGFloat)fullContentHeight {
    CGFloat fullContentHeight = CGRectGetHeight(self.bounds);
    return fullContentHeight;// - height;
}

- (CGFloat)gap {
    NSInteger numberOfRows = [_dataSource numberOfRowsInSectionView:self];
    return ([self fullContentHeight] - [self contentHeight])/ numberOfRows;
}

- (void)setContentSize:(CGSize)size {
    _contentSize = size;
    self.contentView.frame = CGRectMake(CGRectGetMidX(self.bounds) - 0.5 * _contentSize.width, CGRectGetMidY(self.bounds) - 0.5 * _contentSize.height, _contentSize.width, _contentSize.height);
}


- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
	if(!identifier) return nil;
    
	UITableViewCell* aTableViewCell = [[_reusableTableCells objectForKey:identifier] anyObject];
	if(!aTableViewCell) return nil;
    
    
	[[_reusableTableCells objectForKey:identifier] removeObject:aTableViewCell];
    
	return aTableViewCell;
}

- (void)queueReusableCell:(UITableViewCell*)aTableViewCell {
	if(!aTableViewCell) return;
	if(!aTableViewCell.reuseIdentifier) return;
    
	if([[_reusableTableCells objectForKey:aTableViewCell.reuseIdentifier] containsObject:aTableViewCell]) return;
    
	[aTableViewCell prepareForReuse];
    
	if(![_reusableTableCells objectForKey:aTableViewCell.reuseIdentifier]) {
		[_reusableTableCells setObject:[NSMutableSet setWithCapacity:1] forKey:aTableViewCell.reuseIdentifier];
	}
    
	[[_reusableTableCells objectForKey:aTableViewCell.reuseIdentifier] addObject:aTableViewCell];

}

- (void)handleTap:(UITapGestureRecognizer *)tapRecognizer {
    CGPoint location = [tapRecognizer locationInView:self.contentView];
    if (!_highlightedRow) {
        
        int i = 0;
        for(UITableViewCell *cell in _visibleCells) {
            
            cell.highlighted = NO;
            [cell setSelected:NO animated:NO];
            BOOL contains = CGRectContainsPoint(cell.frame, location);
            if (contains) {
                cell.highlighted = YES;

                [cell setSelected:YES animated:NO];
                
                if ([_delegate respondsToSelector:@selector(sectionView:didSelectRowAtIndex:)]) {
                    [_delegate sectionView:self didSelectRowAtIndex:i];
                }
                
            } else {
                continue;
            }
            i++;
        }
    }
    
}


- (NSInteger)indexForCell:(UITableViewCell *)cell
{
    int index = 0;
    for(int i = 0 ; i < _visibleCells.count; i++) {
        if (cell == [_visibleCells objectAtIndex:i]) {
            index = i;
        }
        continue;
    }
    return index;
}

- (void)deselectRowAtIndex:(NSInteger)index animated:(BOOL)animated {
    
}

- (void)selectRowAtIndex:(NSInteger)index animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
    
}



@end
