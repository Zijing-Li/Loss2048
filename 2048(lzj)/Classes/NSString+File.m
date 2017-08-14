//
//  NSString+File.m
//  数据存储_archiver
//
//  Created by loss on 15-3-3.
//  Copyright (c) 2015年 Loss. All rights reserved.
//

#import "NSString+File.h"

@implementation NSString (File)

#pragma mark 拼接沙盒
- (NSString *)documentAppend {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:self];
}

@end
