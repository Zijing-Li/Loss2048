//
//  GameMainController.m
//  2048(lzj)
//
//  Created by loss on 15-4-13.
//  Copyright (c) 2015年 Loss. All rights reserved.
//

#import "GameMainController.h"
#import "GameTile.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+File.h"
#import "SoundsManager.h"
#import "WinController.h"
#import "FailedController.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, MoveOrientation) {
    MoveOrientationUp,
    MoveOrientationDown,
    MoveOrientationLeft,
    MoveOrientationRight
};

typedef NS_ENUM(NSInteger, GameStatus) {
    GameStatusIdel,
    GameStatusFailed,
    GameStatusSuccess
};

#define kCountRow 4
#define kCountColumn 4
#define kMaxNumber 2048
#define kNotificationEndmove @"notification_endmove"
#define kNotificationReset @"notification_reset"
#define kGameHistoryFile @"game_history.xml"
#define kHistoryScore @"historyScore"
#define kHighScore @"highScore"
#define kSound @"sound"

@interface GameMainController () {
    CGPoint _touchBeginPoint;
    UISwipeGestureRecognizer *_swipeRecognizer;
    UIPanGestureRecognizer *_panRecognizer;
    BOOL _isMoving;
    BOOL _isOnceTouch;
    BOOL _isAdded;
    GameStatus _gameStatus;
    int _score;
    int _highScore;
    ImageCheckBox *_soundCheckBox;
    
    UILabel *_scoreView;
    UILabel *_highScoreView;
    
    UILabel *_resetView;
}

@property (nonatomic, retain) NSMutableArray *tiles;
@property (nonatomic, retain) NSMutableArray *freeTiles;

@end

@implementation GameMainController

#pragma mark - 生命周期方法

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *backGround = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backGround.image = [UIImage imageNamed:@"Default.png"];
    [self.view addSubview:backGround];
    [backGround release];
    
    int scoreBgHeight = 60;
    int scoreBgWidth = 100;
    
    UIView *scoreBg = [[UIView alloc] init];
    scoreBg.layer.cornerRadius = 10;
    scoreBg.layer.masksToBounds = YES;
    scoreBg.frame = CGRectMake(10, 22, scoreBgWidth, scoreBgHeight);
    scoreBg.backgroundColor = lossColor(187, 173, 162);
    [self.view addSubview:scoreBg];
    [scoreBg release];
    
    UILabel *scoreTitle = [[UILabel alloc] init];
    scoreTitle.frame = CGRectMake(0, 0, scoreBgWidth, scoreBgHeight * 0.5);
    scoreTitle.font = [UIFont systemFontOfSize:16];
    scoreTitle.textColor = lossColor(242, 230, 214);
    scoreTitle.textAlignment = NSTextAlignmentCenter;
    [scoreBg addSubview:scoreTitle];
    scoreTitle.text = @"得分";
    [scoreTitle release];
    
    UILabel *scoreView = [[UILabel alloc] init];
    scoreView.textAlignment = NSTextAlignmentCenter;
    scoreView.font = [UIFont systemFontOfSize:19];
    scoreView.frame = CGRectMake(0, scoreBgHeight * 0.5, scoreBgWidth, scoreBgHeight * 0.4);
    scoreView.textColor = [UIColor whiteColor];
    [scoreBg addSubview:scoreView];
    _scoreView = scoreView;
    [scoreView release];
    
    UIView *highScoreBg = [[UIView alloc] init];
    highScoreBg.frame = CGRectMake(scoreBg.frame.origin.x, scoreBg.frame.origin.y + scoreBgHeight + 10, scoreBgWidth, scoreBgHeight);
    highScoreBg.layer.cornerRadius = 10;
    highScoreBg.layer.masksToBounds = YES;
    highScoreBg.backgroundColor = lossColor(187, 173, 162);
    [self.view addSubview:highScoreBg];
    [highScoreBg release];
    
    UILabel *highScoreTitle = [[UILabel alloc] init];
    highScoreTitle.frame = scoreTitle.frame;
    highScoreTitle.font = scoreTitle.font;
    highScoreTitle.textColor = scoreTitle.textColor;
    highScoreTitle.textAlignment = NSTextAlignmentCenter;
    [highScoreBg addSubview:highScoreTitle];
    highScoreTitle.text = @"最高分";
    [highScoreTitle release];
    
    UILabel *highScoreView = [[UILabel alloc] init];
    highScoreView.frame = scoreView.frame;
    highScoreView.font = scoreView.font;
    highScoreView.textColor = scoreView.textColor;
    highScoreView.textAlignment = NSTextAlignmentCenter;
    [highScoreBg addSubview:highScoreView];
    _highScoreView = highScoreView;
    [highScoreView release];
    
    // 创建按钮
    UIButton *btn = [[UIButton alloc] init];
    
    btn.bounds = CGRectMake(0, 0, 70, 55);
    btn.center = CGPointMake(self.view.bounds.size.width - 10 - btn.bounds.size.width * 0.5, 90);
    // 设置默认和背景高亮
    [btn setBackgroundImage:[UIImage imageNamed:@"new_features_startbutton_background"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"new_features_startbutton_background_highlighted.png"] forState:UIControlStateHighlighted];
    
    // 设置按钮文字
    NSString *title = NSLocalizedString(@"重置", nil);// 获取本地化的字符,如果不存在则返回key
    [btn setTitle:title forState:UIControlStateNormal];
    // 设置按钮文字颜色
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    // 设置按钮文字大小
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    
    // 设置代理方法
    [btn addTarget:self action:@selector(resetGame) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    [btn release];
    
    ImageCheckBox *checkBox =[[ImageCheckBox alloc] initWithNormal:@"closemusic.png" checked:@"openmusic"];
    checkBox.delete = self;
    checkBox.checked = [[NSUserDefaults standardUserDefaults] boolForKey:kSound];
    
    checkBox.frame = CGRectMake(10, self.view.bounds.size.height - 45, 35, 35);
    [self.view addSubview:checkBox];
    _soundCheckBox = checkBox;
    [checkBox release];
    
    _gameStatus = GameStatusIdel;
    [self initTiles];
    [self registGesture];
}

- (void)dealloc {
    [self unregistGesture];
    [_freeTiles release];
    [_tiles release];
    [super dealloc];
}

- (void)viewDidUnload {
    self.freeTiles = nil;
    self.tiles = nil;
    [super viewDidUnload];
}

#pragma mark - 私有方法
#pragma mark 重置
- (void)resetGame {
    [self setScore:0];
    
    [_freeTiles removeAllObjects];
    NSLog(@"重置");
    for (int i = 0; i < kCountRow; i++) {
        for (int j = 0; j < kCountColumn; j++) {
            GameTile *tile = [self getTileRow:i column:j];
            if (tile) {
                [tile reset];
                [_freeTiles addObject:tile];
            }
        }
    }
    
    
    
    // 随机添加两个数字
    [self randomInsertNumber:NO];
    [self randomInsertNumber:NO];
    //[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReset object:nil];
}
#pragma mark 设置分数
- (void)setScore:(int)score {
    _scoreView.text = [NSString stringWithFormat:@"%i", score];
}

#pragma mark 设置最高分
- (void)setHighScore:(int)score {
    _highScoreView.text = [NSString stringWithFormat:@"%i", score];
}

#pragma mark 初始化方块
- (void)initTiles {
    // 初始化容器
    self.freeTiles = [NSMutableArray array];
    
    self.tiles = [NSKeyedUnarchiver unarchiveObjectWithFile:[kGameHistoryFile documentAppend]];
    _highScore = [[NSUserDefaults standardUserDefaults] integerForKey:kHighScore];
    [self setHighScore:_highScore];
    NSLog(@"highScore:%i", _highScore);
    _score = _tiles ? [[NSUserDefaults standardUserDefaults] integerForKey:kHistoryScore] : 0;
    [self setScore:_score];
    
    NSNotificationCenter *ntfCenter = [NSNotificationCenter defaultCenter];
    [ntfCenter addObserver:self selector:@selector(saveGame) name:kNotificationSaveGame object:nil];
    
    CGSize windowSize = [UIScreen mainScreen].applicationFrame.size;
    
    CGFloat x = windowSize.width * 0.03;
    CGFloat y = (windowSize.height - windowSize.width) * 0.8;
    CGFloat padding = x * 2/3;
    CGFloat tileSize = (windowSize.width - x * 2 - padding * (kCountColumn + 1)) * 1.0f / kCountColumn;
    
    
    UIView *gridsBg = [[UIView alloc] init];
    CGFloat gridsWidth = windowSize.width - x * 2;
    gridsBg.frame = CGRectMake(x, y, gridsWidth, gridsWidth);
    gridsBg.backgroundColor = [UIColor colorWithRed:0.56 green:0.58 blue:0.6 alpha:0.25];
    gridsBg.layer.cornerRadius = gridsWidth * 0.03;
    [self.view addSubview:gridsBg];
    [gridsBg release];

    
    if (!_tiles) {
        NSLog(@"init tiltes ");
        self.tiles = [NSMutableArray arrayWithCapacity:kCountRow];
        
        
        for (int i = 0; i < kCountRow; i++) {
            NSMutableArray *arr = [NSMutableArray arrayWithCapacity:kCountColumn];
            for (int j = 0; j < kCountColumn; j++) {
                GameTile *tile = [[GameTile alloc] init];
                [ntfCenter addObserver:tile selector:@selector(resetAddOnce) name:kNotificationEndmove object:nil];
                //[ntfCenter addObserver:tile selector:@selector(reset) name:kNotificationReset object:nil];
                tile.frame = CGRectMake(j * tileSize + (j + 1) * padding, i * tileSize +(i + 1) *padding, tileSize, tileSize);
                [gridsBg addSubview:tile];
                tile.number = 0;
                
                [arr addObject:tile];
                [_freeTiles addObject:tile];
                
                [tile release];
            }
            [self.tiles addObject:arr];
        }
        
        // 随机添加两个数字
        [self randomInsertNumber:NO];
        [self randomInsertNumber:NO];

    } else {
        // 读取成功，清除原来的
        [NSKeyedArchiver archiveRootObject:nil toFile:[kGameHistoryFile documentAppend]];

        NSLog(@"read tiltes ");
        
        for (int i = 0; i < kCountRow; i++) {
            
            for (int j = 0; j < kCountColumn; j++) {
                GameTile *tile = [self getTileRow:i column:j];
                [ntfCenter addObserver:tile selector:@selector(resetAddOnce) name:kNotificationEndmove object:nil];
                //[ntfCenter addObserver:tile selector:@selector(reset) name:kNotificationReset object:nil];
                tile.frame = CGRectMake(j * tileSize + (j + 1) * padding, i * tileSize +(i + 1) *padding, tileSize, tileSize);
                [gridsBg addSubview:tile];
                tile.number = tile.number;
                if (tile.number == 0) {
                    [_freeTiles addObject:tile];
                }
            }
        }
    }
}

#pragma mark 随机添加一个2或4
- (void)randomInsertNumber:(BOOL)animate {
    int freeCount = _freeTiles.count;
    int index = rand() % freeCount;
    GameTile *tile = [_freeTiles objectAtIndex:index];
    if (tile) {
        int number = (rand() % 2 + 1) * 2;
        tile.number = number;
        [_freeTiles removeObject:tile];
        if (animate) {
            [tile doShowAnimate];
        }
    }
}

#pragma mark 通过行号和列号取得方块
- (GameTile *)getTileRow:(int)row column:(int)column {
    GameTile *tile;
    @try {
        NSMutableArray *arr = [self.tiles objectAtIndex:row];
        tile = [arr objectAtIndex:column];
    }
    @catch (NSException *exception) {
        tile = nil;
    }
    @finally {
    }
    return tile;
}

#pragma mark 注册手势监听
- (void)registGesture {
//    UITapGestureRecognizer  // 点一下
//    UIPinchGestureRecognizer //两指往内或两指往外拨动
//    UIRotationGestureRecognizer // 选装
//    UISwipeGestureRecognizer  // 滑动 快速移动
//    UIPanGestureRecognizer // 拖动 慢速移动
//    UILongPressGestureRecognizer // 长按
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:_panRecognizer];
    [_panRecognizer release];
}
#pragma mark 取消手势监听
- (void)unregistGesture {
    [self.view removeGestureRecognizer:_swipeRecognizer];
    [self.view removeGestureRecognizer:_panRecognizer];
}

#pragma mark 完成滑动后的操作
- (BOOL)move:(BOOL) realMove step:(int) step orientation:(MoveOrientation) moveOrientation{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
    BOOL moved = NO;
    switch (moveOrientation) {
        case MoveOrientationLeft:
        {
            for (int row = 0; row < kCountRow; row++) {
                for (int column = 1; column < kCountColumn; column++) {
                    GameTile *tile_1 = [self getTileRow:row column:column];
                    if (!tile_1 || [_freeTiles containsObject:tile_1]) {
                        continue;
                    }
                    GameTile *tile_2 = [self getTileRow:row column:column - 1];
                    if (!tile_2) {
                        continue;
                    }
                    if ([_freeTiles containsObject:tile_2]) {
                        tile_2.number = tile_1.number;
                        tile_1.number = 0;
                        [_freeTiles removeObject:tile_2];
                        [_freeTiles addObject:tile_1];
                        moved = YES;
                        if (column > 1 && [_freeTiles containsObject:[self getTileRow:row column:column - 2]]) {
                            [tile_2 move];
                        } else {
                            [tile_2 endMove];
                        }
                    } else if (tile_1.number == tile_2.number && !tile_1.addOnce && !tile_2.addOnce) {
                        if (!realMove) {
                            return true;
                        }
                        tile_2.number = tile_2.number + tile_1.number;
                        [self addScore:tile_2.number];
                        if (tile_2.number >= kMaxNumber) {
                            [self sucessed];
                        }
                        tile_2.addOnce = YES;
                        tile_1.number = 0;
                        [_freeTiles addObject:tile_1];
                        moved = YES;
                    }
                }
            }
        }
            break;
        case MoveOrientationRight:
        {
            for (int row = 0; row < kCountRow; row++) {
                for (int column = kCountColumn - 2; column >= 0; column--) {
                    GameTile *tile_1 = [self getTileRow:row column:column];
                    if (!tile_1 || [_freeTiles containsObject:tile_1]) {
                        continue;
                    }
                    GameTile *tile_2 = [self getTileRow:row column:column + 1];
                    if (!tile_2) {
                        continue;
                    }
                    if ([_freeTiles containsObject:tile_2]) {
                        tile_2.number = tile_1.number;
                        tile_1.number = 0;
                        [_freeTiles removeObject:tile_2];
                        [_freeTiles addObject:tile_1];
                        moved = YES;
                        if (column < kCountColumn - 2 && [_freeTiles containsObject:[self getTileRow:row column:column + 2]]) {
                            [tile_2 move];
                        } else {
                            [tile_2 endMove];
                        }
                    } else if (tile_1.number == tile_2.number && !tile_1.addOnce && !tile_2.addOnce) {
                        if (!realMove) {
                            return true;
                        }
                        tile_2.number = tile_2.number + tile_1.number;
                        [self addScore:tile_2.number];
                        if (tile_2.number >= kMaxNumber) {
                            [self sucessed];
                        }
                        tile_2.addOnce = YES;
                        tile_1.number = 0;
                        [_freeTiles addObject:tile_1];
                        moved = YES;
                    }
                }
            }
        }
            break;
        case MoveOrientationUp:
        {
            for (int column = 0; column < kCountColumn; column++) {
                for (int row = 1; row < kCountRow; row++) {
                    GameTile *tile_1 = [self getTileRow:row column:column];
                    if (!tile_1 || [_freeTiles containsObject:tile_1]) {
                        continue;
                    }
                    GameTile *tile_2 = [self getTileRow:row - 1 column:column];
                    if (!tile_2) {
                        continue;
                    }
                    if ([_freeTiles containsObject:tile_2]) {
                        tile_2.number = tile_1.number;
                        tile_1.number = 0;
                        [_freeTiles removeObject:tile_2];
                        [_freeTiles addObject:tile_1];
                        moved = YES;
                        if (row > 1 && [_freeTiles containsObject:[self getTileRow:row - 2 column:column]]) {
                            [tile_2 move];
                        } else {
                            [tile_2 endMove];
                        }
                    } else if (tile_1.number == tile_2.number && !tile_1.addOnce && !tile_2.addOnce) {
                        if (!realMove) {
                            return true;
                        }
                        tile_2.number = tile_2.number + tile_1.number;
                        [self addScore:tile_2.number];
                        if (tile_2.number >= kMaxNumber) {
                            [self sucessed];
                        }
                        tile_2.addOnce = YES;
                        tile_1.number = 0;
                        [_freeTiles addObject:tile_1];
                        moved = YES;
                    }
                }
            }
        }
            break;
        case MoveOrientationDown:
        {
            for (int column = 0; column < kCountColumn; column++) {
                for (int row = kCountRow - 2; row >= 0; row--) {
                    GameTile *tile_1 = [self getTileRow:row column:column];
                    if (!tile_1 || [_freeTiles containsObject:tile_1]) {
                        continue;
                    }
                    GameTile *tile_2 = [self getTileRow:row + 1 column:column];
                    if (!tile_2) {
                        continue;
                    }
                    if ([_freeTiles containsObject:tile_2]) {
                        tile_2.number = tile_1.number;
                        tile_1.number = 0;
                        [_freeTiles removeObject:tile_2];
                        [_freeTiles addObject:tile_1];
                        moved = YES;
                        if (row < kCountRow - 2 && [_freeTiles containsObject:[self getTileRow:row + 2 column:column]]) {
                            [tile_2 move];
                        } else {
                            [tile_2 endMove];
                        }
                    } else if (tile_1.number == tile_2.number && !tile_1.addOnce && !tile_2.addOnce) {
                        if (!realMove) {
                            return true;
                        }
                        tile_2.number = tile_2.number + tile_1.number;
                        [self addScore:tile_2.number];
                        if (tile_2.number >= kMaxNumber) {
                            [self sucessed];
                        }
                        tile_2.addOnce = YES;
                        tile_1.number = 0;
                        [_freeTiles addObject:tile_1];
                        moved = YES;
                    }
                }
            }
        }
            break;
        default:
            _isMoving = NO;
            break;
    }
    if (moved) {
        
        CFTimeInterval endTime = CFAbsoluteTimeGetCurrent();
        //NSLog(@"use time :%f", endTime - startTime);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC * 0.05)), dispatch_get_main_queue(), ^{
            [self move:realMove step:step + 1 orientation:moveOrientation];
        });
    } else {
        if (step != 0) {
            NSNotificationCenter *ntfCenter = [NSNotificationCenter defaultCenter];
            [ntfCenter postNotificationName:kNotificationEndmove object:nil];
            [self randomInsertNumber:YES];
            if (![self hasNextStep]) {
                [self failed];
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC * 0.1)), dispatch_get_main_queue(), ^{
            _isMoving = NO;
            _isAdded = NO;
        });
    }
    return moved;
}

#pragma mark - 游戏结果
#pragma mark 加分
- (void)addScore:(int)score {
    _score += score;
    [self setScore:_score];
    if (_score > _highScore) {
        [[NSUserDefaults standardUserDefaults] setInteger:_score forKey:kHighScore];
        [self setHighScore:_score];
    }
    if (!_isAdded) {
        _isAdded = YES;
        [[SoundsManager manager]playAddedSound];
    }
}
#pragma mark 胜利
- (void)sucessed {
    _gameStatus = GameStatusSuccess;
    [[SoundsManager manager] playWinSound];
    WinController *winController = [[WinController alloc] init];
    [self presentViewController:winController animated:YES completion:nil];
    [winController release];
}
#pragma mark 失败
- (void)failed {
    _gameStatus = GameStatusFailed;
    [[SoundsManager manager] playFailedSound];
    FailedController *failedController = [[FailedController alloc] init];
    [self presentViewController:failedController animated:YES completion:nil];
    [failedController release];

}
#pragma mark 保存游戏
- (void)saveGame {
    if (_score > 0 && _gameStatus == GameStatusIdel && _tiles.count != 0) {
        NSLog(@"保存进度, %@", [kGameHistoryFile documentAppend]);
        [NSKeyedArchiver archiveRootObject:self.tiles toFile:[kGameHistoryFile documentAppend]];
        [[NSUserDefaults standardUserDefaults] setInteger:_score forKey:kHistoryScore];
    }
    
}
#pragma mark 检查是否还有下一步
- (BOOL)hasNextStep {
    if (_freeTiles.count != 0) {
        return YES;
    }
    return [self move:NO step:0 orientation:MoveOrientationLeft] || [self move:NO step:0 orientation:MoveOrientationUp] || [self move:NO step:0 orientation:MoveOrientationRight] || [self move:NO step:0 orientation:MoveOrientationDown];
}

#pragma mark - 手势响应
#pragma mark 慢速滑动响应
- (void)pan:(UIPanGestureRecognizer *)recognizer {
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            _touchBeginPoint = [recognizer translationInView:self.view];;
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (_isMoving || _isOnceTouch || _gameStatus != GameStatusIdel) {
                return;
            }
            _isOnceTouch = YES;
            _isMoving = YES;
            
            CGPoint point =[recognizer translationInView:self.view];
            CGFloat distanceX = abs(point.x - _touchBeginPoint.x);
            CGFloat distanceY = abs(point.y - _touchBeginPoint.y);
            BOOL moved = NO;
            if ( distanceX > distanceY) { // 水平运动
                if (point.x > _touchBeginPoint.x) { // 抬起点在按下点的右边
                    // 向右滑动
                    moved = [self move:YES step:0 orientation:MoveOrientationRight];
                } else {
                    // 向左滑动
                    moved = [self move:YES step:0 orientation:MoveOrientationLeft];
                }
            } else if (distanceX < distanceY) { // 垂直运动
                if (point.y > _touchBeginPoint.y) { // 抬起点在按下点的下边
                    // 向下滑动
                    moved = [self move:YES step:0 orientation:MoveOrientationDown];
                } else {
                    // 向上滑动
                    moved = [self move:YES step:0 orientation:MoveOrientationUp];
                }
            } else {
                CGFloat vx = point.x - _touchBeginPoint.x;
                CGFloat vy = point.y = _touchBeginPoint.y;
                if (vx > 0) {
                    if (vy < 0) {
                        // 右上
                        moved = [self move:YES step:0 orientation:MoveOrientationRight];
                    } else {
                        // 右下
                        moved = [self move:YES step:0 orientation:MoveOrientationDown];
                    }
                } else {
                    if (vy > 0) {
                        // 左下
                        moved = [self move:YES step:0 orientation:MoveOrientationLeft];
                    } else {
                        // 左上
                        moved = [self move:YES step:0 orientation:MoveOrientationUp];
                    }
                }
            }
            if (moved) {
                [[SoundsManager manager] playMoveSound];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            _isOnceTouch = NO;
            break;
        default:
            break;
    }
}

#pragma mark - chekBoxDelegate
- (void)checkBoxStateChanged:(ImageCheckBox *)checkBox {
    [SoundsManager manager].soundOpen = checkBox.isChecked;
    [[NSUserDefaults standardUserDefaults] setBool:checkBox.isChecked forKey:kSound];
}

@end
