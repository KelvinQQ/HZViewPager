//
//  HZViewPager.h
//  HZViewPager
//
//  Created by History on 14-7-23.
//  Copyright (c) 2014年 History. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HZViewPager;

@protocol HZViewPagerDataSource <NSObject>

@required
- (NSInteger)numberOfItems:(HZViewPager *)viewPager;
- (NSString *)viewPager:(HZViewPager *)viewPager titleOfItemAtIndex:(NSInteger)index;
- (UIView *)viewPager:(HZViewPager *)viewPager contentViewAtIndex:(NSInteger)index;

@optional
- (CGFloat)tabItemWidthOfViewPager:(HZViewPager *)viewPager;
- (UIColor *)indicatorColorOfViewPager:(HZViewPager *)viewPager;
- (UIColor *)normalTextColorOfViewPager:(HZViewPager *)viewPager;
- (UIColor *)highlightedTextColorOfViewPager:(HZViewPager *)viewPager;

@end

@protocol HZViewPagerDelegate <NSObject>

@optional
- (void)viewPager:(HZViewPager *)viewPager didSelectedAtIndex:(NSInteger)index;

@end


@interface HZViewPager : UIView
@property (nonatomic, weak) id<HZViewPagerDataSource> dataSource;
@property (nonatomic, weak) id<HZViewPagerDelegate> delegate;
@property (nonatomic, assign) NSInteger selectedIndex;
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;
- (void)reloadData;
@end
