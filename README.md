HZViewPager
===========

ViewPager For iOS.



##Introduce

This is a `ViewPager` use `UIView` not `UIViewController`.
It use `AutoLayout`.

##Depends Lib
* [PureLayout](https://github.com/smileyborg/PureLayout)

	A lib for `AutoLayout`.

* [HZExtension](https://github.com/HistoryZhang/HZExtension)
	
	Some useful category.
	
##FIX

A Bug is we should set `dataSource` or call `- (void)reloadData;` in `- (void)viewDidAppear:(BOOL)animated`.Other wise the layout will not be right.I do not find where the problem is.

##TODO

* Support to change the position of the `TabView`.
	
