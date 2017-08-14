//
//  MyCheckBox.h
//  自定义CheckBox
//
//  Created by loss on 14-12-19.
//  Copyright (c) 2015年 Loss. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MyCheckBoxDelegate;

@interface ImageCheckBox : UIView

@property (nonatomic, assign, getter = isChecked) BOOL checked;
@property (nonatomic, retain) id<MyCheckBoxDelegate> delete;
@property (nonatomic, copy) NSString *normalIcon;
@property (nonatomic, copy) NSString *checkedIcon;

- (id)initWithNormal:(NSString *)normalIcon checked:(NSString *)checkedIcon;

@end

@protocol MyCheckBoxDelegate <NSObject>

- (void)checkBoxStateChanged:(ImageCheckBox *)checkBox;

@end
