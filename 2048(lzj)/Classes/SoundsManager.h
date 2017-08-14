//
//  SoundsManager.h
//  2048(lzj)
//
//  Created by loss on 15-4-16.
//  Copyright (c) 2015年 Loss. All rights reserved.
//  声音管理

#import <Foundation/Foundation.h>

@interface SoundsManager : NSObject

+(SoundsManager *)manager;

@property (nonatomic, assign) BOOL soundOpen;

- (void)playAddedSound;
- (void)playMoveSound;
- (void)playWinSound;
- (void)playFailedSound;

- (void)poseSounds;

@end
