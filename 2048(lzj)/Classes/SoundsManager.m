//
//  SoundsManager.m
//  2048(lzj)
//
//  Created by loss on 15-4-16.
//  Copyright (c) 2015年 Loss. All rights reserved.
//

#import "SoundsManager.h"
#import <AVFoundation/AVFoundation.h>

#define kAdd @"add.wav"
#define kWin @"win.wav"
#define kFailed @"failed.wav"
#define kMove @"move.wav"

@interface SoundsManager ()

@property (nonatomic, retain) NSMutableDictionary *soundIDDict;

@end

@implementation SoundsManager

#pragma mark - 单例设计
static SoundsManager *_manager;

- (id)init {
    if (_manager) {
        return _manager;
    }
    if (self == [super init]) {
        _manager = self;
        self.soundIDDict = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (id)alloc {
    if (_manager) {
        return _manager;
    }
    return [super alloc];
}

- (oneway void)release {
    
}
- (id)retain {
    return _manager;
}

-(NSUInteger)retainCount {
    return 1;
}

+(SoundsManager *)manager {
    if (_manager) {
        return _manager;
    }
    
    return [[SoundsManager alloc] init];
}

#pragma mark - 私有方法
#pragma mark 播放音频
- (void)playSoundWithFile:(NSString *)file {
    if (!_soundOpen || !file) {
        return;
    }
    // 先从从字典里面取
    SystemSoundID soundID = [_soundIDDict[file] unsignedIntValue];
    if (!soundID) {
        // 加载音效文件
        NSURL *url = [[NSBundle mainBundle] URLForResource:file withExtension:nil];
        if (!url) {
            return;
        }
        // 创建音效ID
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
        // 放入字典
        _soundIDDict[file] = @(soundID);
    }
    // 播放
    AudioServicesPlaySystemSound(soundID);
}

#pragma mark 移除音频
- (void)disposeSoundWithFile:(NSString *)file {
    if (!file) {
        return;
    }
    SystemSoundID soundID = [_soundIDDict[file] unsignedIntValue];
    if (soundID) {
        // 销毁音乐ID
        AudioServicesDisposeSystemSoundID(soundID);
        // 从字典移除
        [_soundIDDict removeObjectForKey:file];
    }
}

#pragma mark - 对外方法

- (void)playAddedSound {
    [self playSoundWithFile:kAdd];
}

- (void)playFailedSound {
    [self playSoundWithFile:kFailed];
}

- (void)playMoveSound {
    [self playSoundWithFile:kMove];
}

- (void)playWinSound {
    [self playSoundWithFile:kWin];
}

- (void)poseSounds {
    [self disposeSoundWithFile:kAdd];
    [self disposeSoundWithFile:kFailed];
    [self disposeSoundWithFile:kMove];
    [self disposeSoundWithFile:kWin];
}

@end
