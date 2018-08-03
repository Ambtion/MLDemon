//
//  SYTotasView.m
//  Pods
//
//  Created by quke on 2017/5/10.
//
//

#import "SYTotasView.h"

@interface SYTotasView()

@property(nonatomic,strong)UIImageView * alertView;
@property(nonatomic,strong)UILabel * title;

@end

@implementation SYTotasView

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        [self intUIWithtitle:title];
    }
    return self;
}

- (void)intUIWithtitle:(NSString *)title
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.alertView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.alertView.image = [[UIImage imageNamed:@"popup_alert.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    [self addSubview:self.alertView];
    
    self.title = [[UILabel alloc] initWithFrame:CGRectZero];
    self.title.textAlignment = NSTextAlignmentCenter;
    self.title.backgroundColor = [UIColor clearColor];
    self.title.font = [UIFont systemFontOfSize:16];
    self.title.textColor = [UIColor whiteColor];
    self.title.text = title;
    [self.title sizeToFit];
    
    self.alertView.frame = CGRectMake(0, 0, _title.frame.size.width + 56, 44);
    self.alertView.center = CGPointMake(rect.size.width / 2.f, rect.size.height / 2.f);
    self.title.center = CGPointMake(self.alertView.frame.size.width /2.f, self.alertView.frame.size.height/2.f);
    [self.alertView addSubview:self.title];
    
}


#pragma mark - Show or dismiss

- (void)dismissAfterDelay
{
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismiss];
    });

}

- (void)dismiss
{
    [self removeFromSuperview];
}

- (void)showInController:(UIViewController *)controller
{
    NSAssert(controller == nil, @"controller must not be nil");
    [self showInView:controller.view];
}

- (void)showInView:(UIView *)view
{
    
    if([self viewHasShowTotast:view]) return;
    
    [view addSubview:self];

    [self  dismissAfterDelay];
}


- (BOOL)viewHasShowTotast:(UIView *)view
{
    for (UIView * subView in [view subviews]) {
        if ([subView isKindOfClass:[self class]]) {
            return YES;
        }
    }
    return NO;

}

@end
