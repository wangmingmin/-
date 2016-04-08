//
//  myView.h
//  IBInspectable
//
//  Created by anlaiye on 15/10/16.
//  Copyright © 2015年 wangmingmin. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE//你的初始化、布置和绘制方法将被用来在画布上渲染你的自定义视图
@interface myView : UIButton
@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable UIColor* borderColor;
@end
