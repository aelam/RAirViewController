//
//  RMenuViewController.m
//  RAirViewControllerDemo
//
//  Created by Ryan Wang on 14-3-20.
//  Copyright (c) 2014年 Ryan Wang. All rights reserved.
//

#import "RMenuViewController.h"
#import "RMenuCell.h"
#import "PHViewController.h"

@interface RMenuViewController ()

@property (nonatomic, strong) NSArray *menuItems;
@end

@implementation RMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuItems = @[@"搜索",@"发现",@"您的旅程",@"Wish List", @"收件箱"];
    [self.menuView reloadData];
//    self.airView = [[RAirView alloc] initWithFrame:self.view.bounds];
//    self.airView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.airView.dataSource = self;
//    [self.view addSubview:self.airView];
}


#pragma mark - menu dataSource
- (NSInteger)numberOfSectionsInMenuView:(RAirMenuView *)menuView {
    return 1;
}

- (NSInteger)menuView:(RAirMenuView *)menuView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (CGFloat)menuView:(RAirMenuView *)menuView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)menuView:(RAirMenuView *)menuView viewForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [menuView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[RMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.text = [self.menuItems objectAtIndex:indexPath.row];
    cell.indentationWidth = 10.f;
    cell.indentationLevel = 1;
#if 0
    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor redColor];
    } else if (indexPath.row == 1) {
        cell.backgroundColor = [UIColor greenColor];
    } else {
        cell.backgroundColor = [UIColor blueColor];
    }
#endif
    return cell;

}

- (NSString *)menuView:(RAirMenuView *)menuView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Section %ld", (long)section];
}




@end
