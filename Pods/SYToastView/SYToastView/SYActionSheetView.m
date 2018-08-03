//
//  SYActionSheetView.m
//  Pods
//  Created by quke on 2017/4/17.
//

#define kTitleHeight 50.f
#define kHcdSheetCellHeight 65.f
#define kHcdScreenHeight [UIScreen mainScreen].bounds.size.height
#define kHcdScreenWidth [UIScreen mainScreen].bounds.size.width

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]
#define UIColorFromRGB(rgbValue) UIColorFromRGBA(rgbValue, 1.0f)

#import "SYActionSheetView.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"

@interface SYActionItem : UIControl

@property(nonatomic,strong)UIImageView * iconView;
@property(nonatomic,strong)UILabel * mainLabel;
@property(nonatomic,strong)UILabel * subLabel;

@property(nonatomic,strong)UIView * bottomLineView;

@end


@implementation SYActionItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.iconView = [[UIImageView alloc] init];
    [self addSubview:self.iconView];
    
    
    self.mainLabel = [[UILabel alloc] init];
    self.mainLabel.textColor = UIColorFromRGB(0x333333);
    self.mainLabel.textAlignment = NSTextAlignmentLeft;
    self.mainLabel.font = [UIFont systemFontOfSize:15.f];
    [self addSubview:self.mainLabel];
    
    self.subLabel = [[UILabel alloc] init];
    self.subLabel.textColor = UIColorFromRGB(0xf77f00);
    self.subLabel.textAlignment = NSTextAlignmentRight;
    self.subLabel.font = [UIFont systemFontOfSize:12.f];
    [self addSubview:self.subLabel];
    
    
    CGFloat offset = 15.f;
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(offset);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(kHcdSheetCellHeight - offset * 2, kHcdSheetCellHeight - offset * 2));
    }];
    
    [self.subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-offset);
        make.centerY.equalTo(self);
    }];
    
    [self.mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconView.mas_right).offset(12.f);
        make.right.equalTo(self.subLabel.mas_left).offset(-12.f);
        make.centerY.equalTo(self);
    }];
    
    self.bottomLineView = [[UIView alloc] init];
    self.bottomLineView.backgroundColor = UIColorFromRGB(0xeaeaea);
    [self addSubview:self.bottomLineView];
    
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
        make.height.equalTo(@(1/[UIScreen mainScreen].scale));
        make.top.equalTo(self);

    }];
}


@end

@interface SYActionSheetView()<UIGestureRecognizerDelegate>

@property(nonatomic,copy)NSString * titleStr;
@property(nonatomic,strong)NSArray * icons;
@property(nonatomic,strong)NSArray * mainTitles;
@property(nonatomic,strong)NSArray * subTitles;

@property(nonatomic,strong)UIView * contetView;

@end

@implementation SYActionSheetView

- (instancetype)initWithTitleStr:(NSString *)str icons:(NSArray *)icons mainTitles:(NSArray *)mainTitles subTitles:(NSArray *)subTitles
{
    self = [super init];
    if (self) {
        self.titleStr = str;
        self.icons = icons;
        self.mainTitles = mainTitles;
        self.subTitles = subTitles;
        
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.frame = CGRectMake(0, 0, kHcdScreenWidth, kHcdScreenHeight);
    self.backgroundColor = [UIColor clearColor];
    
    /*ContentView*/
    self.contetView = [[UIView alloc] init];
    self.contetView.backgroundColor = [UIColor whiteColor];
    
    CGFloat actionContentHeigth = self.mainTitles.count * kHcdSheetCellHeight;
    if (self.titleStr) {
        actionContentHeigth += kTitleHeight;
    }
    self.contetView.frame = CGRectMake(0, kHcdScreenHeight, kHcdScreenWidth, actionContentHeigth);
    [self addSubview:self.contetView];
    
    
    /*end*/
    
    
    /*title*/
    
    if (self.titleStr.length) {
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kTitleHeight)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = UIColorFromRGB(0x333333);
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.text = self.titleStr;
        [self.contetView addSubview:titleLabel];
    }
    
    /*end*/

    
    /*Items*/
    
    
    for (NSInteger i = 0; i < self.mainTitles.count; i++) {
        
        
        SYActionItem * itemView = [[SYActionItem alloc] initWithFrame:CGRectMake(0, (self.titleStr.length ? kTitleHeight : 0 )+ kHcdSheetCellHeight * i, self.frame.size.width, kHcdSheetCellHeight)];
        itemView.tag = 100 + i;
        
        NSString * mainTitle = [self countAtIdex_fix:self.mainTitles index:i];
        NSString * subTitle = [self countAtIdex_fix:self.subTitles index:i];
        id imageRef = [self countAtIdex_fix:self.icons index:i];

        if ([imageRef isKindOfClass:[UIImage class]]) {
            itemView.iconView.image = imageRef;
        }else if ([imageRef isKindOfClass:[NSString class]]){
            [itemView.iconView sd_setImageWithURL:[NSURL URLWithString:imageRef] placeholderImage:nil];
        }
        
        itemView.mainLabel.text = mainTitle;
        itemView.subLabel.text = subTitle;
        [itemView addTarget:self action:@selector(selectedButtons:) forControlEvents:UIControlEventTouchUpInside];

        [self.contetView addSubview:itemView];
        
//        [itemView.bottomLineView setHidden:i == self.mainTitles.count - 1];
        
    }
    
    
    /*end*/

    
}

- (id)countAtIdex_fix:(NSArray *)items index:(NSInteger)index
{
    if (index >=0 && index < items.count) {
        return items[index];
    }
    return nil;
}

#pragma mark - Show | hidden

/**
 *  显示ActionSheet
 */
- (void)showHcdActionSheet
{
    typeof(self) __weak weak = self;
    [UIView animateWithDuration:0.3f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        
        [weak setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f]];
        [self.contetView setFrame:CGRectMake(0, kHcdScreenHeight - self.contetView.frame.size.height, kHcdScreenWidth, self.contetView.frame.size.height)];
        
    } completion:^(BOOL finished) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:weak action:@selector(dismiss:)];
        tap.delegate = self;
        [weak addGestureRecognizer:tap];
        [self.contetView setFrame:CGRectMake(0, kHcdScreenHeight - self.contetView.frame.size.height, kHcdScreenWidth, self.contetView.frame.size.height)];
    }];
}

//隐藏
-(void)dismiss:(UITapGestureRecognizer *)tap{
    
    if( CGRectContainsPoint(self.frame, [tap locationInView:self.contetView])) {
        NSLog(@"tap");
    } else{
        
        [self dismissBlock:^(BOOL complete) {
            
        }];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UITapGestureRecognizer *)gestureRecognizer
{
    return !CGRectContainsPoint(self.frame, [gestureRecognizer locationInView:self.contetView]);
}

//隐藏ActionSheet的Block
-(void)dismissBlock:(completeAnimationBlock)block{
    
    
    typeof(self) __weak weak = self;
    CGFloat height = ((kHcdSheetCellHeight+0.5f)) + (self.mainTitles.count * (kHcdSheetCellHeight+0.5f));
    
    [UIView animateWithDuration:0.4f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        
        [weak setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0f]];
        [self.contetView setFrame:CGRectMake(0, kHcdScreenHeight, kHcdScreenWidth, height)];
        
    } completion:^(BOOL finished) {
        
        block(finished);
        [self removeFromSuperview];
        
    }];
    
}

#pragma mark - Action
/**
 *  按钮的点击事件
 *
 *  @param btns 被点击的按钮
 */
- (void)selectedButtons:(UIButton *)btns{
    
    typeof(self) __weak weak = self;
    [self dismissBlock:^(BOOL complete) {
        if (weak.selectButtonAtIndex) {
            weak.selectButtonAtIndex(btns.tag - 100);
        }
    }];
    
    
}
@end
