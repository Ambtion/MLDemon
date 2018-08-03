//
//  RootController.m
//  MLDemon
//
//  Created by Qu,Ke on 2018/5/7.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import "BWRootController.h"
#import "BWCamPreviewView.h"
#import "BWPixelBufferUtils.h"
#import "BWVisonTool.h"
#import "BWViewDrawTool.h"

@interface BWRootController ()<UITableViewDelegate,
                                UITableViewDataSource,
                                AVCaptureVideoDataOutputSampleBufferDelegate>

@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)UILabel *infoLabel;
@property(nonatomic,strong)UIImageView * imageView;

@property(nonatomic,strong)NSArray * dataSource;
@property(nonatomic,assign)kMLVisionCategory seletedCatergory;


@property(nonatomic,strong)AVCaptureVideoPreviewLayer * preViewLayer;
@property(nonatomic,strong)AVCaptureSession * session;

@property(nonatomic, assign) NSUInteger counter;   // 计数器
@property(nonatomic,strong)BWVisonTool * visonTool;

@end

@implementation BWRootController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIBarButtonItem * itemButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(resetImageView)];
    UIBarButtonItem * itemButton2 =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRedo target:self action:@selector(showFunctions)];
    self.navigationItem.rightBarButtonItems = @[itemButton,itemButton2];
    
    self.dataSource = @[@"二维码/条形码检测",
                        @"矩形检测",
                        @"文字检测",
                        @"人脸检测",
                        @"特征识别"];
    
    [self initCapture];
    
    
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.imageView];
    
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40)];
    [self.view addSubview:self.infoLabel];
    self.infoLabel.backgroundColor = [UIColor colorWithRed:0x00 green:0x00 blue:0x00 alpha:0.4];
    self.infoLabel.textColor = [UIColor whiteColor];
    self.infoLabel.numberOfLines = 0;
    
    [self initTableView];
    [self showTableView];
    
}


- (void)resetImageView
{
    [self.visonTool reset];
    self.imageView.image = nil;
    [self hidenTableView];
    [self.session startRunning];
    
}

- (void)showFunctions
{
    [self showTableView];
}

#pragma mark -
- (void)initTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 200)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
}

- (void)showTableView
{
    
    [self.session stopRunning];
    self.imageView.image = nil;

    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.frame = CGRectMake(0, self.view.frame.size.height - 200, self.view.frame.size.width, 200);
        
    }];
}

- (void)hidenTableView
{
    
    [self.session startRunning];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 200);
    }];
    
}

#pragma mark - tableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.seletedCatergory = indexPath.row;
    [self hidenTableView];
}

#pragma mark - VedioPreView
-(void)initCapture
{
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    AVCaptureVideoDataOutput * outPut  = [[AVCaptureVideoDataOutput alloc] init];
    dispatch_queue_t queue = dispatch_queue_create("cameraQueue", NULL);
    
    [outPut setSampleBufferDelegate:self queue:queue];
    
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [outPut setVideoSettings:videoSettings];
    
    self.session = [[AVCaptureSession alloc] init];
    [self.session addInput:input];
    [self.session addOutput:outPut];
    
    // 创建输出对象
    BWCamPreviewView *preView = [[BWCamPreviewView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:preView];
    preView.session = self.session;
    
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    if (self.counter % 10 != 0) {
        self.counter ++;
        return;
    }
    
    self.counter = 0;
    
    @autoreleasepool{
        
        
        CVPixelBufferRef piexBuffer = [BWPixelBufferUtils rotateBuffer:sampleBuffer withConstant:MOVRotateDirectionCounterclockwise270];
        
        [self.visonTool detectImageWithType:self.seletedCatergory image:piexBuffer complete:^(BWVisionData *detecData) {
           
            
            if (![self.session isRunning]) {
                return ;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                switch (self.seletedCatergory) {
                        
                    case kMLVisionCategoryBarCode:
                    {
                        self.infoLabel.text = [detecData.borCodeTexts firstObject];
                        
                    }
                        break;
                    case kMLVisionCategoryRact:
                    {
                        [self.imageView setImage: [BWViewDrawTool drawRectViewWithFrame:detecData.trackRect withImageSize:detecData.imageSize]];

                    }
                        break;
                    case kMLVisionCategoryTxt:
                    {
                        [self.imageView setImage: [BWViewDrawTool drawRectViewWithFrame:detecData.textAllRect withImageSize:detecData.imageSize]];
                    }
                        break;
                    case kMLVisionCategoryFace:
                    {
                        [self.imageView setImage: [BWViewDrawTool drawRectViewWithFrame:detecData.faceAllRect withImageSize:detecData.imageSize]];
                    }
                        break;
                    case kMLVisionCategoryFaceLandmark:
                    {
                         [self.imageView setImage: [BWViewDrawTool drawFaceMarksViewWithPoints:detecData.facePoints withImageSize:detecData.imageSize]];
                    }
                        break;
                    default:
                        break;
                }
            });

            
        }];
        
        CVBufferRelease(piexBuffer);
        
    }
}

#pragma mark -

#pragma mark - barCode
-(BWVisonTool *)visonTool
{
    if (!_visonTool) {
        _visonTool = [[BWVisonTool alloc] init];
    }
    return _visonTool;
}

@end
