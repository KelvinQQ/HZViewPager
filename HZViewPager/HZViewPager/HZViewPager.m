//
//  HZViewPager.m
//  HZViewPager
//
//  Created by History on 14-7-23.
//  Copyright (c) 2014年 History. All rights reserved.
//

#import "HZViewPager.h"

#define kTabItemBaseTag 1000

@class HZTabView;

@protocol HZTabViewDataSource <NSObject>
/**
 *  Number Of Items
 *
 *  @param tabView TabView
 *
 *  @return Number Of Items
 */
- (NSInteger)numberOfItems:(HZTabView *)tabView;
/**
 *  Title For Tab Item At Index
 *
 *  @param tabView TabView
 *  @param index   Index Of Item
 *
 *  @return Title Of TabItem
 */
- (NSString *)tabView:(HZTabView *)tabView titleOfItemAtIndex:(NSInteger)index;

@optional
/**
 *  Tab Item Width
 *
 *  @param tabView TabView
 *
 *  @return Item Width For Tab View
 */
- (CGFloat)tabItemWidthOfTabView:(HZTabView *)tabView;
/**
 *  Indicator Color For Tab View
 *
 *  @param tabView TabView
 *
 *  @return Indicator Color
 */
- (UIColor *)indicatorColorOfTabView:(HZTabView *)tabView;
/**
 *  Normal Text Color For Item Text
 *
 *  @param tabView TabView
 *
 *  @return Normal Text Color
 */
- (UIColor *)normalTextColorOfTabView:(HZTabView *)tabView;
/**
 *  Highlighted Text Color For Item Text
 *
 *  @param tabView TabView
 *
 *  @return Highlighted Text Color
 */
- (UIColor *)highlightedTextColorOfTabView:(HZTabView *)tabView;

@end

@protocol  HZTabViewDelegate <NSObject>

@optional
/**
 *  When Selected Index, It'll Be Called
 *
 *  @param tabView TabView
 *  @param index   Selected Index
 */
- (void)tabView:(HZTabView *)tabView didScrolledToIndex:(NSInteger)index;

@end

@interface HZTabView : UIView
@property (nonatomic, weak) id<HZTabViewDataSource> dataSource;
@property (nonatomic, weak) id<HZTabViewDelegate> delegate;
@end

@interface HZTabView ()
{
    UIScrollView *_scrollView;
    UIView *_indicatorView;
}

@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) NSInteger numberOfItems;
@property (nonatomic, strong) NSMutableArray *tabItems;
@property (nonatomic, strong) UIColor *highlightedTextColor;
@property (nonatomic, strong) UIColor *normalTextColor;
@property (nonatomic, strong) UIColor *indicatorColor;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) NSMutableArray *itemTitles;
/**
 *  For Animated
 */
@property (nonatomic, strong) NSLayoutConstraint *indicatorLeftLc;
@end

@implementation HZTabView

- (void)layoutSubviews
{
    [super layoutSubviews];
    _scrollView.contentSize = CGSizeMake(self.itemWidth * self.numberOfItems, self.bounds.size.height);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultInit];
    }
    return self;
}

- (void)defaultInit
{
    _selectedIndex = -1;
    _itemWidth = 40.f;
    _scrollView = [[UIScrollView alloc] initForAutoLayout];
    [self addSubview:_scrollView];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [_scrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    _indicatorView = [[UIView alloc] initForAutoLayout];
    [_scrollView addSubview:_indicatorView];
    self.indicatorLeftLc = [_indicatorView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_indicatorView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:40];
    [_indicatorView autoSetDimensionsToSize:CGSizeMake(self.itemWidth, 4)];
}

- (void)setDataSource:(id<HZTabViewDataSource>)dataSource
{
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        [self reloadData];
    }
}

- (void)reloadData
{
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.numberOfItems = [_dataSource numberOfItems:self];
    self.itemTitles = [NSMutableArray arrayWithCapacity:_numberOfItems];
    self.tabItems = [NSMutableArray arrayWithCapacity:_numberOfItems];
    for (NSInteger index = 0; index < _numberOfItems; ++ index) {
        [self.tabItems addObject:[NSNull null]];
    }
    /**
     *  Add Button First
     */
    for (NSInteger index = 0; index < _numberOfItems; ++ index) {
        UIButton *button = [self buttonAtIndex:index];
        [_scrollView addSubview:button];
        [button autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
        [button autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:index * self.itemWidth];
        [button autoSetDimensionsToSize:CGSizeMake(self.itemWidth, 40)];
    }
    
    /**
     *  Readd IndicatorView Second
     */
    [_indicatorView autoRemoveConstraintsAffectingView];
    _indicatorView.backgroundColor = self.indicatorColor;
    [_scrollView addSubview:_indicatorView];
    self.indicatorLeftLc = [_indicatorView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_indicatorView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:40];
    [_indicatorView autoSetDimensionsToSize:CGSizeMake(self.itemWidth, 4)];
    
    [self setSelectedIndex:0 animated:NO];
}

/**
 *  Selected At Index
 *
 *  @param index    Selected Index
 *  @param animated animated
 */
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated
{
    if (_selectedIndex != index) {
        [UIView animateWithDuration:animated ? 0.2 : 0
                         animations:^{
                             UIButton *button = (UIButton *)[_scrollView viewWithTag:kTabItemBaseTag + _selectedIndex];
                             [button setTitleColor:self.normalTextColor forState:UIControlStateNormal];
                             
                             self.indicatorLeftLc.constant = index * self.itemWidth;
                             [_indicatorView layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             _selectedIndex = index;
                             
                             UIButton *button = (UIButton *)[_scrollView viewWithTag:kTabItemBaseTag + index];
                             [button setTitleColor:self.highlightedTextColor forState:UIControlStateNormal];
                             
                             [_scrollView scrollRectToVisible:button.frame animated:YES]; // scroll tab item to visible
                         }];
        if (_delegate && [_delegate respondsToSelector:@selector(tabView:didScrolledToIndex:)]) {
            [_delegate tabView:self didScrolledToIndex:index];
        }
    }
}

- (void)setSelectedIndex:(NSInteger)index
{
    [self setSelectedIndex:index animated:YES];
}

- (UIButton *)buttonAtIndex:(NSInteger)index
{
    if (index > self.tabItems.count) {
        NSAssert(false, @"Nil Tab Item");
        return nil;
    }
    if ([self.tabItems[index] isEqual:[NSNull null]]) {
        NSString *title = [_dataSource tabView:self titleOfItemAtIndex:index];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.tag = kTabItemBaseTag + index;
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:self.normalTextColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didSeletedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabItems replaceObjectAtIndex:index withObject:button];
    }
    return self.tabItems[index];
}

#pragma mark -
- (void)didSeletedButton:(UIButton *)button
{
    NSInteger index = button.tag - kTabItemBaseTag;
    self.selectedIndex = index;
}

#pragma mark - Getter Method
- (CGFloat)itemWidth
{
    if ([_dataSource respondsToSelector:@selector(tabItemWidthOfTabView:)]) {
        return [_dataSource tabItemWidthOfTabView:self];
    }
    else {
        return _itemWidth;
    }
}

- (UIColor *)indicatorColor
{
    if (_indicatorColor) {
        return _indicatorColor;
    }
    else if ([_dataSource respondsToSelector:@selector(indicatorColorOfTabView:)]) {
        self.indicatorColor = [_dataSource indicatorColorOfTabView:self];
        return _indicatorColor;
    }
    else {
        self.indicatorColor = [UIColor redColor];
        return _indicatorColor;
    }
}

- (UIColor *)normalTextColor
{
    if (_normalTextColor) {
        return _normalTextColor;
    }
    else if ([_dataSource respondsToSelector:@selector(normalTextColorOfTabView:)]) {
        self.normalTextColor = [_dataSource normalTextColorOfTabView:self];
        return _normalTextColor;
    }
    else {
        self.normalTextColor = [UIColor blackColor];
        return _normalTextColor;
    }
}

- (UIColor *)highlightedTextColor
{
    if (_highlightedTextColor) {
        return _highlightedTextColor;
    }
    else if ([_dataSource respondsToSelector:@selector(highlightedTextColorOfTabView:)]) {
        self.highlightedTextColor = [_dataSource highlightedTextColorOfTabView:self];
        return _highlightedTextColor;
    }
    else {
        self.highlightedTextColor = [UIColor redColor];
        return _highlightedTextColor;
    }
}


@end

@interface HZViewPager () <HZTabViewDataSource, HZTabViewDelegate, UIScrollViewDelegate>
{

}
@property (nonatomic, strong) UIScrollView *contentScorllView;
@property (nonatomic, strong) HZTabView *tabView;

@property (nonatomic, strong) NSMutableArray *contentViews;

@property (nonatomic, assign) CGFloat tabItemWidth;
@property (nonatomic, assign) NSInteger numberOfItems;
@property (nonatomic, strong) UIColor *highlightedTextColor;
@property (nonatomic, strong) UIColor *normalTextColor;
@property (nonatomic, strong) UIColor *indicatorColor;
@end


@implementation HZViewPager

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self defaultInit];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_tabView setNeedsLayout];
    _contentScorllView.contentSize = CGSizeMake(self.numberOfItems * _contentScorllView.width, _contentScorllView.height);
}

- (void)defaultInit
{
    _selectedIndex = -1;
    
    _tabItemWidth = 40.f;
    
    _tabView = [[HZTabView alloc] initForAutoLayout];
    [self addSubview:_tabView];
    [_tabView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
    [_tabView autoSetDimension:ALDimensionHeight toSize:44.f];
    _tabView.delegate = self;
    
    _contentScorllView = [[UIScrollView alloc] initForAutoLayout];
    _contentScorllView.pagingEnabled = YES;
    _contentScorllView.showsHorizontalScrollIndicator = YES;
    _contentScorllView.showsVerticalScrollIndicator = NO;
    
    _contentScorllView.delegate = self;
    
    [self addSubview:_contentScorllView];
    [_contentScorllView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tabView];
    [_contentScorllView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
}

- (void)reloadData
{
    [_contentScorllView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.numberOfItems = [_dataSource numberOfItems:self];
    self.contentViews = [NSMutableArray arrayWithCapacity:_numberOfItems];
    
    for (NSInteger index = 0; index < _numberOfItems; ++ index) {
        [self.contentViews addObject:[NSNull null]];
    }
    
    for (NSInteger index = 0; index < _numberOfItems; ++ index) {
        UIView *view = [self contentViewAtIndex:index];
        [_contentScorllView addSubview:view];
        [view autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
        [view autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:index * self.contentScorllView.width];
        [view autoSetDimensionsToSize:CGSizeMake(self.contentScorllView.width, self.contentScorllView.height)];
    }
}

- (void)setDataSource:(id<HZViewPagerDataSource>)dataSource
{
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        _tabView.dataSource = self;
        [self reloadData];
    }
}

#pragma mark -
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated
{
    if (_selectedIndex != index) {
        [_contentScorllView setContentOffset:CGPointMake(index * _contentScorllView.width, 0) animated:animated];
        _selectedIndex = index;
        
        if (_delegate && [_delegate respondsToSelector:@selector(viewPager:didSelectedAtIndex:)]) {
            [_delegate viewPager:self didSelectedAtIndex:index];
        }
    }
}

- (void)setSelectedIndex:(NSInteger)index
{
    [self setSelectedIndex:index animated:YES];
}

- (UIView *)contentViewAtIndex:(NSInteger)index
{
    if (index > self.contentViews.count) {
        NSAssert(false, @"Nil Content Item");
        return nil;
    }
    if ([self.contentViews[index] isEqual:[NSNull null]]) {
        UIView *view = [_dataSource viewPager:self contentViewAtIndex:index];
        if (view) {
            [self.contentViews replaceObjectAtIndex:index withObject:view];
        }
        else { // if nil, create one
            return [[UIView alloc] initForAutoLayout];
        }
    }
    return self.contentViews[index];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / self.width;
    [_tabView setSelectedIndex:index animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / self.width;
    [_tabView setSelectedIndex:index animated:YES];
}

#pragma mark - DataSource
- (NSInteger)numberOfItems:(HZTabView *)tabView
{
    return [_dataSource numberOfItems:self];
}

- (NSString *)tabView:(HZTabView *)tabView titleOfItemAtIndex:(NSInteger)index
{
    return [_dataSource viewPager:self titleOfItemAtIndex:index];
}

#pragma mark - Option
- (CGFloat)tabItemWidthOfTabView:(HZTabView *)tabView
{
    return self.tabItemWidth;
}

- (UIColor *)indicatorColorOfTabView:(HZTabView *)tabView
{
    return self.indicatorColor;
}
- (UIColor *)normalTextColorOfTabView:(HZTabView *)tabView
{
    return self.normalTextColor;
}
- (UIColor *)highlightedTextColorOfTabView:(HZTabView *)tabView
{
    return self.highlightedTextColor;
}

#pragma mark - Getter
- (CGFloat)tabItemWidth
{
    if ([_dataSource respondsToSelector:@selector(tabItemWidthOfViewPager:)]) {
        return [_dataSource tabItemWidthOfViewPager:self];
    }
    else {
        return _tabItemWidth;
    }
}

- (UIColor *)indicatorColor
{
    if (_indicatorColor) {
        return _indicatorColor;
    }
    else if ([_dataSource respondsToSelector:@selector(viewPager:colorForType:defaultColor:)]) {
        self.indicatorColor = [_dataSource viewPager:self colorForType:HZIndicatorColor defaultColor:[UIColor redColor]];
        return _indicatorColor;
    }
    else if ([_dataSource respondsToSelector:@selector(indicatorColorOfViewPager:)]) {
        self.indicatorColor = [_dataSource indicatorColorOfViewPager:self];
        return _indicatorColor;
    }
    else {
        self.indicatorColor = [UIColor redColor];
        return _indicatorColor;
    }
}

- (UIColor *)normalTextColor
{
    if (_normalTextColor) {
        return _normalTextColor;
    }
    else if ([_dataSource respondsToSelector:@selector(viewPager:colorForType:defaultColor:)]) {
        self.normalTextColor = [_dataSource viewPager:self colorForType:HZNormalTextColor defaultColor:[UIColor blackColor]];
        return _normalTextColor;
    }
    else if ([_dataSource respondsToSelector:@selector(normalTextColorOfViewPager:)]) {
        self.normalTextColor = [_dataSource normalTextColorOfViewPager:self];
        return _normalTextColor;
    }
    else {
        self.normalTextColor = [UIColor blackColor];
        return _normalTextColor;
    }
}

- (UIColor *)highlightedTextColor
{
    if (_highlightedTextColor) {
        return _highlightedTextColor;
    }
    else if ([_dataSource respondsToSelector:@selector(viewPager:colorForType:defaultColor:)]) {
        self.highlightedTextColor = [_dataSource viewPager:self colorForType:HZHighlightedTextColor defaultColor:[UIColor redColor]];
        return _highlightedTextColor;
    }
    else if ([_dataSource respondsToSelector:@selector(highlightedTextColorOfViewPager:)]) {
        self.highlightedTextColor = [_dataSource highlightedTextColorOfViewPager:self];
        return _highlightedTextColor;
    }
    else {
        self.highlightedTextColor = [UIColor redColor];
        return _highlightedTextColor;
    }
}

#pragma mark - Delegate
- (void)tabView:(HZTabView *)tabView didScrolledToIndex:(NSInteger)index
{
    [self setSelectedIndex:index animated:YES];
}

#pragma mark -

@end
