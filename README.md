## MJRefresh
[![SPM supported](https://img.shields.io/badge/SPM-supported-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)

* An easy way to use pull-to-refresh for swift

## Contents

- New Features
    - [Dynamic i18n Switching](#dynamic_i18n_switching)
    - [SPM Supported](#spm_supported)
    - ~~[Swift Chaining Grammar Supported](#swift_chaining_grammar_supported)~~

* Getting Started
    * [Features【Support what kinds of controls to refresh】](#Support_what_kinds_of_controls_to_refresh)
    * [Installation【How to use MJRefresh】](#How_to_use_MJRefresh)
* Comment API
	* [MJRefreshComponent.h](#MJRefreshComponent.h)
	* [MJRefreshHeader.h](#MJRefreshHeader.h)
	* [MJRefreshFooter.h](#MJRefreshFooter.h)
	* ~~[MJRefreshAutoFooter.h](#MJRefreshAutoFooter.h)~~
	* ~~[MJRefreshTrailer.h](#MJRefreshTrailer.h)~~

## New Features
### <a id="dynamic_i18n_switching"></a>Dynamic i18n Switching

Now `MJRefresh components` will be rerendered automatically with `MJRefreshConfig.default.language` setting.

#### Example

Go `i18n` folder and see lots of cases. Simulator example is behind `i18n tab` in right-top corner.

#### Setting language

```swift
MJRefreshConfig.default.language = "zh-hans"
```

#### Setting i18n file name

```swift
MJRefreshConfig.default.i18nFilename = "i18n File Name(not include type<.strings>)"
```

#### Setting i18n language bundle

```swift
MJRefreshConfig.default.i18nBundle = <i18n Bundle>
```

#### Adopting the feature in your DIY component

1. Just override `i18nDidChange` function and reset texts.

```swift
override func i18nDidChange() {
    // Reset texts function
    setupTexts()
    // Make sure to call super after resetting texts. It will call placeSubViews for applying new layout.
    super.i18nDidChange()
}
```

2. Receiving `MJRefreshDidChangeLanguageNotification` notification.

## <a id="Support_what_kinds_of_controls_to_refresh"></a>Support what kinds of controls to refresh

* `UIScrollView`、`UITableView`、`UICollectionView`、`WKWebView`

## <a id="How_to_use_MJRefresh"></a>How to use MJRefresh
* Installation with CocoaPods(Swift and OC)：`pod 'MJRefresh', :git=>'https://github.com/fish-yan/MJRefresh-Swift'`
* Installation with SPM(only for Swift)：`.package(url: "https://github.com/fish-yan/MJRefresh-Swift", branch: "main")`

## <a id="The_Class_Structure_Chart_of_MJRefresh"></a>The Class Structure Chart of MJRefresh
![](http://images0.cnblogs.com/blog2015/497279/201506/132232456139177.png)
- `The class of red text` in the chart：You can use them directly
    - The drop-down refresh control types
        - Normal：`MJRefreshNormalHeader`
        - ~~Gif：`MJRefreshGifHeader`~~
    - The pull to refresh control types
        - Auto refresh
            - Normal：`MJRefreshAutoNormalFooter`
            - ~~Gif：`MJRefreshAutoGifFooter`~~
        - Auto Back
            - Normal：`MJRefreshBackNormalFooter`
            - ~~Gif：`MJRefreshBackGifFooter`~~
- `The class of non-red text` in the chart：For inheritance，to use DIY the control of refresh

## <a id="MJRefreshComponent.h"></a>MJRefreshComponent.h
```swift
/** The Base Class of refresh control */
@objcMembers @objc(MJRefreshComponent)
open class RefreshComponent: UIView {
  	public var fastAnimationDuration: TimeInterval = 0.25
    public var slowAnimationDuration: TimeInterval = 0.4
    public var isRefreshing: Bool
    public var pullingPercent: CGFloat = 0
    public var isAutomaticallyChangeAlpha: Bool = false
    public var refreshingBlock: RefreshComponentAction = {}
    public init(block: @escaping RefreshComponentAction)
    public init(target: Any, action: Selector)
    public func setAnimationDisabled()
    open func i18nDidChange()
    open func beginRefreshing()
    open func endRefreshing()
}
```

## <a id="MJRefreshHeader.h"></a>MJRefreshHeader.h
```swift
@objcMembers @objc(MJRefreshHeader)
open class RefreshHeader: RefreshComponent {
  	@objc(headerWithRefreshingBlock:)
    public static func header(refreshing block: @escaping RefreshComponentAction) -> Self
    
    @objc(headerWithRefreshingTarget: refreshingAction:)
    public static func header(refreshing target: Any, action: Selector) -> Self
      
    public var ignoredScrollViewContentInsetTop: CGFloat = 0
}
```

## <a id="MJRefreshFooter.h"></a>MJRefreshFooter.h
```swift
@objcMembers @objc(MJRefreshFooter)
open class RefreshFooter: RefreshComponent {
    @objc(footerWithRefreshingBlock:)
    public static func footer(block: @escaping RefreshComponentAction) -> Self
    
    @objc(footerWithRefreshingTarget: refreshingAction:)
    public static func footer(target: Any, action: Selector) -> Self
    
    public var ignoredScrollViewContentInsetBottom: CGFloat = 0
    // auto footer or back footer
    public var autoBack = false
    
    open func endRefreshingWithNoMoreData() 
    
    open func resetNoMoreData()
}
```

## <a id="Reference"></a>Reference
## <a id="The_drop-down_refresh_01-Default"></a>The drop-down refresh 01-Default

Swift 

```swift
tableView.mj_header = RefreshNormalHeader {
		//Call this Block When enter the refresh status automatically   
}
或
tableView.mj_header = RefreshNormalHeader.header(refreshing: self, action: #selector(refreshAction))
// Enter the refresh status immediately
tableView.mj.header?.beginRefreshing()
tableView.mj_header?.endRefreshing()
```

OC Same as the original MJRefresh

```objc
self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
   //Call this Block When enter the refresh status automatically 
}];
或
// Set the callback（Once you enter the refresh status，then call the action of target，that is call [self loadNewData]）
self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];

// Enter the refresh status immediately
[self.tableView.mj_header beginRefreshing];
```
![(下拉刷新01-普通)](http://images0.cnblogs.com/blog2015/497279/201506/141204343486151.gif)

## <a id="The_drop-down_refresh_03-Hide_the_time"></a>The drop-down refresh 03-Hide the time
```objc
// Hide the time
header.lastUpdatedTimeLabel.hidden = YES;
```
![(下拉刷新03-隐藏时间)](http://images0.cnblogs.com/blog2015/497279/201506/141204456132944.gif)

## <a id="The_drop-down_refresh_04-Hide_status_and_time"></a>The drop-down refresh 04-Hide status and time
```objc
// Hide the time
header.lastUpdatedTimeLabel.hidden = YES;

// Hide the status
header.stateLabel.hidden = YES;
```
![(下拉刷新04-隐藏状态和时间0)](http://images0.cnblogs.com/blog2015/497279/201506/141204508639539.gif)

## <a id="The_drop-down_refresh_05-DIY_title"></a>The drop-down refresh 05-DIY title
```objc
// Set title
[header setTitle:@"Pull down to refresh" forState:MJRefreshStateIdle];
[header setTitle:@"Release to refresh" forState:MJRefreshStatePulling];
[header setTitle:@"Loading ..." forState:MJRefreshStateRefreshing];

// Set font
header.stateLabel.font = [UIFont systemFontOfSize:15];
header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];

// Set textColor
header.stateLabel.textColor = [UIColor redColor];
header.lastUpdatedTimeLabel.textColor = [UIColor blueColor];
```
![(下拉刷新05-自定义文字)](http://images0.cnblogs.com/blog2015/497279/201506/141204563633593.gif)

## <a id="The_drop-down_refresh_06-DIY_the_control_of_refresh"></a>The drop-down refresh 06-DIY the control of refresh
```objc
self.tableView.mj_header = [MJDIYHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
// Implementation reference to MJDIYHeader.h和MJDIYHeader.m
```
![(下拉刷新06-自定义刷新控件)](http://images0.cnblogs.com/blog2015/497279/201506/141205019261159.gif)

## <a id="The_pull_to_refresh_01-Default"></a>The pull to refresh 01-Default

Swift

```swift
let footer = RefreshFooter {
		//Call this Block When enter the refresh status automatically
}
or
let footer = RefreshNormalFooter.footer(target: self, action: #selector(loadMore))
footer.autoBack = true
tableView.mj_footer = footer
tableView.mj_footer?.endRefreshingWithNoMoreData()
tableView.mj_footer?.endRefreshing()
```

OC Same as the original MJRefresh

```objc
self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
    //Call this Block When enter the refresh status automatically
}];
或
// Set the callback（Once you enter the refresh status，then call the action of target，that is call [self loadMoreData]）
self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
```
![(上拉刷新01-默认)](http://images0.cnblogs.com/blog2015/497279/201506/141205090047696.gif)

## <a id="The_pull_to_refresh_03-Hide_the_title_of_refresh_status"></a>The pull to refresh 03-Hide the title of refresh status
```objc
// Hide the title of refresh status
footer.refreshingTitleHidden = YES;
// If does have not above method，then use footer.stateLabel.hidden = YES;
```
![(上拉刷新03-隐藏刷新状态的文字)](http://images0.cnblogs.com/blog2015/497279/201506/141205200985774.gif)

## <a id="The_pull_to_refresh_05-DIY_title"></a>The pull to refresh 05-DIY title
```objc
// Set title
[footer setTitle:@"Click or drag up to refresh" forState:MJRefreshStateIdle];
[footer setTitle:@"Loading more ..." forState:MJRefreshStateRefreshing];
[footer setTitle:@"No more data" forState:MJRefreshStateNoMoreData];

// Set font
footer.stateLabel.font = [UIFont systemFontOfSize:17];

// Set textColor
footer.stateLabel.textColor = [UIColor blueColor];
```
![(上拉刷新05-自定义文字)](http://images0.cnblogs.com/blog2015/497279/201506/141205295511153.gif)

## <a id="The_pull_to_refresh_06-Hidden_After_loaded"></a>The pull to refresh 06-Hidden After loaded
```objc
//Hidden current control of the pull to refresh
self.tableView.mj_footer.hidden = YES;
```
![(上拉刷新06-加载后隐藏)](http://images0.cnblogs.com/blog2015/497279/201506/141205343481821.gif)

## <a id="The_pull_to_refresh_07-Automatic_back_of_the_pull01"></a>The pull to refresh 07-Automatic back of the pull01
```objc
self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
```
![(上拉刷新07-自动回弹的上拉01)](http://images0.cnblogs.com/blog2015/497279/201506/141205392239231.gif)

## <a id="The_pull_to_refresh_08-Automatic_back_of_the_pull02"></a>The pull to refresh 08-Automatic back of the pull02
```objc
MJRefreshBackGifFooter *footer = [MJRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];

// Set the normal state of the animated image
[footer setImages:idleImages forState:MJRefreshStateIdle];
//  Set the pulling state of animated images（Enter the status of refreshing as soon as loosen）
[footer setImages:pullingImages forState:MJRefreshStatePulling];
// Set the refreshing state of animated images
[footer setImages:refreshingImages forState:MJRefreshStateRefreshing];

// Set footer
self.tableView.mj_footer = footer;
```
![(上拉刷新07-自动回弹的上拉02)](http://images0.cnblogs.com/blog2015/497279/201506/141205441443628.gif)

## <a id="The_pull_to_refresh_09-DIY_the_control_of_refresh(Automatic_refresh)"></a>The pull to refresh 09-DIY the control of refresh(Automatic refresh)
```objc
self.tableView.mj_footer = [MJDIYAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
// Implementation reference to MJDIYAutoFooter.h和MJDIYAutoFooter.m
```
![(上拉刷新09-自定义刷新控件(自动刷新))](http://images0.cnblogs.com/blog2015/497279/201506/141205500195866.gif)

## <a id="The_pull_to_refresh_10-DIY_the_control_of_refresh(Automatic_back)"></a>The pull to refresh 10-DIY the control of refresh(Automatic back)
```objc
self.tableView.mj_footer = [MJDIYBackFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
// Implementation reference to MJDIYBackFooter.h和MJDIYBackFooter.m
```
![(上拉刷新10-自定义刷新控件(自动回弹))](http://images0.cnblogs.com/blog2015/497279/201506/141205560666819.gif)

## <a id="UICollectionView01-The_pull_and_drop-down_refresh"></a>UICollectionView01-The pull and drop-down refresh
```objc
// The drop-down refresh
self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
   //Call this Block When enter the refresh status automatically 
}];

// The pull to refresh
self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
   //Call this Block When enter the refresh status automatically
}];
```
![(UICollectionView01-上下拉刷新)](http://images0.cnblogs.com/blog2015/497279/201506/141206021603758.gif)

## <a id="WKWebView01-The_drop-down_refresh"></a>WKWebView01-The drop-down refresh
```objc
//Add the control of The drop-down refresh
self.webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
   //Call this Block When enter the refresh status automatically
}];
```
![(UICollectionView01-上下拉刷新)](http://images0.cnblogs.com/blog2015/497279/201506/141206080514524.gif)

## Remind
* iOS>=13.0
* iPhone \ iPad screen anyway
