//
//  HZViewController.m
//  HZViewPager
//
//  Created by History on 14-7-23.
//  Copyright (c) 2014年 History. All rights reserved.
//

#import "HZViewController.h"
#import "HZViewPager.h"

@interface HZViewController () <HZViewPagerDataSource, HZViewPagerDelegate>
@property (nonatomic, strong) HZViewPager *viewPager;
@end

@implementation HZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.viewPager = [[HZViewPager alloc] initForAutoLayout];
    [self.view addSubview:self.viewPager];
    [self.viewPager autoPinToTopLayoutGuideOfViewController:self withInset:0];
    [self.viewPager autoPinToBottomLayoutGuideOfViewController:self withInset:0];
    [self.viewPager autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.viewPager autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    
    self.viewPager.dataSource = self;
    self.viewPager.delegate = self;
}

- (void)selectAction
{
    [_viewPager setSelectedIndex:4 animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_viewPager reloadData];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfItems:(HZViewPager *)viewPager
{
    return 5;
}

- (NSString *)viewPager:(HZViewPager *)viewPager titleOfItemAtIndex:(NSInteger)index
{
    return @"1";
}

- (UIView *)viewPager:(HZViewPager *)viewPager contentViewAtIndex:(NSInteger)index
{
    UIView *view = [[UIView alloc] initForAutoLayout];
    view.backgroundColor = [UIColor redColor];
    UILabel *label = [[UILabel alloc] initForAutoLayout];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor yellowColor];
    label.text = @"Hello World";
    [view addSubview:label];
    [label autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    return view;
}

#pragma mark - Option DataSource

- (CGFloat)tabItemWidthOfViewPager:(HZViewPager *)viewPager
{
    return self.view.width / 3;
}

- (UIColor *)viewPager:(HZViewPager *)viewPager colorForType:(HZViewPagerColorType)type defaultColor:(UIColor *)defaultColor
{
    switch (type) {
        case HZIndicatorColor: {
            return [UIColor greenColor];
        }
            
        default: {
            return defaultColor;
        }
    }
}

@end
