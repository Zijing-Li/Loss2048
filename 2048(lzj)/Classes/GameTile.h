//
//  GameTitle.h
//  2048(lzj)
//
//  Created by loss on 15-4-13.
//  Copyright (c) 2015年 Loss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameTile : UIView

@property (nonatomic, assign) int number; // 数字
@property (nonatomic, assign) int row;  // 行号
@property (nonatomic, assign) int column;   // 列号
@property (nonatomic, assign) BOOL addOnce; // 是否已经加过一次

- (void)move;
- (void)endMove;
- (void)doShowAnimate;

- (void)resetAddOnce;
- (void)reset;

- (void)setNumber:(int)number;

@end
