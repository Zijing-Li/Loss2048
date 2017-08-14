//
//  GameMainController.h
//  2048(lzj)
//
//  Created by loss on 15-4-13.
//  Copyright (c) 2015年 Loss. All rights reserved.
//  主控制器

#import <UIKit/UIKit.h>
#import "ImageCheckBox.h"

#define kNotificationSaveGame @"notification_saveGame"

@interface GameMainController : UIViewController <MyCheckBoxDelegate>

@end
