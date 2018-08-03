//
//  BWViewDrawTool.h
//  MLDemon
//
//  Created by Qu,Ke on 2018/6/19.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BWViewDrawTool : NSObject

+ (UIImage *)drawRectViewWithFrame:(NSArray *)frames withImageSize:(CGSize)size;

+ (UIImage *)drawFaceMarksViewWithPoints:(NSArray *)points withImageSize:(CGSize)size;

@end
