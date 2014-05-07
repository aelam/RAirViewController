//
//  RMenuCell.m
//  RAirViewControllerDemo
//
//  Created by Ryan Wang on 14-3-25.
//  Copyright (c) 2014年 Ryan Wang. All rights reserved.
//

#import "RMenuCell.h"

@implementation RMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected) {
        self.textLabel.textColor = [UIColor blueColor];
    } else {
        self.textLabel.textColor = [UIColor lightGrayColor];
    }

    
    // Configure the view for the selected state
}

@end
