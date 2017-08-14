//
//  MyCheckBox.m
//  自定义CheckBox
//
//  Created by loss on 14-12-19.
//  Copyright (c) 2015年 Loss. All rights reserved.
//

#import "ImageCheckBox.h"

@interface ImageCheckBox () {
    
}

@end

@implementation ImageCheckBox

#pragma mark 构造方法
- (id)initWithNormal:(NSString *)normalIcon checked:(NSString *)checkedIcon{
    
    if (self = [super init]) {
        // 设置背景透明
        self.backgroundColor = [UIColor clearColor];
        self.normalIcon = normalIcon;
        self.checkedIcon = checkedIcon;
    }
    
    
    return self;
}

#pragma mark 重写 setChecked 方法
- (void)setChecked:(BOOL)checked {
    // 状态改变,通知代理
    if (_checked != checked) {
        _checked = checked;
        if ([_delete respondsToSelector:@selector(checkBoxStateChanged:)]) {
            [_delete checkBoxStateChanged:self];
        }

        // 重新绘制,会重新调用 drawRect:方法
        [self setNeedsDisplay];
    }
    
}

- (void)dealloc {
    [_normalIcon release];
    [_checkedIcon release];
    [_delete release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    // 根据 checked 来绘制相应图片
    NSString *iconName = _checked?_checkedIcon:_normalIcon;
    UIImage *image = [UIImage imageNamed:iconName];
    [image drawInRect:self.bounds];
}

#pragma mark 重写触摸事件
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.checked = !self.isChecked;
}


@end
