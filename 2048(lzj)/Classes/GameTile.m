//
//  GameTitle.m
//  2048(lzj)
//
//  Created by loss on 15-4-13.
//  Copyright (c) 2015年 Loss. All rights reserved.
//

#import "GameTile.h"
#import <QuartzCore/QuartzCore.h>

#define kNumberSize 19

@interface GameTile () {
    UILabel *_numberLabel;
}

@end

@implementation GameTile

#pragma mark - 生命周期方法
- (id)init {
    if (self == [super init]) {
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:kNumberSize];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _numberLabel = label;
        [label release];
        
        self.number = 0;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.bounds.size.width / 6;
    _numberLabel.bounds = CGRectMake(0, 0, self.bounds.size.width, _numberLabel.font.lineHeight);
    _numberLabel.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
}

#pragma mark - 其他方法
#pragma mark
- (void)move {
    [self setNumber:_number alpah:0.5];
}

- (void)endMove {
    [self setNumber:_number alpah:1];
}

- (void)resetAddOnce {
    self.addOnce = NO;
}

- (void)reset {
    [self resetAddOnce];
    [self setNumber:0];
    [self endMove];
}

// 2
#pragma mark 播放动画
- (void)doShowAnimate {
    self.transform = CGAffineTransformMakeScale(0.5, 0.5);//将要显示的view按照正常比例显示出来
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; //InOut 表示进入和出去时都启动动画
    [UIView setAnimationDuration:0.3];//动画时间
    self.transform = CGAffineTransformMakeScale(1, 1);//先让要显示的view最小直至消失
    [UIView commitAnimations]; //启动动画

    // 缩放动画
//    CABasicAnimation *animate = [CABasicAnimation animationWithKeyPath:@"bounds"];
//    animate.duration = 0.5;
//    animate.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 0, 0)];
//    animate.toValue = [NSValue valueWithCGRect:self.bounds];
//    [self.layer addAnimation:animate forKey:nil];
}

- (void)setNumber:(int)number alpah:(CGFloat)alpha {
    _number = number;
    
    UIColor *color;
    // 改变数字改变颜色值
    switch (_number) {
        case 0:
            color = [UIColor colorWithRed:0.8 green:0.75 blue:0.7 alpha:alpha];
            break;
        case 2:
            color = [UIColor colorWithRed:0.93 green:0.89 blue:0.85 alpha:alpha];
            break;
        case 4:
            color = [UIColor colorWithRed:0.92 green:0.87 blue:0.78 alpha:alpha];
            break;
        case 8:
            color = [UIColor colorWithRed:0.94 green:0.69 blue:0.47 alpha:alpha];
            break;
        case 16:
            color = [UIColor colorWithRed:0.95 green:0.58 blue:0.38 alpha:alpha];
            break;
        case 32:
            color = [UIColor colorWithRed:0.96 green:0.47 blue:0.3 alpha:alpha];
            break;
        case 64:
            color = [UIColor colorWithRed:0.96 green:0.36 blue:0.21 alpha:alpha];
            break;
        case 128:
            color = [UIColor colorWithRed:0.93 green:0.9 blue:0.38 alpha:alpha];
            break;
        case 256:
            color = [UIColor colorWithRed:0.92 green:0.69 blue:0.3 alpha:alpha];
            break;
        case 512:
            color = [UIColor colorWithRed:0.94 green:0.69 blue:0.47 alpha:alpha];
            break;
        case 1024:
            color = [UIColor colorWithRed:0.92 green:0.58 blue:0.21 alpha:alpha];
            break;
        case 2048:
            color = [UIColor colorWithRed:0.91 green:0.47 blue:0.12 alpha:alpha];
            break;
        default:
            color = [UIColor colorWithRed:0.8 green:0.75 blue:0.7 alpha:alpha];
            break;
    }
    self.backgroundColor = color;
    _numberLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
    if (number == 0) {
        _numberLabel.text = @"";
        return;
    }
    _numberLabel.text = [NSString stringWithFormat:@"%i", number];
    

}

#pragma mark 重写setNumber方法
- (void)setNumber:(int)number {
    [self setNumber:number alpah:1];
}

#pragma mark NSCoding协议方法
- (id)initWithCoder:(NSCoder *)decoder {
    if (self == [super init]) {
        self.number = [decoder decodeIntForKey:@"number"];
        self.row = [decoder decodeIntForKey:@"row"];
        self.column = [decoder decodeIntForKey:@"column"];
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:kNumberSize];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _numberLabel = label;
        [label release];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    // [super encodeWithCoder:encoder];
    [encoder encodeInt:self.number forKey:@"number"];
    [encoder encodeInt:self.row forKey:@"row"];
    [encoder encodeInt:self.column forKey:@"column"];
}



@end
