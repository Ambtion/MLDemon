//
//  SYActionSheetView.h
//
//  Created by quke on 2017/4/17.
//

#import <UIKit/UIKit.h>

typedef void(^completeAnimationBlock)(BOOL complete);
typedef void(^seletedButtonIndexBlock)(NSInteger index);

@interface SYActionSheetView : UIView

@property (nonatomic,strong) seletedButtonIndexBlock selectButtonAtIndex;

/**
 *  传入相关参数初始化HcdActionSheet
 *
 *  @param str         标题文字
 *  @param icons       Icon (支持url（NSString） 与本地图片(UIImage))
 *  @param mainTitles  所有选项文字数组
 *  @param subTitles    提示文字
 *
 *  @return SYActionSheetView对象
 */
- (instancetype)initWithTitleStr:(NSString *)str icons:(NSArray *)icons mainTitles:(NSArray *)mainTitles subTitles:(NSArray *)subTitles;


/**
 *  显示出来
 */
- (void)showHcdActionSheet;



/* example
 SYActionSheetView * acView = [[SYActionSheetView alloc] initWithTitleStr:@"测试"
 icons:@[
 [UIImage imageNamed:@"icon_common_recommand_nodata"],
 [UIImage imageNamed:@"icon_common_recommand_nodata"],
 [UIImage imageNamed:@"icon_common_recommand_nodata"]
 ]
 mainTitles:@[
 @"膜拜",
 @"ofo",
 @"其他"
 ]
 subTitles:@[
 @"便宜实惠",
 @"便宜实惠宜实惠宜实惠宜实惠宜实惠",
 @"其他"
 ]];
 
 acView.selectButtonAtIndex = ^(NSInteger index) {
 
 };
 
 
 [self.view addSubview:acView];
 [acView showHcdActionSheet];

 */

@end
