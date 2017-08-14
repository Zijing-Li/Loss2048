//
//  WinController.m
//  2048(lzj)
//
//  Created by loss on 15-4-17.
//  Copyright (c) 2015年 Loss. All rights reserved.
//

#import "WinController.h"

@interface WinController ()

@end

@implementation WinController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:1 green:0.9 blue:0.57 alpha:1];
    
    UILabel *msg = [[UILabel alloc] init];
    msg.font = [UIFont systemFontOfSize:25];
    msg.textColor = [UIColor colorWithRed:0.49 green:0.44 blue:0.25 alpha:1];
    msg.backgroundColor = [UIColor whiteColor];
    msg.textAlignment = NSTextAlignmentCenter;
    msg.text = @"你赢了！";
    msg.frame = CGRectMake(0, 0, self.view.bounds.size.width, 100);
    [self.view addSubview:msg];
    [msg release];
    
}

@end
