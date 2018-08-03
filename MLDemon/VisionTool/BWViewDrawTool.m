//
//  BWViewDrawTool.m
//  MLDemon
//
//  Created by Qu,Ke on 2018/6/19.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import "BWViewDrawTool.h"

@implementation BWViewDrawTool

+ (UIImage *)drawRectViewWithFrame:(NSArray *)frames withImageSize:(CGSize)size
{
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(size.width, size.height)];
    
    void (^UIGraphicsImageDrawingActions)(UIGraphicsImageRendererContext *rendererContext) = ^(UIGraphicsImageRendererContext *rendererContext)
    {
        
        
//        CGAffineTransform  transform = CGAffineTransformIdentity;
//        transform = CGAffineTransformScale(transform, size.width, -size.height);
//        transform = CGAffineTransformTranslate(transform, 0, -1);
        
        [[UIColor redColor] setStroke];

        for (NSValue* value in frames) {
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:[value CGRectValue]];
            path.lineWidth = 4.0f;
            [path stroke];
        }
        
    };

    UIImage * image = [renderer imageWithActions:UIGraphicsImageDrawingActions];
    
    return image;
    
}

+ (UIImage *)drawFaceMarksViewWithPoints:(NSArray *)points withImageSize:(CGSize)size
{
    
    UIGraphicsBeginImageContextWithOptions(size, false, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor greenColor] set];
    CGContextSetLineWidth(context, 2);
    
    
    // 设置翻转
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // 设置线类型
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    // 设置抗锯齿
    CGContextSetShouldAntialias(context, true);
    CGContextSetAllowsAntialiasing(context, true);
    
    
    for (NSInteger i = 0; i < points.count; i++) {
        
        NSArray * markPoints = points[i]; //一张脸
        
        for (NSInteger j = 0; j < markPoints.count; j++) {
            
            NSArray * markArray = markPoints[j]; //一条面部特征
            CGPoint points[markArray.count];

            for (NSInteger k = 0; k < markArray.count; k++) {
                points[k] = [markArray[k] CGPointValue];
            }
            
            if (markArray.count > 1) {
                // 绘制
                CGContextAddLines(context, points, markArray.count);
                CGContextDrawPath(context, kCGPathStroke);
            }
          
        }
        
    }
        
    
    // 结束绘制
    UIImage * sourceImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return sourceImage;
}


@end
