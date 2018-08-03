//
//  BWVisonTool.m
//  MLDemon
//
//  Created by Qu,Ke on 2018/6/19.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import "BWVisonTool.h"
#import <Vision/Vision.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>


@interface BWVisonTool()

@property(nonatomic,strong)NSMutableDictionary * obsertionList;
@property(nonatomic,strong)VNSequenceRequestHandler *sequenceHandler;

@end

typedef void(^CompleteHandle)(VNRequest * request,NSError * error);

@implementation BWVisonTool

- (void)reset
{
    self.obsertionList = nil;
    self.sequenceHandler = nil;
}

- (void)detectImageWithType:(kMLVisionCategory)type image:(CVPixelBufferRef)pixeImageRef complete:(detecImageHandler)complete
{
    
    CompleteHandle handler = ^(VNRequest * request,NSError * error){
        
        NSArray * result = request.results;
        [self handleImageWithType:type pixelBuffer:pixeImageRef observations:result complete:complete];
        
    };
    
    VNImageBasedRequest *detectRequest = [[VNImageBasedRequest alloc]init];
    
    VNImageRequestHandler * requestHandler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:pixeImageRef options:@{}];
    
    switch (type) {
        case kMLVisionCategoryBarCode:
        {
            self.obsertionList = nil;
            detectRequest = [[VNDetectBarcodesRequest alloc] initWithCompletionHandler:handler];
        }
            break;
        case kMLVisionCategoryRact:
        {
            if (self.obsertionList.count == 0) {
                [self detecObjectRectWithPixelBuffer:pixeImageRef complete:complete];
            }else{
                [self trackObjectRectWithType:type Image:pixeImageRef complete:complete];
            }
            return;
        }
            break;
        case kMLVisionCategoryTxt:
        {
            self.obsertionList = nil;
            detectRequest = [[VNDetectTextRectanglesRequest alloc]initWithCompletionHandler:handler];
            [detectRequest setValue:@(YES) forKey:@"reportCharacterBoxes"]; // 设置识别具体文字
        }
            break;
        case kMLVisionCategoryFace:
        {
            self.obsertionList = nil;
            detectRequest = [[VNDetectFaceRectanglesRequest alloc] initWithCompletionHandler:handler];
        }
            break;
        case kMLVisionCategoryFaceLandmark:
        {
            self.obsertionList = nil;
            detectRequest = [[VNDetectFaceLandmarksRequest alloc] initWithCompletionHandler:handler];
        }
            break;
        default:
            break;
    }
    
    [requestHandler performRequests:@[detectRequest] error:nil];
}

- (void)trackObjectRectWithType:(kMLVisionCategory)type Image:(CVPixelBufferRef)pixeImageRef complete:(detecImageHandler)complete
{
    
    VNImageBasedRequest *detectRequest = [[VNImageBasedRequest alloc]init];
    
    NSMutableArray * requestArray = @[].mutableCopy;
    
    NSArray<NSString *> *obsercationKeys = self.obsertionList.allKeys;
    
    for(NSString * key in obsercationKeys){
        
        detectRequest = [[VNTrackObjectRequest alloc] initWithDetectedObjectObservation:self.obsertionList[key] completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
            
            if (nil == error && request.results.count > 0) {
                
                VNDetectedObjectObservation *rectangleObservation = (VNDetectedObjectObservation *)[self getBestObservationFromObservationList:request.results];
                if (rectangleObservation.confidence < 0.3) {
                    [self.obsertionList removeObjectForKey:rectangleObservation.uuid.UUIDString];
                    return ;
                }else{
                    [self.obsertionList setObject:rectangleObservation forKey:rectangleObservation.uuid.UUIDString];
                }
                
            }else{
                [self.obsertionList removeObjectForKey:key];
            }
            
            [self handleImageWithType:type pixelBuffer:pixeImageRef observations:nil complete:complete];
            
        }];
        
        [requestArray addObject:detectRequest];
        
    }
    if (!self.sequenceHandler) {
        self.sequenceHandler = [[VNSequenceRequestHandler alloc] init];
    }
    [self.sequenceHandler performRequests:requestArray onCVPixelBuffer:pixeImageRef error:nil];
    
}

#pragma mark -

-(void)detecObjectRectWithPixelBuffer:(CVPixelBufferRef)pixeImageRef complete:(detecImageHandler)complete
{
    
    CompleteHandle completeHandler = ^(VNRequest * request, NSError * error){
        
        if (!error && request.results.count > 0) {
            
            for (VNDetectedObjectObservation *observation in request.results) {
                [self.obsertionList setObject:observation forKey:observation.uuid.UUIDString];
            }
            
            [self detectImageWithType:kMLVisionCategoryRact image:pixeImageRef complete:complete];
        }
        
    };
    
    VNDetectRectanglesRequest * requset = [[VNDetectRectanglesRequest alloc] initWithCompletionHandler:completeHandler];
    VNImageRequestHandler * requestHandler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:pixeImageRef options:@{}];

    requset.minimumAspectRatio = 0.1;
    requset.maximumObservations = 0;
    [requestHandler performRequests:@[requset] error:nil];
    
}

#pragma mark handResult 处理结果
- (void)handleImageWithType:(kMLVisionCategory)type pixelBuffer:(CVPixelBufferRef)pixeImageRef observations:(NSArray *)observations complete:(detecImageHandler _Nullable )complete
{
    
    switch (type) {
        case kMLVisionCategoryBarCode:
        {
            [self barcodeWithObervation:observations complete:complete];
        }
            break;
        case kMLVisionCategoryRact:
        {
            [self trackRectWithObervation:observations pixelBuffer:pixeImageRef complete:complete];
        }
            break;
        case kMLVisionCategoryTxt:
        {
            [self trackTextWithObervation:observations pixelBuffer:pixeImageRef complete:complete];
        }
            break;
        case kMLVisionCategoryFace:
        {
            [self detecFaceWithObervation:observations pixelBuffer:pixeImageRef complete:complete];
        }
            break;
        case kMLVisionCategoryFaceLandmark:
        {
            [self facelandmark:observations pixelBuffer:pixeImageRef complete:complete];
        }
            break;
        default:
            break;
    }
}

#pragma 二维码识别处理
- (void)barcodeWithObervation:(NSArray *)observations complete:(detecImageHandler _Nullable )complete
{
    
    BWVisionData *detectTextData = [[BWVisionData alloc]init];
    
    VNBarcodeObservation * bestVation = (VNBarcodeObservation *)[self getBestObservationFromObservationList:observations];
    
    detectTextData.borCodeTexts = @[bestVation.payloadStringValue];
    if (complete) {
        complete(detectTextData);
    }
}

#pragma 区块跟踪
- (void)trackRectWithObervation:(NSArray *)observations pixelBuffer:(CVPixelBufferRef)pixeImageRef complete:(detecImageHandler _Nullable )complete
{
    
    size_t width = CVPixelBufferGetWidth(pixeImageRef);
    size_t height = CVPixelBufferGetHeight(pixeImageRef);
    CGSize size = CGSizeMake(width, height);
    
    BWVisionData *detectTextData = [[BWVisionData alloc]init];
    detectTextData.imageSize = size;
    
    NSMutableArray * tempArray = @[].mutableCopy;
    
    for (NSString * key in self.obsertionList.allKeys) {
        VNDetectedObjectObservation * observation = [self.obsertionList objectForKey:key];
        NSValue *rectValue = [NSValue valueWithCGRect:[self convertRect:observation.boundingBox imageSize:size]];
        [tempArray addObject:rectValue];
    }
    
    detectTextData.trackRect = tempArray;
    
    if (complete) {
        complete(detectTextData);
    }
    
}

#pragma 文字区域处理
- (void)trackTextWithObervation:(NSArray *)observations pixelBuffer:(CVPixelBufferRef)pixeImageRef complete:(detecImageHandler _Nullable )complete
{
    
    
    size_t width = CVPixelBufferGetWidth(pixeImageRef);
    size_t height = CVPixelBufferGetHeight(pixeImageRef);
    CGSize size = CGSizeMake(width, height);
    
    BWVisionData *detectTextData = [[BWVisionData alloc]init];
    detectTextData.imageSize = size;
    
    NSMutableArray *tempArray = @[].mutableCopy;
    
    for (VNTextObservation *observation  in observations) {
        for (VNRectangleObservation *box in observation.characterBoxes) {
            NSValue *ractValue = [NSValue valueWithCGRect:[self convertRect:box.boundingBox imageSize:size]];
            [tempArray addObject:ractValue];
        }
    }
    
    detectTextData.textAllRect = tempArray;
    
    if (complete) {
        complete(detectTextData);
    }
    
}

#pragma 人脸区域处理
- (void)detecFaceWithObervation:(NSArray *)observations pixelBuffer:(CVPixelBufferRef)pixeImageRef complete:(detecImageHandler _Nullable )complete
{
    
    size_t width = CVPixelBufferGetWidth(pixeImageRef);
    size_t height = CVPixelBufferGetHeight(pixeImageRef);
    CGSize size = CGSizeMake(width, height);
    
    BWVisionData *detectTextData = [[BWVisionData alloc]init];
    detectTextData.imageSize = size;
    
    NSMutableArray *tempArray = @[].mutableCopy;
    
    for (VNFaceObservation * observation in observations) {
        
        NSValue *ractValue = [NSValue valueWithCGRect:[self convertRect:observation.boundingBox imageSize:size]];
        [tempArray addObject:ractValue];
    }
    
    detectTextData.faceAllRect = tempArray;
    
    if (complete) {
        complete(detectTextData);
    }
}

#pragma 人脸特征处理
- (void)facelandmark:(NSArray *)observations pixelBuffer:(CVPixelBufferRef)pixeImageRef complete:(detecImageHandler _Nullable )complete
{
    if (!observations.count) {
        return;
    }
    
    size_t width = CVPixelBufferGetWidth(pixeImageRef);
    size_t height = CVPixelBufferGetHeight(pixeImageRef);
    CGSize size = CGSizeMake(width, height);
    
    
    BWVisionData *detectTextData = [[BWVisionData alloc]init];
    detectTextData.imageSize = size;

    NSMutableArray * observationMarks = @[].mutableCopy;
    
    
    for (VNFaceObservation* observation in observations) {
        
        
        NSMutableArray * marks2D = @[].mutableCopy;

        VNFaceLandmarks2D * marks = observation.landmarks;
        
        [self getAllKeyFromClass:[VNFaceLandmarks2D class] isProperty:YES block:^(NSString *key) {
        
            if ([key isEqualToString:@"allPoints"] ||
                [key isEqualToString:@"medianLine"] ||
                [key isEqualToString:@"noseCrest"]) {
                return;
            }
            
            NSMutableArray * region = @[].mutableCopy;
            
            VNFaceLandmarkRegion2D * landmarks2D = [marks valueForKey:key];
            
            
            for (int i=0; i<landmarks2D.pointCount; i++) {
                
                CGPoint point = landmarks2D.normalizedPoints[i];
                CGFloat rectWidth = size.width * observation.boundingBox.size.width;
                CGFloat rectHeight = size.height * observation.boundingBox.size.height;
                CGPoint p = CGPointMake(point.x * rectWidth + observation.boundingBox.origin.x * size.width,
                                        observation.boundingBox.origin.y * size.height + point.y * rectHeight);
                
                [region addObject:[NSValue valueWithCGPoint:p]];
            }
            
            [marks2D addObject:region];
            
        }];
        
        [observationMarks addObject:marks2D];
        
    }
    
    detectTextData.facePoints = observationMarks;
    
    if (complete) {
        complete(detectTextData);
    }

    
}

- (void)getAllKeyFromClass:(Class)class isProperty:(BOOL)isGetProperty block:(void(^)(NSString * key))block
{
    unsigned int propertyCount = 0;
    const char * _Nonnull name = NULL;
    
    Ivar  * ivarList = NULL;
    objc_property_t * propertyList = NULL;
    
    
    if (isGetProperty) {
        propertyList = class_copyPropertyList(class, &propertyCount);
    }else{
        ivarList = class_copyIvarList(class, &propertyCount);
    }
    
    for (int i = 0; i < propertyCount; i++) {
        
        if (isGetProperty) {
            
            objc_property_t pro_t = propertyList[i];
            name = property_getName(pro_t);
            
        }else{
        
            Ivar ivar = ivarList[i];
            name = ivar_getName(ivar);
            
        }
        NSString * key = [NSString stringWithUTF8String:name];
        if (block) {
            block(key);
        }
        
    }
    
    if (isGetProperty) {
        free(propertyList);
    }else{
        free(ivarList);
    }
    
}

#pragma mark - CommonMethod
- (VNObservation *)getBestObservationFromObservationList:(NSArray *)observationList
{
    VNObservation * bestVation = nil;
    
    for (VNObservation * value in observationList) {
        
        if (value.confidence > bestVation.confidence) {
            bestVation = value;
        }
    }
    return bestVation;
}

- (CGRect)convertRect:(CGRect)oldRect imageSize:(CGSize)imageSize
{
    
    CGFloat w = oldRect.size.width * imageSize.width;
    CGFloat h = oldRect.size.height * imageSize.height;
    CGFloat x = oldRect.origin.x * imageSize.width;
    CGFloat y = imageSize.height - (oldRect.origin.y * imageSize.height) - h;
    
    return CGRectMake(x, y, w, h);
}


#pragma mark - GetMethod
- (NSMutableDictionary *)obsertionList
{
    if (!_obsertionList) {
        _obsertionList = [[NSMutableDictionary alloc] init];
    }
    return _obsertionList;
}
@end
