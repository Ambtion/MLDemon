//
//  AppDelegate.m
//  MLDemon
//
//  Created by Qu,Ke on 2018/5/7.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import "AppDelegate.h"
#import "BWRootController.h"

@interface AppDelegate ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property(nonatomic,strong)UIPageViewController * pageController;
@property(nonatomic,strong)NSArray * dataSource;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
//    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
//    self.pageController.dataSource = self;
//    self.pageController.view.backgroundColor = [UIColor whiteColor];
//
//    [self.pageController setViewControllers:@[self.dataSource[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
//
//    }];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:self.dataSource[0]];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (NSArray *)dataSource
{
    if (!_dataSource) {
        BWRootController * rc = [[BWRootController alloc] init];
        
        UIViewController * vc1 = [[UIViewController alloc] init];
        vc1.view.backgroundColor = [UIColor greenColor];
        
        
        UIViewController * vc2 = [[UIViewController alloc] init];
        vc2.view.backgroundColor = [UIColor blueColor];
        
        _dataSource = @[rc,vc1,vc2];
    }
    return _dataSource;
}

#pragma mark - PageDataSource
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{

    NSInteger index = [self.dataSource indexOfObject:viewController];
    index++;
    if (index >= self.dataSource.count) {
        return nil;
    }
    return self.dataSource[index%self.dataSource.count];
    
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(nonnull UIViewController *)viewController
{
    NSInteger index = [self.dataSource indexOfObject:viewController];
    index--;
    if (index < 0) {
        return nil;
    }
    return self.dataSource[index%self.dataSource.count];
}

#pragma mark  - PageDelegate


@end
