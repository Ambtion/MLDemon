//
//  BWVisionData.h
//  MLDemon
//
//  Created by Qu,Ke on 2018/6/19.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface BWVisionData : NSObject

@property(nonatomic,assign)CGSize imageSize;


@property(nonatomic,strong)NSArray * textAllRect;

@property(nonatomic,strong)NSArray * facePoints;

@property(nonatomic,strong)NSArray * borCodeTexts;

@property(nonatomic,strong)NSArray * trackRect;

@property(nonatomic,strong)NSArray * faceAllRect;


@end
