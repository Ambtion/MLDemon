//
//  BWVisonTool.h
//  MLDemon
//
//  Created by Qu,Ke on 2018/6/19.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWVisionData.h"
#import <AVFoundation/AVFoundation.h>

typedef void (^detecImageHandler)(BWVisionData * detecData);

typedef NS_ENUM(NSInteger,kMLVisionCategory) {
    kMLVisionCategoryBarCode,
    kMLVisionCategoryRact,
    kMLVisionCategoryTxt,
    kMLVisionCategoryFace,
    kMLVisionCategoryFaceLandmark
    //    kMLVisionCategoryTrack,
};


@interface BWVisonTool : NSObject


- (void)detectImageWithType:(kMLVisionCategory)type image:(CVPixelBufferRef)pixeImageRef complete:(detecImageHandler)complete;

- (void)reset;
@end
